import calendar
import sys

import matplotlib.pyplot as plt
import numpy as np
import cartopy.crs as ccrs
import xesmf as xe
import cmdline_provenance as cmdprov
import dask
import dask.diagnostics

sys.path.append('/g/data/wp00/shared_code/qqscale')
import utils


#dask.diagnostics.ProgressBar().register()


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
    

def quantile_month_plot(quantiles, ax, cmap, levels, extend='both', point=None, title=None):
    """Create two dimensional month/quantile plot"""
            
    quantiles.transpose('month', 'quantiles').plot(ax=ax, cmap=cmap, extend=extend, levels=levels)
    
    yticks = np.arange(1,13)
    ytick_labels = [calendar.month_abbr[i] for i in yticks]
    ax.set_yticks(yticks, ytick_labels)
    ax.invert_yaxis()
    if title:
        ax.set_title(title)


def spatial_qdm_data(da_hist, da_ref, da_target, da_qq, scaling):
    """Get climatology data for QDM spatial plots."""

    hist_clim = da_hist.mean('time', keep_attrs=True)
    ref_clim = da_ref.mean('time', keep_attrs=True)
    target_clim = da_target.mean('time', keep_attrs=True)
    qq_clim = da_qq.mean('time', keep_attrs=True)
    hist_attrs = hist_clim.attrs
    
    if scaling == 'additive':
        ref_hist_comparison = ref_clim - hist_clim
    elif scaling == 'multiplicative':
        ref_hist_comparison = ((ref_clim - hist_clim) / hist_clim) * 100
    ref_hist_comparison = ref_hist_comparison.compute()
    
    if scaling == 'additive':
        qq_obs_comparison = qq_clim - target_clim
    elif scaling == 'multiplicative':
        qq_obs_comparison = ((qq_clim - target_clim) / target_clim) * 100
    qq_obs_comparison = qq_obs_comparison.compute()
    
    regridder = xe.Regridder(ref_hist_comparison, qq_obs_comparison, "bilinear")
    ref_hist_comparison = regridder(ref_hist_comparison)
    
    regridder = xe.Regridder(hist_clim, target_clim, "bilinear")
    hist_clim = regridder(hist_clim)
    
    ref_hist_comparison.attrs = hist_attrs
    qq_obs_comparison.attrs = hist_attrs
    if scaling == 'multiplicative':
        ref_hist_comparison.attrs['units'] = '% change'
        qq_obs_comparison.attrs['units'] = '% change'
    hist_clim = hist_clim.compute()
    target_clim = target_clim.compute()
    
    return hist_clim, target_clim, ref_hist_comparison, qq_obs_comparison 


def spatial_ecdfm_data(da_hist, da_ref, da_target, da_qq, scaling):
    """Get climatology data for eCDFm spatial plots."""

    hist_clim = da_hist.mean('time', keep_attrs=True).compute()
    ref_clim = da_ref.mean('time', keep_attrs=True).compute()
    target_clim = da_target.mean('time', keep_attrs=True).compute()
    qq_clim = da_qq.mean('time', keep_attrs=True).compute()
    hist_attrs = hist_clim.attrs
    
    regridder = xe.Regridder(hist_clim, ref_clim, "bilinear")
    hist_clim_regridded = regridder(hist_clim)
    
    regridder = xe.Regridder(target_clim, qq_clim, "bilinear")
    target_clim_regridded = regridder(target_clim)

    if scaling == 'additive':
        ref_hist_comparison = ref_clim - hist_clim_regridded
    elif scaling == 'multiplicative':
        ref_hist_comparison = ((ref_clim - hist_clim_regridded) / hist_clim_regridded) * 100
    ref_hist_comparison = ref_hist_comparison.compute()
    
    if scaling == 'additive':
        qq_target_comparison = qq_clim - target_clim_regridded
    elif scaling == 'multiplicative':
        qq_target_comparison = ((qq_clim - target_clim_regridded) / target_clim_regridded) * 100
    qq_target_comparison = qq_target_comparison.compute()
        
    ref_hist_comparison.attrs = hist_attrs
    qq_target_comparison.attrs = hist_attrs
    if scaling == 'multiplicative':
        ref_hist_comparison.attrs['units'] = '% change'
        qq_target_comparison.attrs['units'] = '% change'
    
    return hist_clim, target_clim, ref_hist_comparison, qq_obs_comparison 


def bias_spatial_plot(
    hist_agg,
    target_agg,
    agg_cmap,
    comparison_cmap,
    agg_levels,
    comparison_levels,
    agg='mean',
    mask=None,
    city_lat_lon={},
    comparison_method='difference'
):
    """Spatial plot of observed climatology, historical climatology and difference."""
    
    if mask is not None:
        hist_agg = hist_agg.where(mask)
        target_agg = target_agg.where(mask)

    if agg == 'mean':
        title_agg = 'climatology'
    elif agg == 'std':
        title_agg = 'standard deviation'    

    fig = plt.figure(figsize=[24, 6])

    ax1 = fig.add_subplot(131, projection=ccrs.PlateCarree())
    hist_agg.plot(
        ax=ax1,
        transform=ccrs.PlateCarree(),
        cmap=agg_cmap,
        levels=agg_levels,
        extend='max'
    )
    ax1.set_title(f'historical (model) {title_agg}')
    
    ax2 = fig.add_subplot(132, projection=ccrs.PlateCarree())
    target_agg.plot(
        ax=ax2,
        transform=ccrs.PlateCarree(),
        cmap=agg_cmap,
        levels=agg_levels,
        extend='max'
    )
    ax2.set_title(f'observed {title_agg}')

    if comparison_method == 'difference':
        comparison = hist_agg - target_agg
        title_op = '-'
    elif comparison_method == 'pct':
        comparison = ((hist_agg - target_agg) / target_agg) * 100
        title_op = '/'
    comparison.attrs = hist_agg.attrs
    ax3 = fig.add_subplot(133, projection=ccrs.PlateCarree())
    comparison.plot(
        ax=ax3,
        transform=ccrs.PlateCarree(),
        cmap=comparison_cmap,
        levels=comparison_levels,
        extend='both'
    )
    ax3.set_title(f'Comparison (historical {title_op} observed)')

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
    xmin, xmax = ax3.get_xlim()
    ymin, ymax = ax3.get_ylim()
    ax1.set_extent([xmin, xmax, ymin, ymax], crs=ccrs.PlateCarree())
    ax2.set_extent([xmin, xmax, ymin, ymax], crs=ccrs.PlateCarree())
    plt.suptitle(f'Model bias ({title_agg})')
    plt.show()


def projection_spatial_plot(
    ref_hist_mean_comparison,
    qq_obs_mean_comparison,
    cmap,
    comparison_levels,
    diff_levels,
    mask=None,
    city_lat_lon={}
):
    """Spatial plot of GCM projections, QQ-projections and difference."""
    
    if mask is not None:
        ref_hist_mean_comparison = ref_hist_mean_comparison.where(mask)
        qq_obs_mean_comparison = qq_obs_mean_comparison.where(mask)
    
    fig = plt.figure(figsize=[24, 6])

    ax1 = fig.add_subplot(131, projection=ccrs.PlateCarree())
    ref_hist_mean_comparison.plot(
        ax=ax1,
        transform=ccrs.PlateCarree(),
        cmap=cmap,
        levels=comparison_levels,
        extend='both'
    )
    ax1.set_title('ref - hist')

    ax2 = fig.add_subplot(132, projection=ccrs.PlateCarree())
    qq_obs_mean_comparison.plot(
        ax=ax2,
        transform=ccrs.PlateCarree(),
        cmap=cmap,
        levels=comparison_levels,
        extend='both'
    )
    ax2.set_title('QQ-scaled - original')

    difference = qq_obs_mean_comparison - ref_hist_mean_comparison
    ax3 = fig.add_subplot(133, projection=ccrs.PlateCarree())
    difference.plot(
        ax=ax3,
        transform=ccrs.PlateCarree(),
        cmap=cmap,
        levels=diff_levels,
        extend='both'
    )
    ax3.set_title('Difference')

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
    xmin, xmax = ax3.get_xlim()
    ymin, ymax = ax3.get_ylim()
    ax1.set_extent([xmin, xmax, ymin, ymax], crs=ccrs.PlateCarree())
    ax2.set_extent([xmin, xmax, ymin, ymax], crs=ccrs.PlateCarree())
    plt.suptitle('Projections')
    plt.show()


def plot_quantiles_2d_point(
    da_hist_q_point,
    da_ref_point,
    da_target_point,
    da_af_point,
    quantiles,
    general_cmap,
    af_cmap,
    diff_cmap,
    general_levels,
    af_levels,
    diff_levels,
):
    """Plot historical, reference and target quantiles for a single grid point."""
    
    da_ref_q_point = utils.get_quantiles(da_ref_point, quantiles, timescale='monthly')
    da_target_q_point = utils.get_quantiles(da_target_point, quantiles, timescale='monthly')
    
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
        extend='max',
    )
    da_hist_q_point.attrs = da_target_point.attrs
    quantile_month_plot(
        da_hist_q_point,
        ax2,
        general_cmap,
        general_levels,
        title='historical quantiles',
        extend='max',
    )
    da_target_q_point.attrs = da_target_point.attrs
    quantile_month_plot(
        da_target_q_point,
        ax3,
        general_cmap,
        general_levels,
        title='target quantiles',
        extend='max',
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
    bins = np.arange(0, 150, 1)
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

    ax1.bar(quantiles * 100, hist_data, alpha=0.5, label='historical')
    ax1.bar(quantiles * 100, ref_data, alpha=0.5, label='reference')
    ax2.bar(quantiles * 100, target_data, alpha=0.5, label='target')
    ax2.bar(quantiles * 100, qq_data, alpha=0.5, label='qq-scaled data')

    ylabel = f"""{da_target_point.attrs['long_name']} ({da_target_point.attrs['units']})"""

    ymax = np.max(np.concatenate([target_data, qq_data, hist_data, reference_data])) + 1
    if xbounds:
        ax1.set_xlim(xbounds[0], xbounds[1])
    ax1.set_ylim(0, ymax)
    ax1.grid()
    ax1.legend()
    ax1.set_xlabel('quantile')

    if xbounds:
        ax2.set_xlim(xbounds[0], xbounds[1])
    ax2.set_ylim(0, ymax)
    ax2.grid()
    ax2.legend()
    ax2.set_ylabel(ylabel)
    ax2.set_xlabel('quantile')

    title = calendar.month_name[month] if month else 'all months'
    plt.suptitle(f'quantiles - {title}')
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
        annual_mean = da_point.data.mean()
        monthly_anomalies = da_point.groupby('time.month').mean('time') - annual_mean
        plt.plot(xticks, monthly anomalies, label=label, marker='o')

    plt.title('Monthly climatology')
    plt.legend()
    plt.ylabel('monthly mean anomaly (vs annual mean)')
    plt.xticks(xticks, xtick_labels)
    plt.grid()
    plt.show()


def plot_seasonal_totals(
    da_hist_point,
    da_ref_point,
    da_target_point,
    da_qq_point,
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
        annual_total = da_point.data.sum()
        monthly_totals = da_point.groupby('time.month').sum('time')
        month_annual_pct = (monthly_totals.values / annual_total) * 100
        plt.plot(xticks, month_annual_pct, label=label, marker='o')

    plt.title('Rainfall climatology')
    plt.legend()
    plt.ylabel('% of annual total')
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
    city,
    lat,
    lon,
    general_cmap,
    af_cmap,
    diff_cmap,
    general_levels,
    af_levels,
    diff_levels,
    pdf_xbounds=None,
    pdf_ybounds=None,
    q_xbounds=None,
    months=[],
    plot_2d_quantiles=True,
    plot_1d_quantiles=True,
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
            quantiles,
            general_cmap,
            af_cmap,
            diff_cmap,
            general_levels,
            af_levels,
            diff_levels,
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
