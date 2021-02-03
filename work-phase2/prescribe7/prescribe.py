import sys
import os
import argparse
import logging
import subprocess

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


    rScriptFile, ext = os.path.splitext(sys.argv[0])
    rScriptFile += ".R"

    try:
        r_cmd = [
            "Rscript",
            "--vanilla",
            rScriptFile,
            args.start_date,
            args.end_date,
            os.path.expanduser(args.prev_file),
            os.path.expanduser(args.cost_file),
            os.path.expanduser(args.output_file),
            os.path.dirname(os.path.realpath(__file__))
        ]

        logging.info("R command: " + ' '.join(r_cmd))

        subprocess.call(r_cmd)
    except OSError as error:
        logging.info(error)
    except:
        logging.info("Unexpected error:", sys.exc_info()[0])
        raise
    else:
        logging.info("Successfully executed", os.path.realpath(__file__))
