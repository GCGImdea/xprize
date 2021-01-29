# Copyright 2020 (c) Cognizant Digital Business, Evolutionary AI. All rights reserved. Issued under the Apache 2.0 License.

import os
import argparse
import pandas as pd
import glob
import subprocess

NPI_COLS = ['C1_School closing',
            'C2_Workplace closing',
            'C3_Cancel public events',
            'C4_Restrictions on gatherings',
            'C5_Close public transport',
            'C6_Stay at home requirements',
            'C7_Restrictions on internal movement',
            'C8_International travel controls',
            'H1_Public information campaigns',
            'H2_Testing policy',
            'H3_Contact tracing',
            'H6_Facial Coverings']


def prescribe(start_date_str: str,
              end_date_str: str,
              path_to_hist_file: str,
              path_to_cost_file: str,
              output_file_path) -> None:

    # Create skeleton df with one row for each geo for each day
    hdf = pd.read_csv(path_to_hist_file,
                      parse_dates=['Date'],
                      encoding="ISO-8859-1",
                      dtype={"RegionName": str},
                      error_bad_lines=True)
    start_date = pd.to_datetime(start_date_str, format='%Y-%m-%d')
    end_date = pd.to_datetime(end_date_str, format='%Y-%m-%d')
    country_names = []
    region_names = []
    dates = []

    for country_name in hdf['CountryName'].unique():
        cdf = hdf[hdf['CountryName'] == country_name]
        for region_name in cdf['RegionName'].unique():
            for date in pd.date_range(start_date, end_date):
                country_names.append(country_name)
                region_names.append(region_name)
                dates.append(date.strftime("%Y-%m-%d"))

    prescription_df = pd.DataFrame({
        'CountryName': country_names,
        'RegionName': region_names,
        'Date': dates})

    # Fill df with all zeros
    for npi_col in NPI_COLS:
        prescription_df[npi_col] = 0

    # Add prescription index column.
    prescription_df['PrescriptionIndex'] = 0

    # Create the output path
    os.makedirs(os.path.dirname(output_file_path), exist_ok=True)

    # Save to a csv file
    prescription_df.to_csv(output_file_path, index=False)

    return


if __name__ == '__main__':
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

        print('\n######################################################################################################')
        print(f'## Calling Prescriptor with [{p}] from {args.start_date} to {args.end_date}')
        print('######################################################################################################')

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
              ], cwd=os.path.realpath(os.path.expanduser(prescription_dir)), stdout=subprocess.PIPE, stderr=subprocess.PIPE)
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
        print(stdout)
        print(stderr)

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



