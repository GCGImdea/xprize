import os
import argparse
import pandas as pd
import glob
import subprocess
import logging
import time
import json

bin_path = os.path.join('usr', 'bin')
opt_conda_path = os.path.join('opt', 'conda', 'bin')
os.environ["PATH"] += os.pathsep + opt_conda_path + os.pathsep + bin_path

logging.basicConfig(
    filename='prescripting.log',
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    level=logging.INFO,
    datefmt='%Y-%m-%d %H:%M:%S')

if __name__ == '__main__':
    logging.info('')
    logging.info('')
    logging.info('#######  EXECUTING CORONASURVEYS MULTI-PRESCRIPTOR RUNNER  #####################################')
    logging.info('')

    parser = argparse.ArgumentParser()
    parser.add_argument("-s", "--start_date",
                        dest="start_date",
                        type=str,
                        required=True,
                        help="Start date from which to prescribe, included, as YYYY-MM-DD."
                             "For example 2020-08-01")
    parser.add_argument("-e", "--end_date",
                        dest="end_date",
                        type=str,
                        required=True,
                        help="End date for the last prescription, included, as YYYY-MM-DD."
                             "For example 2020-08-31")
    parser.add_argument("-ip", "--interventions_past",
                        dest="prev_file",
                        type=str,
                        required=True,
                        help="The path to a .csv file of previous intervention plans")
    parser.add_argument("-c", "--intervention_costs",
                        dest="cost_file",
                        type=str,
                        required=True,
                        help="Path to a .csv file containing the cost of each IP for each geo")
    parser.add_argument("-o", "--output_file",
                        dest="output_file",
                        type=str,
                        required=True,
                        help="The path to an intervention plan .csv file")
    args = parser.parse_args()

    try:
        output_prescriptions_dir = os.path.expanduser('~/work/prescriptions')
        os.makedirs(output_prescriptions_dir, exist_ok=True)
    except OSError:
        logging.info(f'Creation of the directory {output_prescriptions_dir} failed')
    else:
        logging.info(f'Successfully created the directory {output_prescriptions_dir}')

    prescriptions = sorted(glob.glob('prescribe[0-9]/prescribe.py', recursive=False))
    output_files = {}

    logging.info('')
    logging.info('***************************************************************************************')
    logging.info(f'********* CORONASURVEYS PRESCRIPTIONS *************************************************')
    logging.info(json.dumps(prescriptions, indent=32))
    logging.info('***************************************************************************************')
    logging.info('')

    procs = {}

    for p in prescriptions:

        logging.info(f'Launching prescriptor [{p}] from {args.start_date} to {args.end_date}')

        prescription_script = os.path.basename(p)
        prescription_dir = os.path.dirname(p)

        filename, file_extension = os.path.splitext(args.output_file)
        prescription_output_file = os.path.realpath(
            os.path.expanduser(os.path.join(prescription_dir, prescription_dir + "_output" + file_extension)))

        if os.path.exists(prescription_output_file):
            os.remove(prescription_output_file)

        try:
            execute_cmd = [
                'python', prescription_script,
                '--start_date', args.start_date,
                '--end_date', args.end_date,
                '--interventions_past', os.path.expanduser(args.prev_file),
                '--intervention_costs', os.path.expanduser(args.cost_file),
                '--output_file', os.path.expanduser(prescription_output_file)
            ]

            logging.info(json.dumps(execute_cmd, indent=32))

            procs[p] = subprocess.Popen(
                execute_cmd,
                cwd=os.path.realpath(os.path.expanduser(prescription_dir)),
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE
            )
            # , creationflags=subprocess_flags)

        except subprocess.CalledProcessError as err:
            logging.info(f'Error occurred: {err.stderr}')

        # let this be here, in case we need to parallelize prescriptors
        output_files[p] = prescription_output_file

    ###################################################################################
    print("\n\nlaunched\n\n")

    procs_to_terminate = list(procs.keys())
    start = time.time()
    timeout = 7200 # 2 hours in seconds

    # do this while there are processes alive
    while procs_to_terminate:

        time.sleep(1)

        # if elapsed time exceeds the timeout threshold
        if (time.time() - start) > timeout:

            # ok go ahead and forcibly terminate all processes
            for pkey, p in list(procs.items()):
                if p.poll() is None:
                    p.terminate()
                    del output_files[pkey] # since we abruptly terminated, ignore any outputs
                    logging.info(f"      Terminated {pkey} - {timeout} secs timeout exceeded.")
                else:
                    logging.info(f"Already finished {pkey} - {timeout} secs timeout exceeded.")

            break


        for pkey in procs_to_terminate:

            # check if process has terminated (i.e. poll() != None)
            if procs[pkey].poll() is not None:

                procs_to_terminate.remove(str(pkey))

                (stdout, stderr) = procs[pkey].communicate()
                logging.info("")
                logging.info("=======================================================================================")
                logging.info(f'Prescriptor: {pkey} - exitcode: {procs[pkey].returncode}')
                logging.info("")
                logging.info("=== stdout ============================================================================")
                logging.info(stdout.decode())
                logging.info("")
                logging.info("=== stderr ============================================================================")
                logging.info(stderr.decode())
                logging.info("")
                logging.info("---------------------------------------------------------------------------------------")
                logging.info("")


    # filter for outputs that cannot be read
    outputs_to_combine = list(output_files.keys())
    for pkey in outputs_to_combine:
        if not os.path.isfile(output_files[pkey]):
            del output_files[pkey]

    # concatenate csv files
    combined_csv = pd.concat([pd.read_csv(f) for f in output_files.values()])

    # combined_csv.to_csv( args.output_file, index=False, encoding='utf-8-sig')
    combined_csv.to_csv(args.output_file, encoding='utf-8-sig')

    # prescribe(args.start_date, args.end_date, args.prev_file, args.cost_file, args.output_file)
    logging.info('#######   COMPLETED CORONASURVEYS MULTI-PRESCRIPTOR RUNNER  #####################################')
