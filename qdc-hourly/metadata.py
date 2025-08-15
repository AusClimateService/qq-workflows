"""Command line program for defining the QDC-CMIP6 file metadata."""

import argparse
import yaml
from datetime import datetime


cordex_doi = {
    'CCAM-v2203-SN': 'https://dx.doi.org/10.25914/rd73-4m38',
}

rcm_datasets = {}
for rcm in cordex_doi:
    rcm_datasets[rcm] = f'{rcm} submission to CORDEX-CMIP6 ({cordex_doi[rcm]}) )'

obs_datasets = {}
obs_datasets['BARRA-R2'] = {
    'name': f'Bureau of Meteorology Atmospheric high-resolution Regional Reanalysis for Australia - Version 2 (BARRA-R2; https://doi.org/10.25914/1x6g-2v48)',
    'geospatial_bounds': 'POLYGON((12.98 88.48,12.98 207.39,-57.97 207.39,-57.97 88.48,12.98 88.48))',
    'geospatial_bounds_crs': 'EPSG:4326',
    'var_attr_remove': [],
}

var_name_corrections = {
    'precip': 'pr',
    'tmin': 'tasmin',
    'tmax': 'tasmax',
}

var_attrs = {}
var_attrs['time'] = {
    'axis': 'T',
    'long_name': 'time',
    'standard_name': 'time',
}
var_attrs['tasmin'] = {
    'standard_name': 'air_temperature',
    'long_name': 'Daily Minimum Near-Surface Air Temperature',
}



def parse_tbounds(tbounds):
    """Parse tbounds arguments.
    
    e.g. gwl20-2040-2059 or 2060-2089
    """
    
    components = tbounds.split('-')
    if len(components) == 3:
        gwl, start_year, end_year = components
    else:
        start_year, end_year = components
        gwl = None
    
    if gwl:
        assert gwl[0:3] == 'gwl'
        assert len(gwl) == 5
        tbound_long = f'Global Warming Level {gwl[3]}.{gwl[4]}degC ({start_year}-{end_year})'
        tbound_short = f'GWL {gwl[3]}.{gwl[4]}'
    else:
        tbound_long = f'{start_year}-{end_year}'
        tbound_short = f'{start_year}-{end_year}'
        
    return tbound_long, tbound_short
    

def main(args):
    """Run the program."""

    hist_tbounds_long, hist_tbounds_short  = parse_tbounds(args.hist_tbounds)
    ref_tbounds_long, ref_tbounds_short = parse_tbounds(args.ref_tbounds)
    target_tbounds_long, target_tbounds_short = parse_tbounds(args.target_tbounds) 

    output_dict = {}

    # Variables to rename
    if not args.variable in var_attrs:
        variable = var_name_corrections[args.variable]
        output_dict['rename'] = {args.variable: variable}
    else:
        variable = args.variable
    assert variable in var_attrs

    # Global attributes to create/overwrite
    summary = f'The data have been created by applying climate changes simulated between {hist_tbounds_long} and {ref_tbounds_long} by the {args.rcm_name} RCM to {args.obs} data for {target_tbounds_long} using the Quantile Delta Change (QDC) scaling method.'
    try:
        summary = summary + obs_datasets[args.obs][f'{args.variable}_summary']
    except KeyError:
        pass
    output_dict['global_overwrite'] = {
        'title': 'QDC-Scaled CORDEX-CMIP6 Application-Ready Climate Projections',
        'Conventions': 'CF-1.8, ACDD-1.3',
        'standard_name_vocabulary': 'CF Standard Name Table v86',
        'project': 'QDC-hourly',
        'summary': summary,
        'keywords': 'GCMD:Locations>Continent>Australia/New Zealand>Australia, GCMD:Earth Science Services>Models>Coupled Climate Models, GCMD:Earth Science>Atmosphere',
        'keywords_vocabulary': 'GCMD:GCMD Keywords, Version 17.9',
        'keywords_reference': 'Global Change Master Directory (GCMD). 2023. GCMD Keywords, Version 17.9, Greenbelt, MD: Earth Science Data and Information System, Earth Science Projects Division, Goddard Space Flight Center, NASA. URL (GCMD Keyword Forum Page): https://forum.earthdata.nasa.gov/app.php/tag/GCMD+Keywords',
        'acknowledgement': f'The Coupled Model Intercomparison Project Phase 6 (CMIP6; https://doi.org/10.5194/gmd-9-1937-2016)',
        'time_coverage_resolution': 'PT1440M0S',
        'processing_level': 'Level 1a: Post-processing of output Level 0 scaled data with robust metadata and data reference syntax applied, but no quality assurance and quality control undertaken.',
        'source': 'Data from ' + obs_datasets[args.obs]['name'] + f' and the {rcm_datasets[args.rcm_name]}',
        'comment': 'More information on the Quantile Delta Change (QDC) scaling method can be found at https://github.com/AusClimateService/qqscale/blob/master/docs/method_qdc.md.',
        'projection_method': 'Quantile Delta Change',
        'projection_method_id': 'QDC',
        'projection_baseline': target_tbounds_short,
        'projection_period': ref_tbounds_short,
        'contact': 'damien.irving@csiro.au',
        'institution': 'Commonwealth Scientific and Industrial Research Organisation',
        'institute_id': 'CSIRO',
        'creator_name': 'Australian Climate Service',
        'creator_type': 'group',
        'creator_institution': 'Commonwealth Scientific and Industrial Research Organisation',
        'creator_url': 'https://www.acs.gov.au/',
        'creator_email': 'acs@acs.gov.au',
        'publisher_name': 'Commonwealth Scientific and Industrial Research Organisation',
        'publisher_type': 'institution',
        'publisher_institution': 'Commonwealth Scientific and Industrial Research Organisation',
        'publisher_url': 'https://www.csiro.au/',
        'geospatial_bounds': obs_datasets[args.obs]['geospatial_bounds'],
        'geospatial_bounds_crs': obs_datasets[args.obs]['geospatial_bounds_crs'],
        'license': 'CC BY 4.0 (https://creativecommons.org/licenses/by/4.0/)',
        'cmip6_experiment_id': args.model_experiment,
        'cmip6_variant_label': args.model_run,
        'cmip6_source_id': args.gcm_name,
        'observation_id': args.obs,
        'code': 'https://github.com/AusClimateService/qqscale'
    }
    
    # Global attributes to keep
    output_dict['global_keep'] = ['geospatial_lat_min', 'geospatial_lat_max', 'geospatial_lon_min', 'geospatial_lon_max']

    # Variable attributes to create or overwrite
    output_dict['var_overwrite'] = {}
    output_dict['var_overwrite']['time'] = var_attrs['time']
    output_dict['var_overwrite'][variable] = var_attrs[variable]
    output_dict['var_overwrite'][variable]['coverage_content_type'] = 'modelResult'
    if args.units:
        units = 'deg_C' if args.units in ['C', 'Celsius', 'degC'] else args.units
        output_dict['var_overwrite'][variable]['units'] = units
        
    # Variable attributes to remove
    output_dict['var_remove'] = {
        'lat': ['bounds',],
        'lon': ['bounds',],
        variable: obs_datasets[args.obs]['var_attr_remove'],
    }

    outfile = open(args.outfile, "w")
    yaml.dump(output_dict, outfile)
    outfile.close()


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description=__doc__,
        argument_default=argparse.SUPPRESS,
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    parser.add_argument(
        "outfile",
        type=str,
        help="Output YAML file name"
    )
    parser.add_argument(
        "--variable",
        type=str,
        required=True,
        help="Variable"
    )
    parser.add_argument(
        "--units",
        type=str,
        default=None,
        help="Units for variable"
    )
    parser.add_argument(
        "--obs",
        type=str,
        required=True,
        choices=('BARRA-R2'),
        help="Observational dataset name"
    )
    parser.add_argument(
        "--gcm_name",
        type=str,
        required=True,
        choices=("ACCESS-CM2", "ACCESS-ESM1-5", "CESM2", "CMCC-ESM2", 'CNRM-ESM2-1', "EC-Earth3", "MPI-ESM1-2-HR", "NorESM2-MM", "UKESM1-0-LL"),
        help="GCM name"
    )
    parser.add_argument(
        "--rcm_name",
        type=str,
        required=True,
        choices=("CCAM-v2203-SN"),
        help="RCM name"
    )
    parser.add_argument(
        "--model_experiment",
        type=str,
        required=True,
        help="Model experiment"
    )
    parser.add_argument(
        "--model_run",
        type=str,
        required=True,
        help="Model run"
    )
    parser.add_argument(
        "--hist_tbounds",
        type=str,
        required=True,
        help="Time bounds for historical model data (e.g. gwl10-2001-2020 or 1985-2014)"
    )
    parser.add_argument(
        "--ref_tbounds",
        type=str,
        required=True,
        help="Time bounds for reference data (e.g. gwl20-2040-2059 or 2060-2089)"
    )
    parser.add_argument(
        "--target_tbounds",
        type=str,
        required=True,
        help="Time bounds for target data (e.g. gwl10-2001-2020 or 1985-2014)"
    )
    args = parser.parse_args()
    main(args)
