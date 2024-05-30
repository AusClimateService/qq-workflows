"""Command line program for running the QDC-CMIP6 workflow."""

import os
import sys
import argparse

sys.path.append('/g/data/xv83/quantile-mapping/gwls')
import gwl


run_dict = {
    'ACCESS-CM2': 'r4i1p1f1',
    'ACCESS-ESM1-5': 'r6i1p1f1',
    'CESM2': 'r11i1p1f1',
    'CMCC-ESM2': 'r1i1p1f1',
    'CNRM-ESM2-1': 'r1i1p1f2',
    'EC-Earth3': 'r1i1p1f1',
    'NorESM2-MM': 'r1i1p1f1',
    'UKESM1-0-LL': 'r1i1p1f2',
}

valid_vars = {
    'AGCD': ['tasmax', 'tasmin', 'pr'],
    'BARRA-R2': ["tasmax", "tasmin", "pr", "rsds", "hurs", "hursmin", "hursmax", "sfcWind", "sfcWindmax"]
}


def get_target_tbounds(product):
    """Get the time bounds to be applied to observations"""

    assert product in ['timeslice', 'gwl'] 

    if product == 'timeslice':
        target_start = 1985
        target_end = 2014
    elif product == 'gwl':
        target_start = 2001
        target_end = 2020

    return target_start, target_end


def get_model_tbounds(product, model, run, experiment, ref):
    """Get the time bounds to applied to the model data"""

    assert product in ['timeslice', 'gwl'] 

    if product == 'timeslice':
        ref_start, ref_end = ref.split('-')
        hist_start = 1985
        hist_end = 2014
    elif product == 'gwl':
        ref_gwl = float(ref[3:-1] + '.' + ref[-1])
        hist_start, hist_end = gwl.get_GWL_syear_eyear('CMIP6', model, run, experiment, 1.0)
        ref_start, ref_end = gwl.get_GWL_syear_eyear('CMIP6', model, run, experiment, ref_gwl)

    return hist_start, hist_end, ref_start, ref_end


def main(args, product):
    """Run the program."""

    makefile = '/g/data/xv83/quantile-mapping/qq-workflows/Makefile'
    config = '/g/data/xv83/quantile-mapping/qq-workflows/qdc-cmip6/config_qdc-cmip6.mk'
    target_start, target_end = get_target_tbounds(product)
    for var in args.variables:
        for obs in args.obs:
            if var not in valid_vars[obs]:
                continue
            for model in args.models:
                run = run_dict[model]
                for exp in args.experiments:
                    hist_start, hist_end, ref_start, ref_end = get_model_tbounds(product, model, run, exp, args.output)
                    if args.dry_run or (args.target in ['metadata', 'split-by-year', 'clean-up']):
                        flags = '-n -f' if args.dry_run else '-f'
                        model_tbounds = f'HIST_START={hist_start} HIST_END={hist_end} REF_START={ref_start} REF_END={ref_end}'
                        target_tbounds = f'TARGET_START={target_start} TARGET_END={target_end}'
                        command = f'make {args.target} {flags} {makefile} CONFIG={config} VAR={var} OBS_DATASET={obs} MODEL={model} EXPERIMENT={exp} RUN={run} {model_tbounds} {target_tbounds}'
                        if product == 'gwl':
                            command = command + f' BASE_GWL=gwl10 REF_GWL={args.output}'
                    else:
                        model_tbounds = f'hist_start={hist_start},hist_end={hist_end},ref_start={ref_start},ref_end={ref_end}'
                        target_tbounds = f'target_start={target_start},target_end={target_end}'
                        command = f'qsub -v target={args.target},var={var},obs={obs},model={model},experiment={exp},run={run},{model_tbounds},{target_tbounds}'
                        if product == 'gwl':
                            command = command + f',base_gwl=gwl10,ref_gwl={args.output}'
                        command = command + ' job_qdc-cmip6.sh'
                    print(command)
                    if not args.no_run:
                        os.system(command)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description=__doc__,
        argument_default=argparse.SUPPRESS,
        formatter_class=argparse.RawDescriptionHelpFormatter
    )     
    parser.add_argument(
        "target",
        type=str,
        choices=("metadata", "train", "adjust", "validation", "clipmax", "split-by-year", "clean-up"),
        help="Makefile target"
    )
    parser.add_argument(
        "output",
        type=str,
        help="""can be a timeslice (e.g. '2035-2064', '2070-2099') or global warming level (e.g. 'gwl20')"""
    )
    parser.add_argument(
        "--obs",
        type=str,
        nargs='*',
        choices=("AGCD", "BARRA-R2"),
        help="Observational dataset to process"
    )
    parser.add_argument(
        "--variables",
        type=str,
        nargs='*',
        choices=("tasmax", "tasmin", "pr", "rsds", "hurs", "hursmin", "hursmax", "sfcWind", "sfcWindmax"),
        required=True,
        help='variables to process [required]',
    )
    parser.add_argument(
        "--models",
        type=str,
        nargs='*',
        choices=("ACCESS-CM2", "ACCESS-ESM1-5", "CMCC-ESM2", "CESM2", "EC-Earth3", "NorESM2-MM", "UKESM1-0-LL"),
        required=True,
        help='models to process [required]',
    )
    parser.add_argument(
        "--experiments",
        type=str,
        nargs='*',
        choices=("ssp126", "ssp245", "ssp370", "ssp585"),
        help='experiments [required for timeslice output]',
    )
    parser.add_argument(
        "--no_run",
        action='store_true',
        default=False,
        help='show the make command that would be run but do not execute',
    )
    parser.add_argument(
        "--dry_run",
        action='store_true',
        default=False,
        help='run the make command with the -n flag (dry run mode)',
    )
    args = parser.parse_args()
    if args.output[0:3] == "gwl":
        product = 'gwl'
        args.experiments = ['ssp370',]
    else:
        product = 'timeslice'
    main(args, product)

