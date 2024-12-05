"""Command line program for processing AGCD data to include with QDC-CMIP6 dataset.

e.g. /g/data/xv83/agcd-csiro/tmax/daily/tmax_AGCD-CSIRO_r005_YYYYMMDD-YYYYMMDD_daily.nc

"""

import sys
import argparse

import git
import xarray as xr
import cmdline_provenance as cmdprov


cmor_to_agcd_name = {
    'pr': 'precip',
    'tasmin': 'tmin',
    'tasmax': 'tmax',
}

cmor_var_attrs = {}
cmor_var_attrs['pr'] = {
    'standard_name': 'lwe_precipitation_rate',
    'long_name': 'Precipitation',
    'units': 'mm d-1',
    'coverage_content_type': 'modelResult',
}
cmor_var_attrs['tasmax'] = {
    'standard_name': 'air_temperature',
    'long_name': 'Daily Maximum Near-Surface Air Temperature',
    'units': 'degC',
    'coverage_content_type': 'modelResult',
}
cmor_var_attrs['tasmin'] = {
    'standard_name': 'air_temperature',
    'long_name': 'Daily Minimum Near-Surface Air Temperature',
    'units': 'degC',
    'coverage_content_type': 'modelResult',
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


def get_global_attrs(ds):
    """Get the global attributes for output file."""

    attrs_to_keep = [
        'geospatial_lat_min',
        'geospatial_lat_max',
        'geospatial_lon_min',
        'geospatial_lon_max',
        'bom-cmp-awap_version',
        'bom-cmp-util_aifs2nc_version',
        'title',
        'keywords',
        'references',
        'url',
        'id',
        'summary',
    ]
    global_attrs = {key: ds.attrs[key] for key in attrs_to_keep}
    global_attrs['acknowledgement'] = ds.attrs['acknowledgment']

    global_attrs['standard_name_vocabulary'] = 'CF Standard Name Table v86'
    global_attrs['Conventions'] = 'CF-1.8, ACDD-1.3'
    global_attrs['license'] = 'CC BY 4.0 (https://creativecommons.org/licenses/by/4.0/)'
    global_attrs['comment'] = 'This is a copy of the AGCD data on the CSIRO Digiscape Climate Data Portal (see https://github.com/AusClimateService/agcd-csiro for details) with minor modifications to the file metadata.'

    year = str(ds.time.dt.year.values[0])
    global_attrs['time_coverage_start'] = f'{year}0101T0000Z'
    global_attrs['time_coverage_end'] = f'{year}1231T0000Z'
    global_attrs['time_coverage_duration'] = 'P1Y0M0DT0H0M0S'
    global_attrs['time_coverage_resolution'] = 'PT1440M0S' 

    global_attrs['contact'] = 'damien.irving@csiro.au'
    global_attrs['creator_institution'] = 'Australian Bureau of Meteorology'
    global_attrs['creator_type'] = 'institution'
    global_attrs['publisher_institution'] = 'Commonwealth Scientific and Industrial Research Organisation'
    global_attrs['publisher_name'] = 'Australian Climate Service'
    global_attrs['publisher_type'] = 'group'
    global_attrs['publisher_url'] = 'https://www.csiro.au/'

    global_attrs['history'] = get_new_log()

    return global_attrs


def main(args):
    """Run the program."""
    
    ds = xr.open_dataset(args.infile)

    agcd_var = cmor_to_agcd_name[args.var]
    ds = ds.rename({agcd_var: args.var})

    ds.attrs = get_global_attrs(ds)
    ds[args.var].attrs = cmor_var_attrs[args.var]

    output_encoding = get_output_encoding(ds, args.var)
    ds.to_netcdf(args.outfile, encoding=output_encoding)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter
    )     
    parser.add_argument("infile", type=str, help="input files")
    parser.add_argument("var", type=str, choices=('tasmin', 'tasmax', 'pr'), help="input variable")
    parser.add_argument("outfile", type=str, help="output file")
    args = parser.parse_args()
    main(args)

