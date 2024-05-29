"""Command line program for pre-processing BARRA-R2 1hr hurs to daily hursmin and hursmax."""

import sys
import argparse

import git
import xarray as xr
import cmdline_provenance as cmdprov


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


def get_output_encoding(ds, var, time_units):
    """Define the output file encoding."""

    encoding = {}
    ds_vars = list(ds.coords) + list(ds.keys())
    for ds_var in ds_vars:
        encoding[ds_var] = {'_FillValue': None}
#    encoding[var]['least_significant_digit'] = 2
    encoding[var]['zlib'] = True
    encoding['time']['units'] = time_units   

    return encoding


def main(args):
    """Run the program."""
    
    ds = xr.open_dataset(args.infile, mask_and_scale=True)
    time_units = ds['time'].encoding['units']
    if args.outvar == 'hursmax':
        ds = ds.resample(time='D').max('time', keep_attrs=True)
        ds = ds.rename({'hurs': 'hursmax'})
        ds['hursmax'].attrs['long_name'] = 'Daily Maximum Near-Surface Relative Humidity'
    elif args.outvar == 'hursmin':
        ds = ds.resample(time='D').min('time', keep_attrs=True)
        ds = ds.rename({'hurs': 'hursmin'})
        ds['hursmin'].attrs['long_name'] = 'Daily Minimum Near-Surface Relative Humidity'
    del ds[args.outvar].attrs['cell_methods']
    ds.attrs['history'] = get_new_log()
    output_encoding = get_output_encoding(ds, args.outvar, time_units)
    ds.to_netcdf(args.outfile, encoding=output_encoding)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter
    )     
    parser.add_argument("infile", type=str, help="input file")
    parser.add_argument("outvar", type=str, choices=('hursmin', 'hursmax'), help="output variable")
    parser.add_argument("outfile", type=str, help="output file")
    args = parser.parse_args()
    main(args)

