import os
import argparse
import pandas as pd
import glob
import subprocess
import logging
import time

logging.basicConfig(
    format='%(asctime)s %(levelname)-8s %(message)s',
    level=logging.INFO,
    datefmt='%Y-%m-%d %H:%M:%S')

if __name__ == '__main__':

    logging.info('#######  EXECUTING CORONASURVEYS MULTI-PRESCRIPTOR RUNNER  #####################################')

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
       print ("Creation of the directory %s failed" % output_prescriptions_dir)
    else:
       print ("Successfully created the directory %s " % output_prescriptions_dir)


    prescriptions = glob.glob('prescribe[0-9]/prescribe.py', recursive=False)
    output_files = []

    print('\n\n***************************************************************************************')
    print(f'********* CORONASURVEYS PRESCRIPTIONS: {prescriptions}')
    print('***************************************************************************************')

    procs_list = []

    for p in prescriptions:

        logging.info('=========================================================================================')
        logging.info(f'## Calling Prescriptor with [{p}] from {args.start_date} to {args.end_date}')
        logging.info('=========================================================================================')

        prescription_script = os.path.basename(p)
        prescription_dir = os.path.dirname(p)

        filename, file_extension = os.path.splitext(args.output_file)
        prescription_output_file = os.path.realpath(os.path.expanduser(os.path.join(prescription_dir, prescription_dir + "_output" + file_extension)))

        try:
           proc = subprocess.Popen(
              [
                 'python', prescription_script,
                 '--start_date', args.start_date,
                 '--end_date', args.end_date,
                 '--interventions_past', os.path.expanduser(args.prev_file),
                 '--intervention_costs', os.path.expanduser(args.cost_file),
                 '--output_file', os.path.expanduser(prescription_output_file)
              ],
               cwd=os.path.realpath(os.path.expanduser(prescription_dir)),
               stdout=subprocess.PIPE,
               stderr=subprocess.PIPE
           )
           #, creationflags=subprocess_flags)

           procs_list.append(proc)

           #proc.wait()
           #(stdout, stderr) = proc.communicate()
           #print(stdout)
           #print(stderr)

        except calledProcessError as err:
           print("Error occurred: " + err.stderr)


        # let this be here, in case we need to parallelize prescriptors
        output_files.append(prescription_output_file)

        print('\n********* Ended Processing: {}'.format(p))
        #print("********************** WROTE: {}".format(prescription_output_file))


    for p in procs_list:
        #p.wait()
        (stdout, stderr) = p.communicate()
        print(stdout.decode())
        print(stderr.decode())

    # filter for outputs that cannot be read
    for of in output_files:
       if not os.path.isfile(of):
          output_files.remove(of)

    # concatenate csv files
    combined_csv = pd.concat([pd.read_csv(f) for f in output_files ])

    #combined_csv.to_csv( args.output_file, index=False, encoding='utf-8-sig')
    combined_csv.to_csv( args.output_file, encoding='utf-8-sig')

    #prescribe(args.start_date, args.end_date, args.prev_file, args.cost_file, args.output_file)
    print("Done!")
    logging.info('#######   COMPLETED CORONASURVEYS MULTI-PRESCRIPTOR RUNNER  #####################################')


