"""Command line program for running the CIHP13 workflow."""

import argparse
import yaml


model_dois = {
    'ACCESS-CM2': 'https://doi.org/10.22033/ESGF/CMIP6.2281',
    'ACCESS-ESM1.5': 'https://doi.org/10.22033/ESGF/CMIP6.2286',
    'CESM2': 'https://doi.org/10.22033/ESGF/CMIP6.2185',
    'CMCC-ESM2': 'https://doi.org/10.22033/ESGF/CMIP6.13164',
    'CNRM-ESM2-1': 'https://doi.org/10.22033/ESGF/CMIP6.1391',
    'EC-Earth3': 'https://doi.org/10.22033/ESGF/CMIP6.181',
    'NorESM2-MM': 'https://doi.org/10.22033/ESGF/CMIP6.506',
    'UKESM1-0-LL': 'https://doi.org/10.22033/ESGF/CMIP6.1569'.
}

obs_source = {
    'AGCD': f'Data from Australian Gridded Climate Data v1.0.1 (AGCD; https://dx.doi.org/10.25914/hjqj-0x55), scaled using data from the {model} CMIP6 model.',
    'BARRA-R2': f'Data from Bureau of Meteorology Atmospheric high-resolution Regional Reanalysis for Australia - Version 2 (BARRA-R2; https://doi.org/10.25914/1x6g-2v48), scaled using data from the {model} CMIP6 model.'
}

output_dict['global_overwrite'] = {
    'title': 'QDC-Scaled CMIP6 Application-Ready Climate Projections',
    'Conventions': 'CF-1.8, ACDD-1.3',
    'summary': 'Application-ready climate projections. The data have been created by applying future climate changes simulated by a selection of CMIP6 Global Climate Models to BARRA-R2 reanalysis data using the Quantile Delta Change (QDC) scaling method.',
    'keywords': 'GCMD:Locations>Continent>Australia/New Zealand>Australia, GCMD:Earth Science Services>Models>Coupled Climate Models, GCMD:Earth Science>Atmosphere',
    'keywords_vocabulary': 'GCMD:GCMD Keywords, Version 17.9',
    'keywords_reference': 'Global Change Master Directory (GCMD). 2023. GCMD Keywords, Version 17.9, Greenbelt, MD: Earth Science Data and Information System, Earth Science Projects Division, Goddard Space Flight Center, NASA. URL (GCMD Keyword Forum Page): https://forum.earthdata.nasa.gov/app.php/tag/GCMD+Keywords',
    'acknowledgement': 'Overview of the Coupled Model Intercomparison Project Phase 6 (CMIP6) experimental design and organization, https://doi.org/10.5194/gmd-9-1937-2016',
    'time_coverage_resolution': 'PT1440M0S',
    'processing_level': 'Level 1a: Post-processing of output Level 0 scaled data with robust metadata and data reference syntax applied, but no quality assurance and quality control undertaken.',
    'comment': 'More information on the Quantile Delta Change (QDC) scaling method can be found in the technical report.'
    'project_id': 'CIHP-13'
    'contact': 'damien.irving@csiro.au'
  - institution: 'Commonwealth Scientific and Industrial Research Organisation'
  - institute_id: CSIRO
  - creator_name: 'CSIRO Climate Innovation Hub'
  - creator_type: group
  - creator_institution: 'Commonwealth Scientific and Industrial Research Organisation'
  - creator_email: 'climateinnovationhub@csiro.au'
  - publisher_name: 'Commonwealth Scientific and Industrial Research Organisation'
  - publisher_type: institution
  - publisher_institution: 'Commonwealth Scientific and Industrial Research Organisation'
  - publisher_url: 'https://www.csiro.au/'
  - geospatial_bounds: 'POLYGON((12.98 88.48,12.98 207.39,-57.97 207.39,-57.97 88.48,12.98 88.48))'
  - geospatial_bounds_crs: 'EPSG:4326'
  - date_created:
#  - activity_id
#  - license
#  - date_created
  - cmip6_experiment_id: ssp370
  - cmip6_variant_label: r4i1p1f1
  - cmip6_source_id: ACCESS-CM2
  - cmip6_version: v20210712
  - code: https://github.com/climate-innovation-hub/qqscale

}

var_attrs = {}
var_attrs['pr'] = {
    'cell_methods': 'time: mean (interval: 1 hour) time: mean (interval: 1 day)',
    'standard_name': 'lwe_precipitation_rate',
    'long_name': 'Precipitation',
    'units': 'mm day-1',
}
var_attrs['time'] = {
    'long_name': 'time',
}
var_attrs['tasmax'] = {
    'units': 'deg_C',
    'cell_methods': 'time: maximum (interval: 1 hour) time: maximum (interval: 1 day)',
}
var_attrs['tasmin'] = {
    'units': 'deg_C',
    'cell_methods': 'time: minimum (interval: 1 hour) time: minimum (interval: 1 day)',
}
var_attrs['hurs'] = {
    'cell_methods': 'time: point (interval: 1 hour) time: mean (interval: 1 day)',
}
var_attrs['hursmax'] = {
    'cell_methods': 'time: point (interval: 1 hour) time: maximum (interval: 1 day)',
}
var_attrs['hursmin'] = {
    'cell_methods': 'time: point (interval: 1 hour) time: minimum (interval: 1 day)',
}
var_attrs['rsds'] = {
    'cell_methods': 'time: mean (interval: 1 hour) time: mean (interval: 1 day)',
}
var_attrs['sfcWind'] = {
    'cell_methods': 'time: point (interval: 1 hour) area: point (comment: bilinear interpolation) time: mean (interval: 1 day)',
}
var_attrs['sfcWindmax'] = {
    'cell_methods': 'time: maximum (interval: 1 hour) area: point (comment: bilinear interpolation) time: maximum (interval: 1 day)',
}


def main(args):
    """Run the program."""

    output_dict = {}
    
    # Global attributes
    if args.method == 'qdc':
        output_dict['global_keep'] = ['geospatial_lat_min', 'geospatial_lat_max', 'geospatial_lon_min', 'geospatial_lon_max']
    
    
    # Variable attributes
    output_dict['var_overwrite'][args.var] = var_attrs[args.var]
    output_dict['var_overwrite'][args.var]['coverage_content_type'] = 'modelResult'
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
        "--model",
        type=str,
        help="Climate model name"
    )
    parser.add_argument(
        "--obs",
        type=str,
        help="Observational dataset name"
    )
    
    main(args)