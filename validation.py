import calendar
import sys

import geopandas as gp
from clisops.core.subset import subset_shape
import matplotlib.pyplot as plt
import numpy as np
import cartopy.crs as ccrs
import cartopy
import xesmf as xe
from xskillscore import pearson_r
import cmdline_provenance as cmdprov

sys.path.append('/g/data/xv83/quantile-mapping/qqscale')
import utils


linestyles = {
    'hist': 'solid',
    'ref': 'solid',
    'target': 'dotted',
    'qq': 'dotted',
    'qq-cmatch': 'dotted',
}


def calc_seasonal_change_diff(da_hist, da_ref, da_target, da_qq, scaling):
    """Calculate difference in seasonal change."""

    hist_monthly_clim = da_hist.groupby('time.month').mean('time')
    ref_monthly_clim = da_ref.groupby('time.month').mean('time')
    target_monthly_clim = da_target.groupby('time.month').mean('time')
    qq_monthly_clim = da_qq.groupby('time.month').mean('time')

    if scaling == 'additive':
        model_change = ref_monthly_clim - hist_monthly_clim
        qq_change = qq_monthly_clim - target_monthly_clim
        units = da_hist.attrs['units']
    elif scaling == 'multiplicative':
        model_change = ((ref_monthly_clim - hist_monthly_clim) / hist_monthly_clim) * 100
        qq_change = ((qq_monthly_clim - target_monthly_clim) / target_monthly_clim) * 100
        units = '%'

    qq_change, model_change = match_grids(qq_change, model_change)
    diffs = np.abs(qq_change - model_change)
    mean_diff = diffs.mean(dim='month').compute()
    mean_diff.attrs['units'] = units
    
    return mean_diff


def plot_seasonal_change_diff(
    seasonal_diff,
    land_only=False,
    city_lat_lon={},
    outfile=None,
    levels=None,
):
    """Plot difference in seasonal change"""
 
    if land_only:
        shape = gp.read_file('/g/data/ia39/aus-ref-clim-data-nci/shapefiles/data/australia/australia.shp')
        seasonal_diff = subset_shape(seasonal_diff, shape=shape)

    fig = plt.figure(figsize=[10, 5])
    ax = fig.add_subplot(111, projection=ccrs.PlateCarree(central_longitude=180))

    units = seasonal_diff.attrs['units']
    seasonal_diff.plot(
        ax=ax,
        transform=ccrs.PlateCarree(),
        cmap='Oranges',
        cbar_kwargs={'label': f'average magnitude of monthly difference ({units})'},
        levels=levels,
        extend='max',
    )
    ax.set_title('difference in monthly change (model vs. qq)')
    ax.coastlines()
    ax.add_feature(cartopy.feature.STATES)
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
    ax.set_extent([xmin, xmax, ymin, ymax], crs=ccrs.PlateCarree())
    
    if outfile:
        plt.savefig(outfile, bbox_inches='tight', facecolor='white', dpi=300)
    else:
        plt.show()


def plot_monthly_change_sign_agreement(
    da_before,
    da_after,
    land_only=False,
    city_lat_lon={},
    outfile=None,
):
    """Plot monthly change sign agreement.

    Image shows number of months where the
    climatological mean increases.
    """

    before_monthly_clim = da_before.groupby('time.month').mean('time')
    after_monthly_clim = da_after.groupby('time.month').mean('time')
    change = after_monthly_clim - before_monthly_clim
    increase = change > 0
    count = increase.sum(dim='month')

    if land_only:
        shape = gp.read_file('/g/data/ia39/aus-ref-clim-data-nci/shapefiles/data/australia/australia.shp')
        count = subset_shape(count, shape=shape)

    fig = plt.figure(figsize=[10, 5])
    ax = fig.add_subplot(111, projection=ccrs.PlateCarree(central_longitude=180))

    cax = count.plot(
        ax=ax,
        transform=ccrs.PlateCarree(),
        levels=[-0.5, 0.5, 1.5, 2.5, 3.5, 4.5, 5.5, 6.5, 7.5, 8.5, 9.5, 10.5, 11.5, 12.5],
        add_colorbar=False,
    )
    fig.colorbar(
        cax,
        ticks=[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
        label='number of months',
    ) 

    ax.set_title('Number of months where the climatological mean increases')
    ax.coastlines()
    ax.add_feature(cartopy.feature.STATES)
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
    ax.set_extent([xmin, xmax, ymin, ymax], crs=ccrs.PlateCarree())
    
    if outfile:
        plt.savefig(outfile, bbox_inches='tight', facecolor='white', dpi=300)
    else:
        plt.show()



def monthly_annual_pct(ds, var):
    """Monthly mean precip expressed as a percentage of the annual mean."""
    
    da_monthly_mean = ds[var].groupby('time.month').mean('time')
    da_annual = ds[var].resample(time='Y').sum()
    da_annual_mean = da_annual.mean('time')
    da_monthly_annual_pct = (da_monthly_mean / da_annual_mean) * 100
    da_monthly_annual_pct = da_monthly_annual_pct.compute()

    return da_monthly_annual_pct

    
def calc_seasonal_correlation(ds_target, var_target, ds_qq, var_qq):
    """Calculate correlation between model and obs monthly climatology"""

    if 'pr' in [var_target, var_qq]:
        target_monthly_clim = monthly_annual_pct(ds_target, var_target)
        qq_monthly_clim = monthly_annual_pct(ds_qq, var_qq)
    else:
        target_monthly_clim = ds_target[var_target].groupby('time.month').mean('time')
        target_monthly_clim = target_monthly_clim.compute()
        qq_monthly_clim = ds_qq[var_qq].groupby('time.month').mean('time')
        qq_monthly_clim = qq_monthly_clim.compute()

    seasonal_r = pearson_r(target_monthly_clim, qq_monthly_clim, 'month')
    seasonal_r = seasonal_r.compute()
    
    return seasonal_r


def plot_seasonal_correlation(
    seasonal_r,
    land_only=False,
    city_lat_lon={},
    outfile=None,
):
    """Plot the correlation between model and obs monthly climatology"""
 
    if land_only:
        shape = gp.read_file('/g/data/ia39/aus-ref-clim-data-nci/shapefiles/data/australia/australia.shp')
        seasonal_r = subset_shape(seasonal_r, shape=shape)

    fig = plt.figure(figsize=[10, 5])
    ax = fig.add_subplot(111, projection=ccrs.PlateCarree(central_longitude=180))

    seasonal_r.plot(
        ax=ax,
        transform=ccrs.PlateCarree(),
        cmap='RdBu_r',
        cbar_kwargs={'label': 'correlation'},
        levels=[-1.0, -0.8, -0.6, -0.4, -0.2, 0, 0.2, 0.4, 0.6, 0.8, 1.0],
    )
    ax.set_title('seasonal cycle correlation (target vs. qq)')
    ax.coastlines()
    ax.add_feature(cartopy.feature.STATES)
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
    ax.set_extent([xmin, xmax, ymin, ymax], crs=ccrs.PlateCarree())
    
    if outfile:
        plt.savefig(outfile, bbox_inches='tight', facecolor='white', dpi=300)
    else:
        plt.show()


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
    
    if quantiles.ndim == 1:
        quantiles = quantiles.expand_dims(dim={'month': 1})
        input_ndims = 1
    else:
        assert quantiles.ndim == 2
        input_ndims = 2

    quantiles.transpose('month', 'quantiles').plot.imshow(
        ax=ax,
        cmap=cmap,
        extend=extend,
        **kwargs
    )
    
    if input_ndims == 1:
        ax.set_yticks([1], [])
        ax.set_ylabel('')
        ax.set_xlabel('')
    else:
        yticks = np.arange(1,13)
        ytick_labels = [calendar.month_abbr[i] for i in yticks]
        ax.set_yticks(yticks, ytick_labels)
        ax.invert_yaxis()
    if title:
        ax.set_title(title)


def match_grids(primary_da, secondary_da):
    """Match grids (to the highest resolution)"""

    da1 = primary_da.copy()
    da2 = secondary_da.copy()

    if len(da1['lat']) > len(da2['lat']):
        regridder = xe.Regridder(da2, da1, "bilinear")
        da2 = regridder(da2)
        da2 = da2.compute()
    elif len(da1['lat']) < len(da2['lat']):
        regridder = xe.Regridder(da1, da2, "bilinear")
        da1 = regridder(da1)
        da1 = da1.compute()

    return da1, da2


def spatial_comparison_data(da1, da2, scaling):
    """Compare two spatial fields."""
    
    global_attrs = da1.attrs
    primary_da, secondary_da = match_grids(da1, da2)

    if scaling == 'additive':
        comparison = primary_da - secondary_da
    elif scaling == 'multiplicative':
        comparison = ((primary_da - secondary_da) / secondary_da) * 100
        
    comparison.attrs = global_attrs
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
    print_mav=False,
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
    if print_mav:
        mav = np.nanmean(np.abs(da_comp))
        print(f'mean absolute value: {mav:.2f} ')
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
    
    if da_hist_q_point.ndim == 1:
        timescale = 'annual'
        height = 14
    else:
        timescale = 'monthly'
        height = 24
    da_ref_q_point = utils.get_quantiles(da_ref_point, quantiles, timescale=timescale)
    da_target_q_point = utils.get_quantiles(da_target_point, quantiles, timescale=timescale)
    extend = 'max' if 'pr' in variable else 'both'

    fig = plt.figure(figsize=[20, height])
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
    da_qq_cmatch_point=None,
    xbounds=None,
    month=None
):
    """Plot 1D quantiles comparisons"""
    
    hist_point = da_hist_point.copy()
    ref_point = da_ref_point.copy()
    target_point = da_target_point.copy()
    qq_point = da_qq_point.copy()
    if da_qq_cmatch_point is not None:
        qq_cmatch_point = da_qq_cmatch_point.copy()
    if month:
        hist_point = hist_point[hist_point['time'].dt.month == month]
        ref_point = ref_point[ref_point['time'].dt.month == month]
        target_point = target_point[target_point['time'].dt.month == month]
        qq_point = qq_point[qq_point['time'].dt.month == month]
        if da_qq_cmatch_point is not None:
            qq_cmatch_point = qq_cmatch_point[qq_cmatch_point['time'].dt.month == month]

    hist_q_point = utils.get_quantiles(hist_point, quantiles, timescale='annual')
    ref_q_point = utils.get_quantiles(ref_point, quantiles, timescale='annual')
    target_q_point = utils.get_quantiles(target_point, quantiles, timescale='annual')
    qq_q_point = utils.get_quantiles(qq_point, quantiles, timescale='annual')
    if da_qq_cmatch_point is not None:
       qq_cmatch_q_point = utils.get_quantiles(qq_cmatch_point, quantiles, timescale='annual') 
    
    fig = plt.figure(figsize=[15, 5])
    ax1 = fig.add_subplot(121)
    ax2 = fig.add_subplot(122)

    target_data = target_q_point.values
    qq_data = qq_q_point.values
    hist_data = hist_q_point.values
    ref_data = ref_q_point.values
    if da_qq_cmatch_point is not None:
        qq_cmatch_data = qq_cmatch_q_point.values

    width = 80 / len(hist_q_point)
    ax1.bar(quantiles * 100, hist_data, alpha=0.5, width=width, label='historical')
    ax1.bar(quantiles * 100, ref_data, alpha=0.5, width=width, label='reference')
    ax2.bar(quantiles * 100, target_data, alpha=0.5, width=width, label='target')
    ax2.bar(quantiles * 100, qq_data, alpha=0.5, width=width, label='qq-scaled data')
    if da_qq_cmatch_point is not None:
        ax2.bar(quantiles * 100, qq_cmatch_data, alpha=0.5, width=width, label='qq-scaled cmatch data')

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
    extremes='max',
    month=None
):
    """Plot 1D values comparisons."""
    
    assert extremes in ['min', 'max']

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

    ylabel = f"""{da_target_point.attrs['long_name']} ({da_target_point.attrs['units']})"""

    xvals1 = np.arange(len(target_point)) + 1
    xvals2 = np.arange(len(target_point_sorted)) + 1

    if extremes == 'max':
        plot_xvals1 = xvals1[-n_values:]
        plot_xvals2 = xvals2[-n_values:]     
        plot_hist = hist_point_sorted[-n_values:]
        plot_ref = ref_point_sorted[-n_values:]
        plot_adjustments = adjustments[-n_values:]
        plot_target = target_point_sorted[-n_values:]
        plot_qq = qq_point_sorted[-n_values:]
    elif extremes == 'min':
        plot_xvals1 = xvals1[0:n_values]
        plot_xvals2 = xvals2[0:n_values]     
        plot_hist = hist_point_sorted[0:n_values]
        plot_ref = ref_point_sorted[0:n_values]
        plot_adjustments = adjustments[0:n_values]
        plot_target = target_point_sorted[0:n_values]
        plot_qq = qq_point_sorted[0:n_values]

    all_data = np.concatenate([plot_hist, plot_ref, plot_target, plot_qq])
    ymax = np.max(all_data) + 5

    ax1a.stem(plot_xvals1, plot_hist, label='hist', markerfmt='bo', linefmt='--')
    ax1a.stem(plot_xvals1, plot_ref, label='ref', markerfmt='go', linefmt='--')
    ax1a.set_ylabel(ylabel)
    ax1a.set_xlabel('rank')
    ax1a.set_ylim([-5, ymax])
    ax1a.legend(loc='center left')
    ax1a.grid()
    ax1b = ax1a.twinx()
    ax1b.plot(plot_xvals1, plot_adjustments, color='tab:grey', linestyle=':', label='adjustment_factor')
    ax1b.set_ylabel('adjustment factor')
    ax1b.legend(loc='upper left')

    ax2a.stem(plot_xvals2, plot_target, label='target', markerfmt='bo', linefmt='--')
    ax2a.stem(plot_xvals2, plot_qq, label='qq', markerfmt='go', linefmt='--')
    ax2a.set_xlabel('rank (target)')
    ax2a.set_ylim([-5, ymax])
    ax2a.legend(loc='center left')
    ax2a.grid()
    ax2b = ax2a.twinx()
    ax2b.plot(plot_xvals2, plot_adjustments, color='tab:grey', linestyle=':', label='adjustment_factor')
    ax2b.set_ylabel('adjustment factor')
    ax2b.legend(loc='upper left')

    title = calendar.month_name[month] if month else 'all months'
    plt.suptitle(f'highest values - {title}')
    plt.show()


def plot_seasonal_change(
    da_hist_point,
    da_ref_point,
    da_target_point,
    da_qq_point,
    scaling,
):
    """Plot seasonal change"""

    hist_monthly_clim = da_hist_point.groupby('time.month').mean('time')
    ref_monthly_clim = da_ref_point.groupby('time.month').mean('time')
    target_monthly_clim = da_target_point.groupby('time.month').mean('time')
    qq_monthly_clim = da_qq_point.groupby('time.month').mean('time')

    if scaling == 'additive':
        model_change = ref_monthly_clim - hist_monthly_clim
        qq_change = qq_monthly_clim - target_monthly_clim
        units = da_hist_point.attrs['units']
    elif scaling == 'multiplicative':
        model_change = ((ref_monthly_clim - hist_monthly_clim) / hist_monthly_clim) * 100
        qq_change = ((qq_monthly_clim - target_monthly_clim) / target_monthly_clim) * 100
        units = '%'

    xticks = np.arange(1, 13)
    xtick_labels = [calendar.month_abbr[i] for i in xticks]

    fig = plt.figure(figsize=[15, 10])
    ax = fig.add_subplot(111)
    
    ax.bar(xticks, qq_change, alpha=0.5, label='qq data')
    ax.bar(xticks, model_change, alpha=0.5, label='model data')
    ax.set_title('Monthly change')
    ax.legend()
    ax.set_ylabel(f'Change ({units})')
    ax.set_xticks(xticks, xtick_labels)
    ax.grid()
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
    da_qq_cmatch_point=None,
    time_agg='mean',
):
    """Plot rainfall seasonal cycle"""

    labels = ['hist', 'ref', 'target', 'qq']
    point_data = {}
    point_data['hist'] = da_hist_point.copy()
    point_data['ref'] = da_ref_point.copy()
    point_data['target'] = da_target_point.copy()
    point_data['qq'] = da_qq_point.copy()
    if da_qq_cmatch_point is not None:
        point_data['qq-cmatch'] = da_qq_cmatch_point.copy()
        labels.append('qq-cmatch')

    xticks = np.arange(1, 13)
    xtick_labels = [calendar.month_abbr[i] for i in xticks]

    fig = plt.figure(figsize=[15, 10])
    for label in labels:
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


def plot_clipped(da_qq_point, da_qq_clipped_point):
    """Plot first year of clipped data"""

    fig = plt.figure(figsize=[15, 10])
    da_qq_point[0:365].plot(color='tab:orange', label='QQ data')
    da_qq_clipped_point[0:365].plot(color='tab:blue', label='QQ clipped data')
    plt.title('Clipping check - first year of daily data')
    plt.legend()
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
    da_qq_clipped=None,
    da_qq_cmatch=None,
    pdf_xbounds=None,
    pdf_ybounds=None,
    q_xbounds=None,
    n_values=50,
    months=[],
    seasonal_agg='mean',
    extreme_for_values='max',
    plot_1d_quantiles=True,
    plot_1d_values=True,
    plot_pdfs=True,
):
    """Plots for a single grid point"""
    
    point_selection = {'lat': lat, 'lon': lon}
    da_hist_point = da_hist.sel(point_selection, method='nearest').compute()
    da_ref_point = da_ref.sel(point_selection, method='nearest').compute()
    da_target_point = da_target.sel(point_selection, method='nearest').compute()
    da_qq_point = da_qq.sel(point_selection, method='nearest').compute()
    if da_qq_clipped is not None:
        da_qq_clipped_point = da_qq_clipped.sel(point_selection, method='nearest').compute()
    if da_qq_cmatch is not None:
        da_qq_cmatch_point = da_qq_cmatch.sel(point_selection, method='nearest').compute()
    else:
        da_qq_cmatch_point = None
    ds_adjust_point = ds_adjust.sel(point_selection, method='nearest').compute()
    quantiles = ds_adjust['quantiles'].data
    
    print(city.upper())
    
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
            da_qq_cmatch_point=da_qq_cmatch_point,
        )
    else:
        plot_seasonal_cycle(
            da_hist_point,
            da_ref_point,
            da_target_point,
            da_qq_point,
        )
    plot_seasonal_change(
        da_hist_point,
        da_ref_point,
        da_target_point,
        da_qq_point,
        scaling,
    )
    if plot_1d_quantiles:
        plot_quantiles_1d_point(
            da_hist_point,
            da_ref_point,
            da_target_point,
            da_qq_point,
            quantiles,
            da_qq_cmatch_point=da_qq_cmatch_point,
            xbounds=q_xbounds
        )
        for month in months:
            plot_quantiles_1d_point(
                da_hist_point,
                da_ref_point,
                da_target_point,
                da_qq_point,
                quantiles,
                da_qq_cmatch_point=da_qq_cmatch_point,
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
            extremes=extreme_for_values,
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
                extremes=extreme_for_values,
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

    if da_qq_clipped is not None:
        plot_clipped(da_qq_point, da_qq_clipped_point)
        
