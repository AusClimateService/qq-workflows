import calendar
import sys
import gc

import xarray as xr
from xclim import sdba
import matplotlib.pyplot as plt
import numpy as np
import cartopy.crs as ccrs
import xesmf as xe
import dask.diagnostics
import cmdline_provenance as cmdprov
import dask
import cmocean
import seaborn as sns
import pandas as pd

sys.path.append('/g/data/wp00/shared_code/qqscale')
import utils


plot_config = {}
plot_config['pct_change_levels'] = [64, 72, 80, 88, 96, 104, 112, 120, 128, 136]
plot_config['pct_diff_levels'] = [-14, -10, -6, -2, 2, 6, 10, 14]
if hist_var == 'tasmin':
    plot_config['regular_cmap'] = cmocean.cm.thermal
    plot_config['diverging_cmap'] = 'RdBu_r'
    plot_config['general_levels'] = [-1, 0.5, 2, 3.5, 5, 6.5, 8, 9.5, 11, 12.5, 14, 15.5, 17, 18.5, 20, 21.5]
    plot_config['af_levels'] = None
    plot_config['difference_levels'] = [0.6, 0.8, 1.0, 1.2, 1.4, 1.6, 1.8, 2.0]
elif hist_var == 'tasmax':
    plot_config['regular_cmap'] = cmocean.cm.thermal
    plot_config['diverging_cmap'] = 'RdBu_r'
    plot_config['general_levels'] = [5, 7.5, 10, 12.5, 15, 17.5, 20, 22.5, 25, 27.5, 30, 32.5, 35]
    plot_config['af_levels'] = None
    plot_config['difference_levels'] = [0.6, 0.8, 1.0, 1.2, 1.4, 1.6, 1.8, 2.0, 2.2]
elif hist_var == 'pr':
    plot_config['regular_cmap'] = cmocean.cm.rain
    plot_config['diverging_cmap'] = 'BrBG'
    plot_config['general_levels'] = [0, 0.01, 10, 20, 30, 40, 50, 60, 70, 80, 90]
    plot_config['af_levels'] = [0.125, 0.25, 0.5, 0.67, 0.8, 1, 1.25, 1.5, 2, 4, 8]
    plot_config['difference_levels'] = [-0.55, -0.45, -0.35, -0.25, -0.15, -0.05, 0.05, 0.15, 0.25, 0.35, 0.45, 0.55]
else:
    raise ValueError(f'No plotting configuration defined for {hist_var}')


def quantile_spatial_plot(
    da, month, cmap_type, lat_bounds=None, lon_bounds=None, levels=None,
):
    """Spatial plot of the 10th, 50th and 90th percentile"""
    
    da_selection = da.sel({'quantiles': [.1, .5, .9], 'month': month}, method='nearest')
    if lat_bounds:
        lat_min, lat_max = lat_bounds
        da_selection = da_selection.sel(lat=slice(lat_min, lat_max))
    if lon_bounds:
        lon_min, lon_max = lon_bounds
        da_selection = da_selection.sel(lon=slice(lon_min, lon_max))
        
    cmap = plot_config[f'{cmap_type}_cmap']
    kwargs = {}
    if levels:
        kwargs['levels'] = levels
    elif cmap_type == 'diverging':
        abs_max = np.max(np.abs(da_selection.values))
        vmax = abs_max
        vmin = -1 * abs_max
        kwargs['vmax'] = vmax
        kwargs['vmin'] = vmin
        
    p = da_selection.plot(
        col='quantiles',
        transform=ccrs.PlateCarree(),
        cmap=cmap,
        figsize=[20, 5.5],
        subplot_kws={'projection': ccrs.PlateCarree(),},
        **kwargs,
    )
    for ax in p.axes.flat:
        ax.coastlines()
    plt.suptitle(calendar.month_name[month])
    plt.show()
    

def quantile_month_plot(quantiles, ax, cmap_type, levels=None, extend='both', point=None, title=None):
    """Create two dimensional month/quantile plot"""
    
    assert cmap_type in ['regular', 'diverging']
    
    cmap = plot_config[f'{cmap_type}_cmap']
    kwargs = {}
    if levels:
        kwargs['levels'] = levels
    elif cmap_type == 'diverging':
        abs_max = np.max(np.abs(quantiles.values))
        vmax = abs_max
        vmin = -1 * abs_max
        kwargs['vmax'] = vmax
        kwargs['vmin'] = vmin
    
    quantiles.transpose('month', 'quantiles').plot(ax=ax, cmap=cmap, extend=extend, **kwargs)
    
    yticks = np.arange(1,13)
    ytick_labels = [calendar.month_abbr[i] for i in yticks]
    ax.set_yticks(yticks, ytick_labels)
    ax.invert_yaxis()
    if title:
        ax.set_title(title)

        
def projection_spatial_plot():
    """Spatial plot of GCM projections, QQ-projections and difference."""
    
    hist_clim = ds_hist[hist_var].mean('time', keep_attrs=True)
    ref_clim = ds_ref[ref_var].mean('time', keep_attrs=True)
    target_clim = ds_target[target_var].mean('time', keep_attrs=True)
    qq_clim = ds_qq[target_var].mean('time', keep_attrs=True)
    
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
    
    difference = qq_obs_mean_comparison - ref_hist_mean_comparison
    
    fig = plt.figure(figsize=[24, 6])

    ax1 = fig.add_subplot(131, projection=ccrs.PlateCarree())
    ref_hist_mean_comparison.plot(
        ax=ax1,
        transform=ccrs.PlateCarree(),
        cmap=plot_config['diverging_cmap'],
        levels=plot_config['difference_levels'],
        extend='both'
    )
    ax1.set_title('ref - hist')

    ax2 = fig.add_subplot(132, projection=ccrs.PlateCarree())
    qq_obs_mean_comparison.plot(
        ax=ax2,
        transform=ccrs.PlateCarree(),
        cmap=plot_config['diverging_cmap'],
        levels=plot_config['difference_levels'],
        extend='both'
    )
    ax2.set_title('QQ-scaled - original')

    ax3 = fig.add_subplot(133, projection=ccrs.PlateCarree())
    difference.plot(
        ax=ax3,
        transform=ccrs.PlateCarree(),
        cmap=plot_config['diverging_cmap'],
        levels=plot_config['difference_levels'],
        extend='both'
    )
    ax3.set_title('Difference')

    for ax in [ax1, ax2, ax3]:
        ax.coastlines()
    xmin, xmax = ax3.get_xlim()
    ymin, ymax = ax3.get_ylim()
    ax1.set_extent([xmin, xmax, ymin, ymax], crs=ccrs.PlateCarree())
    ax2.set_extent([xmin, xmax, ymin, ymax], crs=ccrs.PlateCarree())

    plt.show()

    
#ds_adjust['hist_q'].sel(point_selection, method='nearest')
def plot_quantiles_2d_point(da_hist_q_point, da_ref_point, da_target_point, quantiles):
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
        'regular',
        levels=plot_config['general_levels'],
        title='reference',
        extend='max',
    )
    quantile_month_plot(
        da_hist_q_point,
        ax2,
        'regular',
        levels=plot_config['general_levels'],
        title='historical',
        extend='max',
    )
    quantile_month_plot(
        da_target_q_point,
        ax3,
        'regular',
        levels=plot_config['general_levels'],
        title='target (obs)',
        extend='max',
    )
    plt.show()


def plot_af_point(da_af_point):
    """Plot adjustment factors for a single grid point"""
    
    fig = plt.figure(figsize=[12, 5])
    ax1 = fig.add_subplot(111)

    quantile_month_plot(
        da_af_point,
        ax1,
        'diverging',
        levels=plot_config['af_levels'],
        title='adjustment factors'
    )
    plt.show()
    

def plot_pdfs_point(da_hist_point, da_ref_point, da_target_point, da_qq_point, month=None):
    """Plot observed, historical and qq-scaled PDFs for a single grid point"""

    hist_point = da_hist_point.copy()
    ref_point = da_ref_point.copy()
    target_point_month = da_target_point.copy()
    qq_point_month = da_qq_point.copy()
    if month:
        hist_point = hist_point[hist_point['time'].dt.month == month]
        ref_point = ref_point[ref_point['time'].dt.month == month]
        target_point = target_point[target_point['time'].dt.month == month]
        qq_point = qq_point[qq_point['time'].dt.month == month]        
    
    fig = plt.figure(figsize=[10, 6])
    ax1 = fig.add_subplot(122)
    ax2 = fig.add_subplot(121)
    bins = np.arange(0, 150, 1)
    target_point_month.plot.hist(
        ax=ax1,
        bins=bins,
        density=True,
        label='observations',
        facecolor='tab:green',
        alpha=0.5,
        rwidth=0.9,
    )
    hist_point_month.plot.hist(
        ax=ax1,
        bins=bins,
        density=True,
        label='histotical data',
        facecolor='tab:blue',
        alpha=0.5,
        rwidth=0.9,
    )
    ax1.set_ylabel('probability')
    #ax1.set_xlim(5, 25)
    ax1.legend()

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
    ax2.set_ylim(0, 0.005)
    ax2.set_xlim(5, 80)
    ax2.legend()

    title = calendar.month_name[month] if month else 'all months'
    plt.suptitle(title)
    plt.show()

    
def plot_quantiles_1d_point(da_hist_point, da_ref_point, da_target_point, da_qq_point, quantiles, month=None):
    """Plot 1D quantiles comparisons"""
    
    hist_point = da_hist_point.copy()
    ref_point = da_ref_point.copy()
    target_point_month = da_target_point.copy()
    qq_point_month = da_qq_point.copy()
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

    ax1.set_xlim(0, 100)
    ax1.set_ylim(0, 37)
    ax1.grid()
    ax1.legend()
    ax1.set_xlabel('quantile')

    ax2.set_xlim(0, 100)
    ax2.set_ylim(0, 37)
    ax2.grid()
    ax2.legend()
    ax2.set_ylabel(ylabel)
    ax2.set_xlabel('quantile')

    title = calendar.month_name[month] if month else 'all months'
    plt.suptitle(f'quantiles - {title}')
    plt.show()


# ds_hist[hist_var], ds_ref[ref_var], ds_target[target_var], ds_qq[target_var]
def single_point_analysis(da_hist, da_ref, da_target, da_qq, ds_adjust, point_selection, months=[]):
    """Plots for a single grid point"""
    
    da_hist_point = ds_hist[hist_var].sel(point_selection, method='nearest')
    da_ref_point = ds_ref[ref_var].sel(point_selection, method='nearest')
    da_target_point = ds_target[target_var].sel(point_selection, method='nearest')
    da_qq_point = ds_qq[target_var].sel(point_selection, method='nearest')
    ds_adjust_point = ds_adjust.sel(point_selection, method='nearest')
    quantiles = ds_adjust['quantiles'].data
    
    plot_quantiles_2d_point(ds_adjust_point['hist_q'], da_ref_point, da_target_point, quantiles)
    plot_af_point(ds_adjust_point['af'])
    
    plot_pdfs_point(da_hist_point, da_ref_point, da_target_point, da_qq_point)
    for month in months:
        plot_pdfs_point(da_hist_point, da_ref_point, da_target_point, da_qq_point, month=month)

    plot_quantiles_1d_point(da_hist_point, da_ref_point, da_target_point, da_qq_point, quantiles)
    for month in months:
        plot_quantiles_1d_point(da_hist_point, da_ref_point, da_target_point, da_qq_point, quantiles, month=month)
    