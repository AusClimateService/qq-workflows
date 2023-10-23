import calendar
import sys

import geopandas as gp
from clisops.core.subset import subset_shape
import matplotlib.pyplot as plt
import numpy as np
import cartopy.crs as ccrs
import xesmf as xe
import cmdline_provenance as cmdprov

sys.path.append('/g/data/wp00/shared_code/qqscale')
import utils


linestyles = {
    'hist': 'solid',
    'ref': 'solid',
    'target': 'dotted',
    'qq': 'dotted'
}


def quantile_spatial_plot(
    da, month, cmap, levels, lat_bounds=None, lon_bounds=None, city_lat_lon={},
):
    """Spatial plot of the 10th, 50th and 90th percentile"""
    
    da_selection = da.sel({'quantiles': [.1, .5, .9], 'month': month}, method='nearest')
    if lat_bounds:
        lat_min, lat_max = lat_bounds
        da_selection = da_selection.sel(lat=slice(lat_min, lat_max))
    if lon_bounds:
        lon_min, lon_max = lon_bounds
        da_selection = da_selection.sel(lon=slice(lon_min, lon_max))
        
    p = da_selection.plot(
        col='quantiles',
        transform=ccrs.PlateCarree(),
        cmap=cmap,
        figsize=[20, 5.5],
        subplot_kws={'projection': ccrs.PlateCarree(),},
        levels=levels,
    )
    for ax in p.axes.flat:
        ax.coastlines()
        for lat, lon in city_lat_lon.values():
            ax.plot(
                lon,
                lat,
                marker='o',
                markerfacecolor='lime',
                markeredgecolor='none',
                zorder=5,
                transform=ccrs.PlateCarree()
            )
    plt.suptitle(calendar.month_name[month])
    plt.show()
    

def quantile_month_plot(quantiles, ax, cmap, levels=None, extend='both', point=None, title=None):
    """Create two dimensional month/quantile plot"""
    
    kwargs = {}  
    if levels:
        kwargs['levels'] = levels
    else:
        data_max = np.abs(quantiles).max()
        kwargs['vmin'] = data_max * -1
        kwargs['vmax'] = data_max
    
    quantiles.transpose('month', 'quantiles').plot(ax=ax, cmap=cmap, extend=extend, **kwargs)
    
    yticks = np.arange(1,13)
    ytick_labels = [calendar.month_abbr[i] for i in yticks]
    ax.set_yticks(yticks, ytick_labels)
    ax.invert_yaxis()
    if title:
        ax.set_title(title)


def spatial_comparison_data(da1, da2, scaling):
    """Compare two spatial fields."""
    
    primary_da = da1.copy()
    secondary_da = da2.copy()
    primary_attrs = primary_da.attrs

    if len(primary_da['lat']) > len(secondary_da['lat']):
        regridder = xe.Regridder(secondary_da, primary_da, "bilinear")
        secondary_da = regridder(secondary_da)
        secondary_da = secondary_da.compute()
    elif len(primary_da['lat']) < len(secondary_da['lat']):
        regridder = xe.Regridder(primary_da, secondary_da, "bilinear")
        primary_da = regridder(primary_da)
        primary_da = primary_da.compute()

    if scaling == 'additive':
        comparison = primary_da - secondary_da
    elif scaling == 'multiplicative':
        comparison = ((primary_da - secondary_da) / secondary_da) * 100
        
    comparison.attrs = primary_attrs
    if scaling == 'multiplicative':
        comparison.attrs['units'] = '% difference'
    
    return comparison 


def spatial_comparison_plot(
    da_clim1,
    da_clim2,
    da_comp,
    clim1_title,
    clim2_title,
    clim_cmap,
    comp_cmap,
    clim_levels,
    comp_levels,
    scaling,
    land_only=False,
    city_lat_lon={},
    clim_extend='max',
    outfile=None,
):
    """Spatial plot of two climatologies and their difference."""
    
    if land_only:
        shape = gp.read_file('/g/data/ia39/aus-ref-clim-data-nci/shapefiles/data/australia/australia.shp')
        da_clim1 = subset_shape(da_clim1, shape=shape)
        da_clim2 = subset_shape(da_clim2, shape=shape)
        da_comp = subset_shape(da_comp, shape=shape)
        
    fig = plt.figure(figsize=[24, 6])

    ax1 = fig.add_subplot(131, projection=ccrs.PlateCarree())
    da_clim1.plot(
        ax=ax1,
        transform=ccrs.PlateCarree(),
        cmap=clim_cmap,
        levels=clim_levels,
        extend=clim_extend,
    )
    ax1.set_title(clim1_title)
    
    ax2 = fig.add_subplot(132, projection=ccrs.PlateCarree())
    da_clim2.plot(
        ax=ax2,
        transform=ccrs.PlateCarree(),
        cmap=clim_cmap,
        levels=clim_levels,
        extend=clim_extend,
    )
    ax2.set_title(clim2_title)

    ax3 = fig.add_subplot(133, projection=ccrs.PlateCarree())
    da_comp.plot(
        ax=ax3,
        transform=ccrs.PlateCarree(),
        cmap=comp_cmap,
        levels=comp_levels,
        extend='both'
    )
    comp_text = 'Difference' if scaling == 'additive' else 'Ratio'
    ax3.set_title(comp_text)

    for ax in [ax1, ax2, ax3]:
        ax.coastlines()
        for lat, lon in city_lat_lon.values():
            ax.plot(
                lon,
                lat,
                marker='o',
                markerfacecolor='lime',
                markeredgecolor='none',
                zorder=5,
                transform=ccrs.PlateCarree()
            )

    xmin = 112.92
    xmax = 153.63
    ymin = -43.625
    ymax = -10.07
    ax1.set_extent([xmin, xmax, ymin, ymax], crs=ccrs.PlateCarree())
    ax2.set_extent([xmin, xmax, ymin, ymax], crs=ccrs.PlateCarree())
    ax3.set_extent([xmin, xmax, ymin, ymax], crs=ccrs.PlateCarree())
    
    if outfile:
        plt.savefig(outfile, bbox_inches='tight', facecolor='white', dpi=300)
    else:
        plt.show()


def plot_quantiles_2d_point(
    da_hist_q_point,
    da_ref_point,
    da_target_point,
    da_af_point,
    variable,
    quantiles,
    general_cmap,
    af_cmap,
    general_levels,
    af_levels,
):
    """Plot historical, reference and target quantiles for a single grid point."""
    
    da_ref_q_point = utils.get_quantiles(da_ref_point, quantiles, timescale='monthly')
    da_target_q_point = utils.get_quantiles(da_target_point, quantiles, timescale='monthly')
    extend = 'max' if 'pr' in variable else 'both'
    
    fig = plt.figure(figsize=[20, 24])
    ax1 = fig.add_subplot(411)
    ax2 = fig.add_subplot(412)
    ax3 = fig.add_subplot(413)
    ax4 = fig.add_subplot(414)
    
    da_ref_q_point.attrs = da_target_point.attrs
    quantile_month_plot(
        da_ref_q_point,
        ax1,
        general_cmap,
        general_levels,
        title='reference quantiles',
        extend=extend,
    )
    da_hist_q_point.attrs = da_target_point.attrs
    quantile_month_plot(
        da_hist_q_point,
        ax2,
        general_cmap,
        general_levels,
        title='historical quantiles',
        extend=extend,
    )
    da_target_q_point.attrs = da_target_point.attrs
    quantile_month_plot(
        da_target_q_point,
        ax3,
        general_cmap,
        general_levels,
        title='target quantiles',
        extend=extend,
    )
    quantile_month_plot(
        da_af_point,
        ax4,
        af_cmap,
        af_levels,
        title='adjustment factors'
    )
    plt.show()
    

def plot_pdfs_point(
    da_hist_point, da_ref_point, da_target_point, da_qq_point, xbounds=None, ybounds=None, month=None
):
    """Plot PDFs for a single grid point"""

    hist_point = da_hist_point.copy()
    ref_point = da_ref_point.copy()
    target_point = da_target_point.copy()
    qq_point = da_qq_point.copy()
    if month:
        hist_point = hist_point[hist_point['time'].dt.month == month]
        ref_point = ref_point[ref_point['time'].dt.month == month]
        target_point = target_point[target_point['time'].dt.month == month]
        qq_point = qq_point[qq_point['time'].dt.month == month]        
    
    fig = plt.figure(figsize=[15, 5])
    ax1 = fig.add_subplot(121)
    ax2 = fig.add_subplot(122)
    bins = np.arange(-20, 150, 1)
    ref_point.plot.hist(
        ax=ax1,
        bins=bins,
        density=True,
        label='reference',
        facecolor='tab:green',
        alpha=0.5,
        rwidth=0.9,
    )
    hist_point.plot.hist(
        ax=ax1,
        bins=bins,
        density=True,
        label='histotical',
        facecolor='tab:blue',
        alpha=0.5,
        rwidth=0.9,
    )
    ax1.set_ylabel('probability')
    if xbounds:
        ax1.set_xlim(xbounds[0], xbounds[1])
    if ybounds:
        ax1.set_ylim(ybounds[0], ybounds[1])
    ax1.legend()
    ax1.set_title('')

    target_point.plot.hist(
        ax=ax2,
        bins=bins,
        density=True,
        label='target',
        facecolor='tab:green',
        alpha=0.5,
        rwidth=0.9,
    )
    qq_point.plot.hist(
        ax=ax2,
        bins=bins,
        density=True,
        label='QQ-scaled data',
        facecolor='tab:orange',
        alpha=0.5,
        rwidth=0.9,
    )
    ax2.set_ylabel('probability')
    if xbounds:
        ax2.set_xlim(xbounds[0], xbounds[1])
    if ybounds:
        ax2.set_ylim(ybounds[0], ybounds[1])
    ax2.legend()
    ax2.set_title('')
    
    title = calendar.month_name[month] if month else 'all months'
    plt.suptitle(title)
    plt.show()

    
def plot_quantiles_1d_point(
    da_hist_point,
    da_ref_point,
    da_target_point,
    da_qq_point,
    quantiles,
    xbounds=None,
    month=None
):
    """Plot 1D quantiles comparisons"""
    
    hist_point = da_hist_point.copy()
    ref_point = da_ref_point.copy()
    target_point = da_target_point.copy()
    qq_point = da_qq_point.copy()
    if month:
        hist_point = hist_point[hist_point['time'].dt.month == month]
        ref_point = ref_point[ref_point['time'].dt.month == month]
        target_point = target_point[target_point['time'].dt.month == month]
        qq_point = qq_point[qq_point['time'].dt.month == month]
    
    hist_q_point = utils.get_quantiles(hist_point, quantiles, timescale='annual')
    ref_q_point = utils.get_quantiles(ref_point, quantiles, timescale='annual')
    target_q_point = utils.get_quantiles(target_point, quantiles, timescale='annual')
    qq_q_point = utils.get_quantiles(qq_point, quantiles, timescale='annual')
    
    fig = plt.figure(figsize=[15, 5])
    ax1 = fig.add_subplot(121)
    ax2 = fig.add_subplot(122)

    target_data = target_q_point.values
    qq_data = qq_q_point.values
    hist_data = hist_q_point.values
    ref_data = ref_q_point.values

    width = 80 / len(hist_q_point)
    ax1.bar(quantiles * 100, hist_data, alpha=0.5, width=width, label='historical')
    ax1.bar(quantiles * 100, ref_data, alpha=0.5, width=width, label='reference')
    ax2.bar(quantiles * 100, target_data, alpha=0.5, width=width, label='target')
    ax2.bar(quantiles * 100, qq_data, alpha=0.5, width=width, label='qq-scaled data')

    ylabel = f"""{da_target_point.attrs['long_name']} ({da_target_point.attrs['units']})"""

    data_min = np.min(np.concatenate([target_data, qq_data, hist_data, ref_data]))
    ymin = data_min - 1 if (data_min < 0) else 0
    ymax = np.max(np.concatenate([target_data, qq_data, hist_data, ref_data])) + 1
    if xbounds:
        ax1.set_xlim(xbounds[0], xbounds[1])
    ax1.set_ylim(ymin, ymax)
    ax1.grid()
    ax1.legend()
    ax1.set_ylabel(ylabel)
    ax1.set_xlabel('quantile')

    if xbounds:
        ax2.set_xlim(xbounds[0], xbounds[1])
    ax2.set_ylim(ymin, ymax)
    ax2.grid()
    ax2.legend()
    ax2.set_xlabel('quantile')

    title = calendar.month_name[month] if month else 'all months'
    plt.suptitle(f'quantiles - {title}')
    plt.show()


def plot_values_1d_point(
    da_hist_point,
    da_ref_point,
    da_target_point,
    da_qq_point,
    scaling,
    n_values=50,
    month=None
):
    """Plot 1D values comparisons"""
    
    hist_point = da_hist_point.copy()
    ref_point = da_ref_point.copy()
    target_point = da_target_point.copy()
    qq_point = da_qq_point.copy()
    assert len(target_point) == len(qq_point), "1D values plot only works if length of target and qq are the same"
    qq_point['time'] = target_point['time']
    if month:
        hist_point = hist_point[hist_point['time'].dt.month == month]
        ref_point = ref_point[ref_point['time'].dt.month == month]
        target_point = target_point[target_point['time'].dt.month == month]
        qq_point = qq_point[qq_point['time'].dt.month == month]

    hist_point_sorted = np.sort(hist_point.values) 
    ref_point_sorted = np.sort(ref_point.values)
    target_args = np.argsort(target_point.values)
    target_point_sorted = target_point[target_args].values
    qq_point_sorted = qq_point[target_args].values
    if scaling == 'multiplicative':
        adjustments = qq_point_sorted / target_point_sorted
    else:
        adjustments = qq_point_sorted - target_point_sorted

    fig = plt.figure(figsize=[15, 5])
    ax1a = fig.add_subplot(121)
    ax2a = fig.add_subplot(122)

    all_data = np.concatenate([
        hist_point_sorted, ref_point_sorted, target_point_sorted, qq_point_sorted
    ])
    ymax = np.max(all_data) + 5
    ylabel = f"""{da_target_point.attrs['long_name']} ({da_target_point.attrs['units']})"""

    xvals = np.arange(len(target_point)) + 1
    ax1a.stem(xvals[-n_values:], hist_point_sorted[-n_values:], label='hist', markerfmt='bo', linefmt='--')
    ax1a.stem(xvals[-n_values:], ref_point_sorted[-n_values:], label='ref', markerfmt='go', linefmt='--')
    ax1a.set_ylabel(ylabel)
    ax1a.set_xlabel('rank')
    ax1a.set_ylim([-5, ymax])
    ax1a.legend(loc='center left')
    ax1a.grid()
    ax1b = ax1a.twinx()
    ax1b.plot(xvals[-n_values:], adjustments[-n_values:], color='tab:grey', linestyle=':', label='adjustment_factor')
    ax1b.set_ylabel('adjustment factor')
    ax1b.legend(loc='upper left')

    xvals = np.arange(len(target_point_sorted)) + 1
    ax2a.stem(xvals[-n_values:], target_point_sorted[-n_values:], label='target', markerfmt='bo', linefmt='--')
    ax2a.stem(xvals[-n_values:], qq_point_sorted[-n_values:], label='qq', markerfmt='go', linefmt='--')
    ax2a.set_xlabel('rank (target)')
    ax2a.set_ylim([-5, ymax])
    ax2a.legend(loc='center left')
    ax2a.grid()
    ax2b = ax2a.twinx()
    ax2b.plot(xvals[-n_values:], adjustments[-n_values:], color='tab:grey', linestyle=':', label='adjustment_factor')
    ax2b.set_ylabel('adjustment factor')
    ax2b.legend(loc='upper left')

    title = calendar.month_name[month] if month else 'all months'
    plt.suptitle(f'highest values - {title}')
    plt.show()


def plot_seasonal_cycle(
    da_hist_point,
    da_ref_point,
    da_target_point,
    da_qq_point,
):
    """Plot seasonal cycle"""

    point_data = {}
    point_data['hist'] = da_hist_point.copy()
    point_data['ref'] = da_ref_point.copy()
    point_data['target'] = da_target_point.copy()
    point_data['qq'] = da_qq_point.copy()

    xticks = np.arange(1, 13)
    xtick_labels = [calendar.month_abbr[i] for i in xticks]

    fig = plt.figure(figsize=[15, 10])
    for label in ['hist', 'ref', 'target', 'qq']:
        da_point = point_data[label]
        monthly_means = da_point.groupby('time.month').mean('time')
        plt.plot(xticks, monthly_means, label=label, linestyle=linestyles[label], marker='o')

    plt.title('Monthly climatology')
    plt.legend()
    units = da_hist_point.attrs['units']
    plt.ylabel(f'monthly mean ({units})')
    plt.xticks(xticks, xtick_labels)
    plt.grid()
    plt.show()


def plot_seasonal_totals(
    da_hist_point,
    da_ref_point,
    da_target_point,
    da_qq_point,
    time_agg='mean',
):
    """Plot rainfall seasonal cycle"""

    point_data = {}
    point_data['hist'] = da_hist_point.copy()
    point_data['ref'] = da_ref_point.copy()
    point_data['target'] = da_target_point.copy()
    point_data['qq'] = da_qq_point.copy()

    xticks = np.arange(1, 13)
    xtick_labels = [calendar.month_abbr[i] for i in xticks]

    fig = plt.figure(figsize=[15, 10])
    for label in ['hist', 'ref', 'target', 'qq']:
        da_point = point_data[label]
        if time_agg == 'pct_total':
            annual_total = da_point.data.sum()
            monthly_totals = da_point.groupby('time.month').sum('time')
            monthly_values = (monthly_totals.values / annual_total) * 100
            ylabel = '% of annual total'
        elif time_agg == 'mean':
            monthly_values = da_point.groupby('time.month').mean('time')
            ylabel = da_hist_point.attrs['units'] 
        plt.plot(xticks, monthly_values, label=label, linestyle=linestyles[label], marker='o')

    plt.title('Climatology')
    plt.legend()
    plt.ylabel(ylabel)
    plt.xticks(xticks, xtick_labels)
    plt.grid()
    plt.show()


def single_point_analysis(
    da_hist,
    da_ref,
    da_target,
    da_qq,
    ds_adjust,
    variable,
    scaling,
    city,
    lat,
    lon,
    general_cmap,
    af_cmap,
    general_levels,
    af_levels,
    pdf_xbounds=None,
    pdf_ybounds=None,
    q_xbounds=None,
    n_values=50,
    months=[],
    seasonal_agg='mean',
    plot_2d_quantiles=True,
    plot_1d_quantiles=True,
    plot_1d_values=True,
    plot_pdfs=True,
):
    """Plots for a single grid point"""
    
    point_selection = {'lat': lat, 'lon': lon}
    da_hist_point = da_hist.sel(point_selection, method='nearest')
    da_ref_point = da_ref.sel(point_selection, method='nearest')
    da_target_point = da_target.sel(point_selection, method='nearest')
    da_qq_point = da_qq.sel(point_selection, method='nearest')
    ds_adjust_point = ds_adjust.sel(point_selection, method='nearest')
    quantiles = ds_adjust['quantiles'].data
    
    print(city.upper())
    
    if plot_2d_quantiles:
        plot_quantiles_2d_point(
            ds_adjust_point['hist_q'],
            da_ref_point,
            da_target_point,
            ds_adjust_point['af'],
            variable,
            quantiles,
            general_cmap,
            af_cmap,
            general_levels,
            af_levels,
        )

    if 'pr' in variable:
        plot_seasonal_totals(
            da_hist_point,
            da_ref_point,
            da_target_point,
            da_qq_point,
        )
    else:
        plot_seasonal_cycle(
            da_hist_point,
            da_ref_point,
            da_target_point,
            da_qq_point,
        )

    if plot_1d_quantiles:
        plot_quantiles_1d_point(
            da_hist_point,
            da_ref_point,
            da_target_point,
            da_qq_point,
            quantiles,
            xbounds=q_xbounds
        )
        for month in months:
            plot_quantiles_1d_point(
                da_hist_point,
                da_ref_point,
                da_target_point,
                da_qq_point,
                quantiles,
                month=month,
                xbounds=q_xbounds,
            )

    if plot_1d_values:
        plot_values_1d_point(
            da_hist_point,
            da_ref_point,
            da_target_point,
            da_qq_point,
            scaling,
            n_values=n_values
        )
        for month in months:
            plot_values_1d_point(
                da_hist_point,
                da_ref_point,
                da_target_point,
                da_qq_point,
                scaling,
                month=month,
                n_values=n_values,
            )

    if plot_pdfs:
        plot_pdfs_point(
            da_hist_point,
            da_ref_point,
            da_target_point,
            da_qq_point,
            xbounds=pdf_xbounds,
            ybounds=pdf_ybounds,
        )
        for month in months:
            plot_pdfs_point(
                da_hist_point,
                da_ref_point,
                da_target_point,
                da_qq_point,
                month=month,
                xbounds=pdf_xbounds,
                ybounds=pdf_ybounds,
        )
