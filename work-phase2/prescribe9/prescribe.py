# Copyright 2021 (c) R.A. García Leiva (rafael.garcia@imdea.org). IMDEA Networks Institute.

import argparse

import numpy  as np
import pandas as pd

from datetime import date, timedelta

import os
import time


IP_COLS = ['C1_School closing',
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
              path_to_prior_ips_file: str,
              path_to_cost_file: str,
              output_file_path) -> None:
    pass
    #time.sleep(30)



# !!! PLEASE DO NOT EDIT. THIS IS THE OFFICIAL COMPETITION API !!!
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
                        dest="prior_ips_file",
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
    print(f"Generating prescriptions from {args.start_date} to {args.end_date}...")
    prescribe(args.start_date, args.end_date, args.prior_ips_file, args.cost_file, args.output_file)
    print("Done!")

