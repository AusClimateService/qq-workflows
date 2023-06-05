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


def projection_spatial_data(da_hist, da_ref, da_target, da_qq, scaling):
    """Get data for projection spatial plot."""
    
    hist_clim = da_hist.mean('time', keep_attrs=True)
    ref_clim = da_ref.mean('time', keep_attrs=True)
    target_clim = da_target.mean('time', keep_attrs=True)
    qq_clim = da_qq.mean('time', keep_attrs=True)
    
    if scaling == 'additive':
        ref_hist_mean_comparison = ref_clim - hist_clim
    elif scaling == 'multiplicative':
        ref_hist_mean_comparison = (ref_clim / hist_clim) * 100
    ref_hist_mean_comparison = ref_hist_mean_comparison.compute()
    
    if scaling == 'additive':
        qq_obs_mean_comparison = qq_clim - target_clim
    elif scaling == 'multiplicative':
        qq_obs_mean_comparison = (qq_clim / target_clim) * 100
    qq_obs_mean_comparison = qq_obs_mean_comparison.compute()
    
    regridder = xe.Regridder(ref_hist_mean_comparison, qq_obs_mean_comparison, "bilinear")
    ref_hist_mean_comparison = regridder(ref_hist_mean_comparison)
    
    return ref_hist_mean_comparison, qq_obs_mean_comparison 


def projection_spatial_plot(
    ref_hist_mean_comparison,
    qq_obs_mean_comparison,
    cmap,
    comparison_levels,
    diff_levels,
    city_lat_lon={}
):
    """Spatial plot of GCM projections, QQ-projections and difference."""
    
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

    plt.show()


def plot_quantiles_2d_point(da_hist_q_point, da_ref_point, da_target_point, quantiles, cmap, levels):
    """Plot historical, reference and target quantiles for a single grid point."""
    
    da_ref_q_point = utils.get_quantiles(da_ref_point, quantiles, timescale='monthly')
    da_target_q_point = utils.get_quantiles(da_target_point, quantiles, timescale='monthly')
    
    fig = plt.figure(figsize=[20, 17])
    ax1 = fig.add_subplot(311)
    ax2 = fig.add_subplot(312)
    ax3 = fig.add_subplot(313)
    
    quantile_month_plot(
        da_ref_q_point,
        ax1,
        cmap,
        levels,
        title='reference',
        extend='max',
    )
    quantile_month_plot(
        da_hist_q_point,
        ax2,
        cmap,
        levels,
        title='historical',
        extend='max',
    )
    quantile_month_plot(
        da_target_q_point,
        ax3,
        cmap,
        levels,
        title='target (obs)',
        extend='max',
    )
    plt.show()


def plot_af_point(da_af_point, cmap, levels):
    """Plot adjustment factors for a single grid point"""
    
    fig = plt.figure(figsize=[12, 5])
    ax1 = fig.add_subplot(111)

    quantile_month_plot(
        da_af_point,
        ax1,
        cmap,
        levels,
        title='adjustment factors'
    )
    plt.show()
    

def plot_pdfs_point(
    da_hist_point, da_ref_point, da_target_point, da_qq_point, xbounds=None, ybounds=None, month=None
):
    """Plot observed, historical and qq-scaled PDFs for a single grid point"""

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
    ax1 = fig.add_subplot(122)
    ax2 = fig.add_subplot(121)
    bins = np.arange(0, 150, 1)
    target_point.plot.hist(
        ax=ax1,
        bins=bins,
        density=True,
        label='observations',
        facecolor='tab:green',
        alpha=0.5,
        rwidth=0.9,
    )
    hist_point.plot.hist(
        ax=ax1,
        bins=bins,
        density=True,
        label='histotical data',
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
        label='observations',
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
    ax1 = fig.add_subplot(122)
    ax2 = fig.add_subplot(121)

    obs_data = target_q_point.values
    qq_data = qq_q_point.values
    hist_data = hist_q_point.values
    future_data = ref_q_point.values

    ax1.bar(quantiles * 100, obs_data, alpha=0.5, label='observations')
    ax1.bar(quantiles * 100, qq_data, alpha=0.5, label='qq-scaled data')
    ax2.bar(quantiles * 100, hist_data, alpha=0.5, label='historical')
    ax2.bar(quantiles * 100, future_data, alpha=0.5, label='ssp370')

    ylabel = f"""{da_target_point.attrs['long_name']} ({da_target_point.attrs['units']})"""

    ymax = np.max(np.concatenate([obs_data, qq_data, hist_data, future_data])) + 1
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


def single_point_analysis(
    da_hist,
    da_ref,
    da_target,
    da_qq,
    ds_adjust,
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
    months=[]
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
    
    #plot_quantiles_2d_point(
    #    ds_adjust_point['hist_q'],
    #    da_ref_point,
    #    da_target_point,
    #    quantiles,
    #    general_cmap,
    #    general_levels
    #)
    #plot_af_point(ds_adjust_point['af'], af_cmap, af_levels)
    
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
    