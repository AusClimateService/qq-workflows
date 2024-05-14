"""Command line program for defining the QDC-CMIP6 file metadata."""

import argparse
import yaml
from datetime import datetime


cmip_doi = {
    'ACCESS-CM2': 'https://doi.org/10.22033/ESGF/CMIP6.2281',
    'ACCESS-ESM1.5': 'https://doi.org/10.22033/ESGF/CMIP6.2288',
    'CESM2': 'https://doi.org/10.22033/ESGF/CMIP6.2185',
    'CMCC-ESM2': 'https://doi.org/10.22033/ESGF/CMIP6.13164',
    'CNRM-ESM2-1': 'https://doi.org/10.22033/ESGF/CMIP6.1391',
    'EC-Earth3': 'https://doi.org/10.22033/ESGF/CMIP6.181',
    'NorESM2-MM': 'https://doi.org/10.22033/ESGF/CMIP6.506',
    'UKESM1-0-LL': 'https://doi.org/10.22033/ESGF/CMIP6.1569',
}

scenariomip_doi = {
    'ACCESS-CM2': 'https://doi.org/10.22033/ESGF/CMIP6.2285',
    'ACCESS-ESM1.5': 'https://doi.org/10.22033/ESGF/CMIP6.2291',
    'CESM2': 'https://doi.org/10.22033/ESGF/CMIP6.2201',
    'CMCC-ESM2': 'https://doi.org/10.22033/ESGF/CMIP6.13168',
    'CNRM-ESM2-1': 'https://doi.org/10.22033/ESGF/CMIP6.1395',
    'EC-Earth3': 'https://doi.org/10.22033/ESGF/CMIP6.251',
    'NorESM2-MM': 'https://doi.org/10.22033/ESGF/CMIP6.608',
    'UKESM1-0-LL': 'https://doi.org/10.22033/ESGF/CMIP6.1567',
}

model_datasets = {}
for model in cmip_doi:
    model_datasets[model] = f'{model} submission to CMIP6 CMIP ({cmip_doi[model]}) and CMIP6 ScenarioMIP ({scenariomip_doi[model]})'

obs_datasets = {}
obs_datasets['AGCD'] = {
    'name': f'Australian Gridded Climate Data v1.0.1 (AGCD; https://dx.doi.org/10.25914/hjqj-0x55)',
    'geospatial_bounds': 'POLYGON((-10.0 112.0,-10.0 156.2,-44.5 156.2,-44.5 112.0,-10.0 112.0))',
    'geospatial_bounds_crs': 'EPSG:4326',
}    
obs_datasets['BARRA-R2'] = {
    'name': f'Bureau of Meteorology Atmospheric high-resolution Regional Reanalysis for Australia - Version 2 (BARRA-R2; https://doi.org/10.25914/1x6g-2v48)',
    'geospatial_bounds': 'POLYGON((12.98 88.48,12.98 207.39,-57.97 207.39,-57.97 88.48,12.98 88.48))',
    'geospatial_bounds_crs': 'EPSG:4326',  
}

var_attrs = {}
var_attrs['pr'] = {
    'standard_name': 'precipitation',
    'long_name': 'Precipitation',
}
var_attrs['time'] = {
    'axis': 'T',
    'long_name': 'time',
    'standard_name': 'time',
}
var_attrs['tasmax'] = {
    'standard_name': 'air_temperature',
    'long_name': 'Daily Maximum Near-Surface Air Temperature',
}
var_attrs['tasmin'] = {
    'standard_name': 'air_temperature',
    'long_name': 'Daily Minimum Near-Surface Air Temperature',
}
var_attrs['hurs'] = {
    'standard_name': 'relative_humidity',
    'long_name': 'Near-Surface Relative Humidity',
}
var_attrs['hursmax'] = {
    'standard_name': 'relative_humidity',
    'long_name': 'Daily Maximum Near-Surface Relative Humidity',
}
var_attrs['hursmin'] = {
    'standard_name': 'relative_humidty',
    'long_name': 'Daily Minimum Near-Surface Relative Humidity',
}
var_attrs['rsds'] = {
    'standard_name': 'surface_downwelling_shortwave_flux_in_air',
    'long_name': 'Surface Downwelling Shortwave Radiation',
}
var_attrs['sfcWind'] = {
    'standard_name': 'wind_speed',
    'long_name': 'Daily Mean Near-Surface Wind Speed',
}
var_attrs['sfcWindmax'] = {
    'standard_name': 'wind_speed',
    'long_name': 'Daily Maximum Near-Surface Wind Speed',
}


def parse_tbounds(tbounds):
    """Parse tbounds arguments.
    
    e.g. gwl20-20400101-20591231 or 20600101-20891231
    """
    
    components = tbounds.split('-')
    if len(components) == 3:
        gwl, start_date, end_date = components
    else:
        start_date, end_date = components
        gwl = None
    start_year = start_date[0:4]
    start_month = start_date[4:6]
    start_day = start_date[6:8]
    start_string = f'{start_year}-{start_month}-{start_day}'
    end_year = end_date[0:4]
    end_month = end_date[4:6]
    end_day = end_date[6:8]
    end_string = f'{end_year}-{end_month}-{end_day}'
    
    if gwl:
        assert gwl[0:3] == 'gwl'
        assert len(gwl) == 5
        tbound_string = f'Global Warming Level {gwl[3]}.{gwl[4]}degC ({start_string} to {end_string})'
    else:
        tbound_string = f'{start_string} to {end_string}'
        
    return tbound_string
    

def main(args):
    """Run the program."""

    hist_tbounds = parse_tbounds(args.hist_tbounds)
    ref_tbounds = parse_tbounds(args.ref_tbounds)
    target_tbounds = parse_tbounds(args.target_tbounds) 

    method_details = {}
    method_details['qdc'] = {
        'title': 'QDC-Scaled CMIP6 Application-Ready Climate Projections',
        'summary': f'The data have been created by applying climate changes simulated between {hist_tbounds} and {ref_tbounds} by the {args.model_name} CMIP6 global climate model to {args.obs} data for {target_tbounds} using the Quantile Delta Change (QDC) scaling method.',
        'info': 'More information on the Quantile Delta Change (QDC) scaling method can be found at https://github.com/AusClimateService/qqscale/blob/master/docs/method_qdc.md.'   
    }
    
    output_dict = {}

    # Global attributes to create/overwrite
    output_dict['global_overwrite'] = {
        'title': method_details[args.method]['title'],
        'Conventions': 'CF-1.8, ACDD-1.3',
        'summary': method_details[args.method]['summary'],
        'keywords': 'GCMD:Locations>Continent>Australia/New Zealand>Australia, GCMD:Earth Science Services>Models>Coupled Climate Models, GCMD:Earth Science>Atmosphere',
        'keywords_vocabulary': 'GCMD:GCMD Keywords, Version 17.9',
        'keywords_reference': 'Global Change Master Directory (GCMD). 2023. GCMD Keywords, Version 17.9, Greenbelt, MD: Earth Science Data and Information System, Earth Science Projects Division, Goddard Space Flight Center, NASA. URL (GCMD Keyword Forum Page): https://forum.earthdata.nasa.gov/app.php/tag/GCMD+Keywords',
        'acknowledgement': f'The Coupled Model Intercomparison Project Phase 6 (CMIP6; https://doi.org/10.5194/gmd-9-1937-2016)',
        'time_coverage_resolution': 'PT1440M0S',
        'processing_level': 'Level 1a: Post-processing of output Level 0 scaled data with robust metadata and data reference syntax applied, but no quality assurance and quality control undertaken.',
        'source': 'Data from ' + obs_datasets[args.obs]['name'] + f' and the {model_datasets[args.model_name]}',
        'comment': method_details[args.method]['info'],
        'contact': 'damien.irving@csiro.au',
        'institution': 'Commonwealth Scientific and Industrial Research Organisation',
        'institute_id': 'CSIRO',
        'creator_name': 'Australian Climate Service',
        'creator_type': 'group',
        'creator_institution': 'Commonwealth Scientific and Industrial Research Organisation',
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
        'cmip6_source_id': args.model_name,
        'code': 'https://github.com/AusClimateService/qqscale'
    }
    
    # Global attributes to keep
    if args.method == 'qdc':
        output_dict['global_keep'] = ['geospatial_lat_min', 'geospatial_lat_max', 'geospatial_lon_min', 'geospatial_lon_max']

    # Variable attributes to create or overwrite
    output_dict['var_overwrite'] = {}
    output_dict['var_overwrite']['time'] = var_attrs['time']
    if args.variable:
        output_dict['var_overwrite'][args.variable] = var_attrs[args.variable]
    if args.units:
        units = 'deg_C' if args.units in ['C', 'Celsius', 'degC'] else args.units
        output_dict['var_overwrite'][args.variable]['units'] = units
        
    # Variable attributes to remove
    output_dict['var_remove'] = {'lat': 'bounds', 'lon': 'bounds'}

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
        "method",
        type=str,
        choices=('qdc', 'ecdfm'),
        help="Quantile method"
    )
    parser.add_argument(
        "outfile",
        type=str,
        help="Output YAML file name"
    )
    parser.add_argument(
        "--variable",
        type=str,
        choices=('tasmin', 'tasmax', 'pr', 'rsds', 'sfcWind', 'sfcWindmax', 'hurs', 'hursmin', 'hursmax'),
        default=None,
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
        choices=('AGCD', 'BARRA-R2'),
        help="Observational dataset name"
    )
    parser.add_argument(
        "--model_name",
        type=str,
        required=True,
        choices=("ACCESS-CM2", "ACCESS-ESM1-5", "CMCC-ESM2", "CESM2", "EC-Earth3", "NorESM2-MM", "UKESM1-0-LL"),
        help="Climate model name"
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
        help="Time bounds for historical model data (e.g. gwl10-20010101-20201231 or 19850101-20141231)"
    )
    parser.add_argument(
        "--ref_tbounds",
        type=str,
        required=True,
        help="Time bounds for reference data (e.g. gwl20-20400101-20591231 or 20600101-20891231)"
    )
    parser.add_argument(
        "--target_tbounds",
        type=str,
        required=True,
        help="Time bounds for target data (e.g. gwl10-20010101-20201231 or 19850101-20141231)"
    )
    args = parser.parse_args()
    main(args)
