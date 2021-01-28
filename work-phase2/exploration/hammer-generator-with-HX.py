import pandas as pd
import numpy as np
import argparse
import sys


# Columns holding IP levels
IP_COLS = ['C1_School closing',
       'C2_Workplace closing', 'C3_Cancel public events',
       'C4_Restrictions on gatherings', 'C5_Close public transport',
       'C6_Stay at home requirements', 'C7_Restrictions on internal movement',
       'C8_International travel controls',
       'H1_Public information campaigns',
       'H2_Testing policy',
       'H3_Contact tracing',
       'H6_Facial Coverings'
]


def gen_IP1_hammers(df=None, ip_columns=IP_COLS):
    """
    Generates a vector of 1 active IP, e.g.:
    [ [0, 0, 0, ..., 0],
      [1, 0, 0, ..., 0],
      ...
      [0, 1, 0, ..., 0],
      [0, 2, 0, ..., 0],
      ...
      [0, 0, 0, ..., N]]
    """

    # Read the validation example to retrieve IP levels
    if type(df) != pd.DataFrame:
        df = pd.read_csv('../validation/data/2020-09-30_historical_ip.csv')

    hammers = []
    for IP_col in ip_columns:
        IP_idx = ip_columns.index(IP_col)
        hammer = [0] * len(ip_columns)
        for IP_level in df[IP_col].unique():
            IP1_hammer = list(hammer)
            IP1_hammer[IP_idx] = IP_level
            hammers.append( IP1_hammer )

    # Only one hammer with all zeros (the first one)
    hammers = list(filter(lambda h: any(h), hammers))
    hammers = [[0]*len(ip_columns)] + hammers

    return hammers



def gen_IP1_hammer_dfs(start_date_no, end_date_no, start_date, end_date,
        df=None, nth=1, frac=1):
    """
    Generate dataframes of hammers with 1 IP active.
    From start_date_no to end_date_no there are no IPs,
    and from start_date to end_date there are IPs.
    
    It generates the nth/frac of the corresponding hammers.
    E.g., the 4th/5 fraction of hammers
              0th/5 fraction
    Note: fractions start from 0
    """
    
    # Read the validation example as IP df template
    if type(df) != pd.DataFrame:
        df = pd.read_csv('../validation/data/2020-09-30_historical_ip.csv')

    # Get the nth/frac fraction of the hammers
    print(f'Generating the {nth}/{frac} frac. of hammers...')
    IP_hammers = gen_IP1_hammers(df, ip_columns=IP_COLS)
    # frac_len = int(len(IP_hammers) / frac)
    # frac_start = int( len(IP_hammers) * nth/frac )
    # frac_end = frac_start + frac_len if nth<frac-1 else len(IP_hammers)
    # IP_hammers = IP_hammers[frac_start:frac_end]
    print(IP_hammers)
    print(f'finish generating the {nth}/{frac} frac. of hammers')


    # Retrieve the existing countries
    countries = df['CountryName'].unique()

    # Generate the dates arrays
    no_IP_dates = pd.date_range(start=start_date_no, end=end_date_no)
    IP_dates = pd.date_range(start=start_date, end=end_date)

    # Generate the IP hammers dataframes
    for IP_hammer in IP_hammers:
        IP_hammer_df = pd.DataFrame(columns=df.columns)

        # Obtain which IP and levels are associated to the hammer
        IP_idx = [idx for idx,level in enumerate(IP_hammer) if level != 0]
        IP_idx = IP_idx[0] if len(IP_idx) > 0 else 0
        hammer_IP, hammer_level = IP_COLS[IP_idx], IP_hammer[IP_idx]

        # Print generation process
        IP_spl = hammer_IP.split(" ")[0]
        out_name = f'hammer-dfs-with-HX/hammer-{IP_spl}-level-{hammer_level}-' +\
                         f'sn-{start_date_no}-en-{end_date_no}-' +\
                         f's-{start_date}-e-{end_date}.csv'
        print(f'Generating {out_name}...')

        for country in countries:
            # Country rows without that IP hammer
            country_no_IP = {
                IP_col: [0] * len(no_IP_dates)
                for IP_col in IP_COLS
            }
            country_no_IP['CountryName'] = [country] * len(no_IP_dates)
            country_no_IP['Date'] = no_IP_dates
            country_no_IP_df = pd.DataFrame(country_no_IP)

            # Country rows with that IP hammer
            country_IP = {
                IP_col: [IP_level] * len(IP_dates)
                for IP_col, IP_level in zip(IP_COLS, IP_hammer)
            }
            country_IP['CountryName'] =  [country] * len(IP_dates)
            country_IP['Date'] = IP_dates
            country_IP_df = pd.DataFrame(country_IP)

            # Concatenate the country rows to the IP hammer df
            country_IP_hammer_df = pd.concat([country_no_IP_df, country_IP_df])
            IP_hammer_df = pd.concat([IP_hammer_df, country_IP_hammer_df])


        # Fill NaNs columns, e.g., H3_Contact tracing
        IP_hammer_df.fillna(0)
        print(f'writing {out_name}...')
        IP_hammer_df.to_csv(out_name)



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
    parser.add_argument("-nth", "--nth",
                        dest="nth",
                        type=int,
                        required=True,
                        help="nth/frac fraction of hammers")
    parser.add_argument("-frac", "--frac",
                        dest="frac",
                        type=int,
                        required=True,
                        help="nth/frac fraction of hammers")
    # TODO - let customize the user
    ## parser.add_argument("-o", "--output_dir",
    ##                     dest="output_dir",
    ##                     type=str,
    ##                     required=True,
    ##                     help="Directory to store the resulting Rt files")
    args = parser.parse_args()


    if args.nth >= args.frac:
        print(f'nth={args.nth} must be < frac, which is {args.frac}')
        print('EXIT')
        sys.exit()
        

    if args.hammer_type == 1:
        gen_IP1_hammer_dfs(
                start_date_no=args.start_date_no,
                end_date_no=args.end_date_no,
                start_date=args.start_date,
                end_date=args.end_date,
                nth=args.nth,
                frac=args.frac)
    else:
        print('Not implemented')


