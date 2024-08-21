'Command line program for defining the ACS ECDFm file metadata. Source: http://is-enes-data.github.io/CORDEX_adjust_drs.pdf'

import argparse
import yaml


obs_datasets = {}
obs_datasets['AGCD'] = {
    'name': f'Australian Gridded Climate Data v1.0.1 (AGCD; https://dx.doi.org/10.25914/hjqj-0x55)',
    'var_attr_remove': ['analysis_version_number', 'source', 'frequency', 'length_scale_for_analysis', 'analysis_time', 'number_of_stations_reporting'],
}
obs_datasets['AGCA-AGCD'] = {
    'name': f'An AGCA version of AGCD; Australian Gridded Climate Data v1.0.1 (AGCD; https://dx.doi.org/10.25914/hjqj-0x55)',
    'var_attr_remove': [],
}

bc_methods = {}
bc_methods['additive'] = 'Equidistant CDF Matching; https://github.com/AusClimateService/qqscale/blob/master/docs/method_ecdfm.md'
bc_methods['multiplicative'] = 'Equiratio CDF Matching; https://github.com/AusClimateService/qqscale/blob/master/docs/method_ecdfm.md; Wang L, & Chen W (2014). Equiratio cumulative distribution function matching as an improvement to the equidistant approach in bias correction of precipitation. Atmospheric Science Letters, 15(1), 1–6. https://doi.org/10.1002/asl2.454'

experiment_descriptions = {
    'ssp126': 'update of RCP2.6 based on SSP1',
    'ssp245': 'update of RCP4.5 based on SSP2',
    'ssp370': 'gap-filling scenario reaching 7.0 based on SSP3',
    'ssp585': 'update of RCP8.5 based on SSP5',
    'evaluation': 'reanalysis simulation of the recent past',
}
    

def main(args):
    """Run the program."""

    # Global attributes to create/overwrite
    output_dict = {}
    output_dict['global_overwrite'] = {
        'driving_experiment': experiment_descriptions[args.experiment],
        'driving_experiment_id': args.experiment,
        'product': 'bias-adjusted-output',
        'project_id': 'CORDEX-Adjust',
        'contact': 'damien.irving@csiro.au',
        'bc_method': bc_methods[args.scaling],
        'bc_method_id': 'ecdfm',
        'bc_observation': obs_datasets[args.obs]['name'],
        'bc_observation_id': args.obs,
        'bc_period': args.baseline,
        'bc_info': f'ecdfm-{args.obs}-{args.baseline}'
    }
    
    # Global attributes to keep
    output_dict['global_keep'] = [
        'Conventions',
        'domain',
        'domain_id',
        'driving_institution_id',
        'driving_source_id',
        'driving_variant_label',
        'frequency',
        'institution',
        'institution_id',
        'mip_era',
        'native_resolution',
        'source',
        'source_id',
        'source_type',
        'version_realisation',
        'variable_id',
    ]

    # Variable attributes to remove
    output_dict['var_remove'] = {
        'lat': ['bounds',],
        'lon': ['bounds',],
        args.variable: obs_datasets[args.obs]['var_attr_remove'],
    }

    outfile = open(args.outfile, 'w')
    yaml.dump(output_dict, outfile)
    outfile.close()


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description=__doc__,
        argument_default=argparse.SUPPRESS,
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    parser.add_argument(
        'outfile',
        type=str,
        help='Output YAML file name'
    )
    parser.add_argument(
        'variable',
        type=str,
        help='Variable'
    )
    parser.add_argument(
        'obs',
        type=str,
        choices=('AGCD', 'AGCA-AGCD'),
        help='Observational dataset name'
    )
    parser.add_argument(
        'experiment',
        type=str,
        choices=('ssp126', 'ssp245', 'ssp370', 'ssp585', 'evaluation'),
        help='Model experiment'
    )
    parser.add_argument(
        'scaling',
        type=str,
        choices=('additive', 'multiplicative'),
        help='Scaling method',
    )
    parser.add_argument(
        'baseline',
        type=str,
        help='Baseline period in YYYY-YYYY format',
    )
    args = parser.parse_args()
    main(args)
