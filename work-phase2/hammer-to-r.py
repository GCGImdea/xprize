import pandas as pd
import argparse



if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("-sN", "--start_date_no",
                        dest="start_date_no",
                        type=str,
                        required=True,
                        help="Start date from which to apply no intervention, included, as YYYY-MM-DD."
                             "For example 2020-08-01")
    parser.add_argument("-eN", "--end_date_no",
                        dest="end_date_no",
                        type=str,
                        required=True,
                        help="End date from which to apply no intervention, included, as YYYY-MM-DD."
                             "For example 2020-08-31")
    parser.add_argument("-s", "--start_date",
                        dest="start_date",
                        type=str,
                        required=True,
                        help="Start date from which to apply intervention, included, as YYYY-MM-DD."
                             "For example 2020-08-01")
    parser.add_argument("-e", "--end_date",
                        dest="end_date",
                        type=str,
                        required=True,
                        help="End date from which to apply intervention, included, as YYYY-MM-DD."
                             "For example 2020-08-31")
    parser.add_argument("-hammerTypes", "--hammer_Types",
                        dest="hammer_type",
                        type=int,
                        required=True,
                        help="Types of hammers to use:\n" +\
                            "1: apply just one intervention\n" +\
                            "2: apply all possible intervention combinations")
    parser.add_argument("-o", "--output_dir",
                        dest="output_dir",
                        type=str,
                        required=True,
                        help="Directory to store the resulting Rt files")
    args = parser.parse_args()
    print(f"Generating prescriptions from {args.start_date} to {args.end_date}...")
    prescribe(args.start_date, args.end_date, args.prev_file, args.cost_file, args.output_file)
    print("Done!")

