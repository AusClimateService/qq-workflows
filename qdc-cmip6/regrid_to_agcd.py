"""Regrid to AGCD grid"""

import argparse

import numpy as np
import xarray as xr
import xesmf as xe
import cmdline_provenance as cmdprov


def get_outfile_encoding(ds, var):
    """Define output file encoding."""

    encoding = {}
    ds_vars = list(ds.coords) + list(ds.keys())
    for ds_var in ds_vars:
        encoding[ds_var] = {'_FillValue': None}
    encoding[var]['dtype'] = 'float32'
    encoding[var]['zlib'] = True
    encoding['time']['units'] = 'days since 1850-01-01'

    return encoding


def main(args):
    """Run the program."""

    input_ds = xr.open_dataset(args.infile)

    # 05i (0.05 degree) grid with AGCD bounds (lon: 886, lat: 691)
    lat_values = np.round(np.arange(-44.5, -9.99, 0.05), decimals=2)
    lat_attrs = {
        'standard_name': 'latitude',
        'long_name': 'latitude',
        'units': 'degrees_north',
        'axis': 'Y',
    }
    lon_values = np.round(np.arange(112, 156.251, 0.05), decimals=2)
    lon_attrs = {
        'standard_name': 'longitude',
        'long_name': 'longitude',
        'units': 'degrees_east',
        'axis': 'X',
    }    
    agcd_grid = xr.Dataset(
        {
            'lat': (['lat'], lat_values, lat_attrs),
            'lon': (['lon'], lon_values, lon_attrs), 
        }
    )
    regridder = xe.Regridder(input_ds, agcd_grid, 'bilinear')
    output_ds = regridder(input_ds, keep_attrs=True)

    output_ds.attrs['geospatial_lat_min'] = -44.525
    output_ds.attrs['geospatial_lat_max'] = -9.975
    output_ds.attrs['geospatial_lon_min'] = 111.975
    output_ds.attrs['geospatial_lon_max'] = 156.275

    infile_log = {}
    infile_log[args.infile] = input_ds.attrs['history']
    output_ds.attrs['history'] = cmdprov.new_log(infile_logs=infile_log)
    encoding = get_outfile_encoding(output_ds, args.var)
    output_ds.to_netcdf(args.outfile, encoding=encoding)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter
    )     
    parser.add_argument("infile", type=str, help="input file")
    parser.add_argument("var", type=str, help="input variable")
    parser.add_argument("outfile", type=str, help="output file")
    args = parser.parse_args()
    main(args)

