"""Command line program for processing AGCD data to include with QDC-CMIP6 dataset.

e.g. /g/data/xv83/agcd-csiro/tmax/daily/tmax_AGCD-CSIRO_r005_YYYYMMDD-YYYYMMDD_daily.nc

"""

import sys
import argparse

import git
import xarray as xr
import cmdline_provenance as cmdprov


var_to_cmor_name = {
    'precip': 'pr',
    'tmin': 'tasmin',
    'tmax': 'tasmax',
}

cmor_var_attrs = = {}
cmor_var_attrs['pr'] = {
    'standard_name': 'lwe_precipitation_rate',
    'long_name': 'Precipitation',
}
cmor_var_attrs['tasmax'] = {
    'standard_name': 'air_temperature',
    'long_name': 'Daily Maximum Near-Surface Air Temperature',
}
cmor_var_attrs['tasmin'] = {
    'standard_name': 'air_temperature',
    'long_name': 'Daily Minimum Near-Surface Air Temperature',
}


output_units = {
    'tasmax': 'degC',
    'tasmin': 'degC',
    'pr': 'mm d-1',
}

def get_new_log():
    """Generate command log for output file."""

    try:
        script_dir = sys.path[0]
        repo_dir = '/' + '/'.join(script_dir.split('/')[1:-1]) 
        repo = git.Repo(repo_dir)
        repo_url = repo.remotes[0].url.split(".git")[0]
        commit_hash = str(repo.heads[0].commit)
        code_info = f'{repo_url}, commit {commit_hash[0:7]}'
    except (git.exc.InvalidGitRepositoryError, NameError):
        code_info = None
    new_log = cmdprov.new_log(code_url=code_info)

    return new_log


def get_output_encoding(ds, var):
    """Define the output file encoding."""

    encoding = {}
    ds_vars = list(ds.coords) + list(ds.keys())
    for ds_var in ds_vars:
        encoding[ds_var] = {'_FillValue': None}
#    encoding[var]['least_significant_digit'] = 2
    encoding[var]['zlib'] = True
    encoding['time']['units'] = 'days since 1850-01-01'

    return encoding


def main(args):
    """Run the program."""
    
    ds = xr.open_mfdataset(args.infiles)
    cmor_var = var_to_cmor_name[args.invar]
    ds = ds.rename({args.invar: cmor_var})
    ds.attrs['history'] = get_new_log()
    output_encoding = get_output_encoding(ds, cmor_var)
    ds.to_netcdf(args.outfile, encoding=output_encoding)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter
    )     
    parser.add_argument("infiles", type=str, nargs='*', help="input files")
    parser.add_argument("invar", type=str, help="input variable")
    parser.add_argument("outfile", type=str, help="output file")
    args = parser.parse_args()
    main(args)

