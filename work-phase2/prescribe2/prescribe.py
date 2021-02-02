# Copyright 2021 (c) IMDEA Networks Institute.

#
# Loss function
#
# num_periods = int( np.ceil( (end_date - start_date) / ACTION_DURATION ) )
#
# MAX_COST  = 12 * 4 / 2
# MAX_CASES = (population / 10000) * 10 * (end_date - start_date)
#
# total_cost = sum_regions sum_periods inner_product (costs_region * candidate_policy)
# total_pred = sum_regions sum_days cases
#
# rel_cost  = total_cost / MAX_COST  / num_regions
# rel_cases = total_pred / MAX_CASES / num_regions
#

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

ACTION_DURATION  = 15 # Duration of the policies in days

regions_file    = "countries_regions.csv"
threshold_file  = "dance_threshold50.csv"
ratios_file     = "ratios.csv"
num_cases_file  = "numcases.csv"

def prescribe(start_date_str: str,
              end_date_str: str,
              path_to_prior_ips_file: str,
              path_to_cost_file: str,
              output_file_path) -> None:

    # Compute prescription time
    start_date  = pd.to_datetime(start_date_str, format='%Y-%m-%d')
    end_date    = pd.to_datetime(end_date_str,   format='%Y-%m-%d')
    num_days    = (end_date - start_date).days
    num_periods = int( np.ceil( (num_days) / ACTION_DURATION ) )

    # Maximum cost per day
    MAX_COST = 12 * 4 / 2

    # Load list of regions
    regions_df = pd.read_csv(regions_file)
    regions_df['RegionName'] = regions_df['RegionName'].fillna("")
    regions_df['GeoID'] = regions_df['CountryName'] + '__' + regions_df['RegionName'].astype(str)
    geos = regions_df['GeoID'].unique()

    # Load IP costs to condition prescriptions
    cost_df = pd.read_csv(path_to_cost_file)
    cost_df['RegionName'] = cost_df['RegionName'].fillna("")
    cost_df['GeoID'] = cost_df['CountryName'] + '__' + cost_df['RegionName'].astype(str)
    geo_costs = {}
    for geo in geos:
        costs = cost_df[cost_df['GeoID'] == geo]
        cost_arr = np.array(costs[IP_COLS])[0]
        geo_costs[geo] = cost_arr

    # Load ratios data
    ratios_df = pd.read_csv(ratios_file)
    ratios_df['RegionName'] = ratios_df['RegionName'].fillna("")
    ratios_df['GeoID'] = ratios_df['CountryName'] + '__' + ratios_df['RegionName'].astype(str)

    # Compute simulated policies for all regions
    # TODO: Deal with contradictory entries
    geo_policies = {}
    for geo in geos:
        # Rank list of simulated policies
        ips      = np.array(ratios_df[ratios_df['GeoID'] == geo][IP_COLS])
        policies = np.unique(ips, axis=0)
        costs    = geo_costs[geo]
        order    = np.dot(policies, np.transpose(costs)).flatten()
        order    = np.argsort(order)
        policies = policies[order]
        ratios   = np.array(ratios_df[ratios_df['GeoID'] == geo]["avg_ratio"])
        ratios   = ratios[order]
        geo_policies[geo] = {"policies" : policies,
                             "ratios"   : ratios}

    # print("N. Policies:", len(geo_policies))
    # print("Policy: ", geo_policies["Afghanistan__"]["policies"][0])
    # print("Ratio: ",  geo_policies["Afghanistan__"]["ratios"][0])
    # print("Policy: ", geo_policies["Afghanistan__"]["policies"][-1])
    # print("Ratio: ",  geo_policies["Afghanistan__"]["ratios"][-1])
    # return

    # Compute MAX_CASES for all regions
    threshold_df  = pd.read_csv(threshold_file)
    geo_max_cases = {}
    for geo in geos:
        country_name = geo.split("__")[0]
        region_name  = geo.split("__")[1]
        # Compute the maximum number of cases for this region
        if region_name == "":
            population = threshold_df[(threshold_df["CountryName"] == country_name)]["population"].values[0]
        else:
            population = threshold_df[(threshold_df["CountryName"] == country_name) & (threshold_df["RegionName"] == region_name)]["population"].values[0]           
        MAX_CASES = (population / 10000) * 10
        geo_max_cases[geo] = MAX_CASES

    # Load current cases
    cases_df = pd.read_csv(num_cases_file, parse_dates=['Date'])
    cases_df['RegionName'] = cases_df['RegionName'].fillna("")
    cases_df['GeoID'] = cases_df['CountryName'] + '__' + cases_df['RegionName'].astype(str)
    geo_cases = {}
    for geo in geos:
        cases = cases_df[(cases_df['GeoID'] == "Afghanistan__") & (cases_df['Date'] == "2020-08-01")]['PredictedDailyNewCases'].values[0]
        geo_cases[geo] = cases

    # TODO: Only used for debugging, remove from production
    results = pd.DataFrame(columns=["Region", "Period", "Policy", "Cost", "Cases"])

    # For every geographical region
    for geo in geos:

        # TODO: Remove from production
        print("Processing region:", geo)

        country_name = geo.split("__")[0]
        region_name  = geo.split("__")[1]

         # Ranked list of used policies and their rate
        policies = geo_policies[geo]["policies"]
        ratios   = geo_policies[geo]["ratios"]

        # Cases for this region
        num_cases = geo_cases[geo]
        MAX_CASES = geo_max_cases[geo]

        # For every period
        for period_id in np.arange(num_periods):

            # TODO: Remove from production
            print("    Processing period:", period_id)

            best_cost     = np.inf
            best_policies = [0] * num_periods

            # For every policy
            for policy_id in np.arange(len(policies)):

                # TODO: Remove from production
                print("        Processing policy:", policy_id)

                total_cost  = 0
                total_cases = 0

                # Compute candidate policy
                candidate_policies            = best_policies.copy()
                candidate_policies[period_id] = policy_id

                # Compute total costs of measures
                costs = geo_costs[geo]
                for pid in np.arange(num_periods):
                    policy = policies[candidate_policies[pid]]
                    tmp    = np.dot(costs, policy)
                    tmp    = np.sum(tmp)
                    total_cost = total_cost + tmp * ACTION_DURATION
                    
                # Compute total number of cases
                for pid in np.arange(num_periods):
                    rate = ratios[candidate_policies[pid]]
                    tmp  = rate ** ACTION_DURATION
                    tmp  = rate * num_cases
                    total_cases = total_cases + tmp

                rel_cost  = total_cost / MAX_COST /  len(geos)
                rel_cases = total_cases / MAX_CASES / len(geos)

                # Arithmetic mean
                fitness = (rel_cost + rel_cases) / 2
        
                # TODO: Remove in production
                print("    Period:", period_id, "Policy:", policy_id, "Cost:", rel_cost, "Cases:", rel_cases, "Fitness:", fitness)                        
        
                if fitness < best_cost:
                    best_cost = fitness 
                    best_policies = candidate_policies.copy()
                    
            # TODO: Only used for debugging, remove from production
            tmp_df = pd.DataFrame({
                    'Region' : geo,
                    'Period' : period_id,
                    'Policy' : policy_id,
                    'Cost'   : total_cost,
                    'Cases'  : total_cases
            }, index=[0])
        
            # TODO: Only used for debugging, remove from production
            results = pd.concat([results, tmp_df], ignore_index=True)

        # Save optimal results
        for geo in geos:

            country_name = geo.split("__")[0]
            region_name  = geo.split("__")[1]
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
