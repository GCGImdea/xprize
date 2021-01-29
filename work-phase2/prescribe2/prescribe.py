# Copyright 2021 (c) R.A. García Leiva (rafael.garcia@imdea.org). IMDEA Networks Institute.

import argparse

import numpy  as np
import pandas as pd

from datetime import date, timedelta

import os

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

ACTION_DURATION = 15

# TODO: Replace with the location at sandbox
predictor       = "/home/rleiva/Projects/Covid19/covid-xprize-1.1.2/covid_xprize/standard_predictor/predict.py"
new_ip_file     = "/home/rleiva/Projects/Covid19/data/new_ip.csv"
threshold_file  = "/home/rleiva/Projects/Covid19/data/dance_threshold50.csv"
tmp_output_file = "/home/rleiva/Projects/Covid19/data/tmp_output_file"

def prescribe(start_date_str: str,
              end_date_str: str,
              path_to_prior_ips_file: str,
              path_to_cost_file: str,
              output_file_path) -> None:

    # Compute prescription time
    start_date = pd.to_datetime(start_date_str, format='%Y-%m-%d')
    end_date   = pd.to_datetime(end_date_str,   format='%Y-%m-%d')
    delta      = end_date - start_date
    num_periods = int( np.ceil( (delta.days) / ACTION_DURATION ) )
    MAX_COST = 12 * 4 * num_periods / 2

    # Load the past IPs data
    past_ips_df = pd.read_csv(path_to_prior_ips_file,
                              parse_dates=['Date'],
                              encoding="ISO-8859-1",
                              error_bad_lines=False)
    final_prescriptions = past_ips_df.copy()    # DF to store results
    past_ips_df['RegionName'] = past_ips_df['RegionName'].fillna("")
    past_ips_df['GeoID'] = past_ips_df['CountryName'] + '__' + past_ips_df['RegionName'].astype(str)
    geos = past_ips_df['GeoID'].unique()

    # Load IP costs to condition prescriptions
    cost_df = pd.read_csv(path_to_cost_file)
    cost_df['RegionName'] = cost_df['RegionName'].fillna("")
    cost_df['GeoID'] = cost_df['CountryName'] + '__' + cost_df['RegionName'].astype(str)
    geo_costs = {}
    for geo in geos:
        costs = cost_df[cost_df['GeoID'] == geo]
        cost_arr = np.array(costs[IP_COLS])[0]
        geo_costs[geo] = cost_arr

    # Used to compute MAX_CASES
    threshold_df = pd.read_csv(threshold_file)

    # TODO: Only used for debugging, remove from production
    results = pd.DataFrame(columns=["Geo", "Period", "Policy", "Cost", "Cases"])

    # For each geographical region
    for geo in geos:

        country_name = geo.split("__")[0]
        region_name  = geo.split("__")[1]

        # TODO: Remove from production
        print("Processing region:", geo)

        best_cost     = np.inf
        best_policies = [0, 0, 0, 0, 0, 0]

        # Rank list of used policies
        ips      = np.array(past_ips_df[past_ips_df['GeoID'] == geo][IP_COLS])
        policies = np.unique(ips, axis=0)
        costs    = geo_costs[geo]
        order    = np.dot(policies, np.transpose(costs)).flatten()
        order    = np.argsort(order)
        policies = policies[order]

        # Compute the maximum number of cases for this region
        if region_name == "":
            population = threshold_df[(threshold_df["CountryName"] == country_name)]["population"].values[0]
        else:
            population = threshold_df[(threshold_df["CountryName"] == country_name) & (threshold_df["RegionName"] == region_name)]["population"].values[0]
        MAX_CASES = (population / 10000) * 50 * delta.days

        # For every period
        for period_id in np.arange(num_periods):

            # For every policy
            for policy_id in np.arange(policies.shape[0]):
        
                # Compute candidate policy
                candidate_policies            = best_policies.copy()
                candidate_policies[period_id] = policy_id
                
                # Compute total costs of measures
                total_cost = 0
                for pid in np.arange(6):
                    policy = policies[candidate_policies[pid]]
                    tmp    = np.dot(costs, policy)
                    tmp    = np.sum(tmp)
                    total_cost = total_cost + tmp
                    
                # Upate the intervention plan

                current_date = start_date
                new_prescriptions = past_ips_df.copy()
        
                # For each period
                for i in np.arange(num_periods):
            
                    policy = policies[candidate_policies[i]]
            
                    # For each day
                    for j in np.arange(ACTION_DURATION):

                        tmp_df = pd.DataFrame({
                            'CountryName'                          : country_name,
                            'RegionName'                           : region_name,
                            'Date'                                 : current_date.strftime("%Y-%m-%d"),
                            'C1_School closing'                    : policy[0],
                            'C2_Workplace closing'                 : policy[1],
                            'C3_Cancel public events'              : policy[2],
                            'C4_Restrictions on gatherings'        : policy[3],
                            'C5_Close public transport'            : policy[4],
                            'C6_Stay at home requirements'         : policy[5],
                            'C7_Restrictions on internal movement' : policy[6],
                            'C8_International travel controls'     : policy[7],
                            'H1_Public information campaigns'      : policy[8],
                            'H2_Testing policy'                    : policy[9],
                            'H3_Contact tracing'                   : policy[10],
                            'H6_Facial Coverings'                  : policy[11]
                        }, index=[0])
                
                        new_prescriptions = pd.concat([new_prescriptions, tmp_df], ignore_index=True)
                
                        current_date = current_date + timedelta(days=1)        
                
                # Save 
                new_prescriptions.to_csv(new_ip_file, index=False)

                # Make predictions
                predict = "python " + predictor + " -s " + start_date.strftime("%Y-%m-%d") + " -e " + end_date.strftime("%Y-%m-%d") + " -ip " + new_ip_file + " -o " + tmp_output_file
                os.system(predict)

                # Load predictions
                predict_df  = pd.read_csv(tmp_output_file)
                predictions = np.array(predict_df["PredictedDailyNewCases"])
                total_pred  = np.sum(predictions)
        
                rel_cost  = total_cost / MAX_COST
                rel_cases = total_pred / MAX_CASES

                # Arithmetic mean
                fitness = (rel_cost + rel_cases) / 2
        
                # TODO: Remove in production
                print("    Period:", period_id, "Policy:", policy_id, "Cost:", rel_cost, "Cases:", rel_cases, "Fitness:", fitness)                        
        
                if fitness < best_cost:
                    best_cost = fitness 
                    best_policies = candidate_policies.copy()
                else:
                    # Early stop
                    break
                    
                # TODO: Only used for debugging, remove from production
                tmp_df = pd.DataFrame({
                    'Geo'    : geo,
                    'Period' : period_id,
                    'Policy' : policy_id,
                    'Cost'   : total_cost,
                    'Cases'  : total_pred
                }, index=[0])
        
                # TODO: Only used for debugging, remove from production
                results = pd.concat([results, tmp_df], ignore_index=True)

        # Save optimal result for this region
        
        current_date = start_date

        for i in np.arange(num_periods):
            
            policy = policies[best_policies[i]]
            
            # For each day
            for j in np.arange(ACTION_DURATION):

                tmp_df = pd.DataFrame({
                    'CountryName'                          : country_name,
                    'RegionName'                           : region_name,
                    'Date'                                 : current_date.strftime("%Y-%m-%d"),
                    'C1_School closing'                    : policy[0],
                    'C2_Workplace closing'                 : policy[1],
                    'C3_Cancel public events'              : policy[2],
                    'C4_Restrictions on gatherings'        : policy[3],
                    'C5_Close public transport'            : policy[4],
                    'C6_Stay at home requirements'         : policy[5],
                    'C7_Restrictions on internal movement' : policy[6],
                    'C8_International travel controls'     : policy[7],
                    'H1_Public information campaigns'      : policy[8],
                    'H2_Testing policy'                    : policy[9],
                    'H3_Contact tracing'                   : policy[10],
                    'H6_Facial Coverings'                  : policy[11]
                }, index=[0])
                
                final_prescriptions = pd.concat([final_prescriptions, tmp_df], ignore_index=True)
                
                current_date = current_date + timedelta(days=1)

    # TODO: Only used for debugging, remove from production
    results.to_csv("/home/rleiva/Projects/Covid19/data/results.csv", header=True, index=False)

    # Save final predictions
    final_prescriptions.to_csv(output_file_path, header=True, index=False)


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

