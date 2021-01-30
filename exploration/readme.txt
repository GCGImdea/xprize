folders:
- processed: folders and files used to generate scenarios already processed
- ips-vectors: intervention plans already processed. One line per country dated 2020-01-01.
- ips-vectors-full: intervention plans already processed. For each country/region has lines with no intervention from 2020-11-01 to 2020-12-31, and the corresponding intervention plan from 2021-01-01 to 2021-02-28. The name of each fie is the same as in ips-vectors.
- predictions-raw: results of simulating the plans in ips-vectors-full. One file for each file in ips-vectors-full, with the same lines. A prefix "predicted-" is added to the name. For each country/region and date it has the predicted number of cases.
- predictions-with-Rt: processing of the predictions-raw, adding for each country/region and date the 7-day rolling average of the predicted cases, daily ratio, and Rt.
- scenarios-to-simulate: pending scenarios to be simulated.
