
# Oxford data
ox_data <- c(
  "date",
  # "countryname", # Constant for a country/region
  # "countrycode", # Constant for a country/region
  # "regionname", # Constant for a country/region
  # "regioncode", # Constant for a country/region
  # "iso2", # Constant for a country/region
  # "jurisdiction", # Constant for a country/region
  # "population", # Constant for a country/region
  "confirmedcases", # Cumulative cases
  "confirmeddeaths", # Cumulative fatalities
  "cases", # Daily new cases
  "deaths",  # Daily new fatalities
  "avgcases7days", # 7 day rolling average of cases
  "avgdeaths7days",  # 7 day rolling average of deaths
  "cases_delta", # Daily difference of cases
  "deaths_delta", # Daily difference of deaths
  "avgcases7days_delta", # Daily difference of avgcases7days
  "avgdeaths7days_delta", # Daily difference of avgdeaths7days
  "c1_school.closing",
#  "c1_flag", # Redundant (says whether the previous one is 0 or not)
  "c2_workplace.closing",
#  "c2_flag", # Redundant (says whether the previous one is 0 or not)
  "c3_cancel.public.events",
#  "c3_flag", # Redundant (says whether the previous one is 0 or not)
  "c4_restrictions.on.gatherings",
#  "c4_flag", # Redundant (says whether the previous one is 0 or not)
  "c5_close.public.transport",
#  "c5_flag", # Redundant (says whether the previous one is 0 or not)
  "c6_stay.at.home.requirements",
#  "c6_flag", # Redundant (says whether the previous one is 0 or not)
  "c7_restrictions.on.internal.movement",
#  "c7_flag", # Redundant (says whether the previous one is 0 or not)
  "c8_international.travel.controls",
  "e1_income.support",
#  "e1_flag", # Redundant (says whether the previous one is 0 or not)
  "e2_debt.contract.relief",
  "e3_fiscal.measures",
  "e4_international.support",
  "h1_public.information.campaigns",
#  "h1_flag", # Redundant (says whether the previous one is 0 or not)
  "h2_testing.policy",
  "h3_contact.tracing",
  "h4_emergency.investment.in.healthcare",
  "h5_investment.in.vaccines",
  "h6_facial.coverings",
#  "h6_flag", # Redundant (says whether the previous one is 0 or not)
  "h7_vaccination.policy",
#  "h7_flag", # Redundant (says whether the previous one is 0 or not)
  "m1_wildcard",
  "stringencyindex",
  "stringencyindexfordisplay",
  "stringencylegacyindex",
  "stringencylegacyindexfordisplay",
  "governmentresponseindex",
  "governmentresponseindexfordisplay",
  "containmenthealthindex",
  "containmenthealthindexfordisplay",
  "economicsupportindex",
  "economicsupportindexfordisplay"
)

# Our World in Data data
owid_data <- c(
#"owid_iso_code", # Constant for a country/region
#"owid_continent", # Constant for a country/region
#"owid_location", # Constant for a country/region
#"owid_date", # Redundant
#"owid_total_cases", # Redundant
#"owid_new_cases", # Redundant
#"owid_new_cases_smoothed", # Redundant
#"owid_total_deaths", # Redundant
#"owid_new_deaths", # Redundant
#"owid_new_deaths_smoothed", # Redundant
"owid_total_cases_per_million",
"owid_new_cases_per_million",
"owid_new_cases_smoothed_per_million",
"owid_total_deaths_per_million",
"owid_new_deaths_per_million",
"owid_new_deaths_smoothed_per_million",
"owid_reproduction_rate",
"owid_icu_patients",
"owid_icu_patients_per_million",
"owid_hosp_patients",
"owid_hosp_patients_per_million",
"owid_weekly_icu_admissions",
"owid_weekly_icu_admissions_per_million",
"owid_weekly_hosp_admissions",
"owid_weekly_hosp_admissions_per_million",
"owid_new_tests",
"owid_total_tests",
"owid_total_tests_per_thousand",
"owid_new_tests_per_thousand",
"owid_new_tests_smoothed",
"owid_new_tests_smoothed_per_thousand",
"owid_positive_rate",
"owid_tests_per_case",
"owid_tests_units",
"owid_total_vaccinations",
"owid_total_vaccinations_per_hundred",
"owid_stringency_index",
"owid_population",  # Redundant
"owid_population_density", 
"owid_median_age",
"owid_aged_65_older",
"owid_aged_70_older",
"owid_gdp_per_capita",
"owid_extreme_poverty",
"owid_cardiovasc_death_rate",
"owid_diabetes_prevalence",
"owid_female_smokers",
"owid_male_smokers",
"owid_handwashing_facilities",
"owid_hospital_beds_per_thousand",
"owid_life_expectancy",
"owid_human_development_index"
)

# Confirmed data from ECDC
conf_data <- c(
# "conf_date", # Redundant
# "conf_countrycode2", # Constant for a country/region
# "conf_population", # Constant for a country/region
# "conf_cases", # Redundant
# "conf_deaths", # Redundant
# "conf_cases_prev_week", # Redundant
# "conf_deaths_prev_week", # Redundant
# "conf_cases_infected", # Redundant
# "conf_cum_deaths", # Redundant
"conf_cases_contagious",
"conf_cases_active",
"conf_p_cases_infected",
"conf_p_cases",
"conf_p_cases_contagious",
"conf_p_cases_active"
)

# CCFR estimates
ccfr_data <- c(
# "ccfr_date", # Redundant
# "ccfr_countrycode", # Constant for a country/region
# "ccfr_population", # Constant for a country/region
# "ccfr_cases", # Redundant
# "ccfr_deaths", # Redundant
# "ccfr_cum_cases", # Redundant
# "ccfr_cum_deaths", # Redundant
"ccfr_cases_infected",
"ccfr_cases_infected_low",
"ccfr_cases_infected_high",
"ccfr_cases_daily",
"ccfr_cases_contagious",
"ccfr_cases_active",
"ccfr_p_cases_infected",
"ccfr_p_cases_infected_low",
"ccfr_p_cases_infected_high",
"ccfr_p_cases_daily",
"ccfr_p_cases_contagious",
"ccfr_p_cases_active"
)

# Hospital data from ECDC
hosp_data <- c(
"hosp_year_week",
# "hosp_date",  # Redundant
# "hosp_countrycode", # Constant for a country/region
# "hosp_countryname", # Constant for a country/region
"hosp_hosp_occupancy",
"hosp_icu_occupancy",
"hosp_hosp_weekly_admission",
"hosp_icu_weekly_admission"
)

# Estimates from the CoronaSurveys poll
W_data <- c(
# "W_date", # Redundant
"W_p_cases",
"W_p_cases_recent",
"W_p_cases_fatalities",
"W_p_cases_stillsick"
)

W_data_smooth <- c(
  "W_p_cases_smooth",
  "W_p_cases_smooth_low",
  "W_p_cases_smooth_high",
  "W_p_cases_fatalities_smooth",
  "W_p_cases_fatalities_smooth_low",
  "W_p_cases_fatalities_smooth_high",
  "W_p_cases_recent_smooth",
  "W_p_cases_recent_smooth_low",
  "W_p_cases_recent_smooth_high",
  "W_p_cases_stillsick_smooth",
  "W_p_cases_stillsick_smooth_low",
  "W_p_cases_stillsick_smooth_high"
)

# Data from UMD Symptom Survey via API
umdapi_data <- c(
#"umdapi_date", # Redundant
#"umdapi_iso_code", # Constant for a country/region
#"umdapi_country", # Constant for a country/region
#"umdapi_population", # Redundant
"umdapi_sample_size",
"umdapi_percent_cli",
"umdapi_cli_se",
"umdapi_percent_cli_unw",
"umdapi_cli_se_unw",
"umdapi_percent_ili",
"umdapi_ili_se",
"umdapi_percent_ili_unw",
"umdapi_ili_se_unw",
"umdapi_percent_mc",
"umdapi_mc_se",
"umdapi_percent_mc_unw",
"umdapi_mc_se_unw",
"umdapi_percent_dc",
"umdapi_dc_se",
"umdapi_percent_dc_unw",
"umdapi_dc_se_unw",
"umdapi_percent_hf",
"umdapi_hf_se",
"umdapi_percent_hf_unw",
"umdapi_hf_se_unw"
)

umdapi_data_smooth <- c(
"umdapi_percent_cli_smooth",
"umdapi_percent_cli_smooth_low",
"umdapi_percent_cli_smooth_high",
"umdapi_percent_cli_unw_smooth",
"umdapi_percent_cli_unw_smooth_low",
"umdapi_percent_cli_unw_smooth_high",
"umdapi_percent_ili_smooth",
"umdapi_percent_ili_smooth_low",
"umdapi_percent_ili_smooth_high",
"umdapi_percent_ili_unw_smooth",
"umdapi_percent_ili_unw_smooth_low",
"umdapi_percent_ili_unw_smooth_high",
"umdapi_percent_mc_smooth",
"umdapi_percent_mc_smooth_low",
"umdapi_percent_mc_smooth_high",
"umdapi_percent_mc_unw_smooth",
"umdapi_percent_mc_unw_smooth_low",
"umdapi_percent_mc_unw_smooth_high",
"umdapi_percent_dc_smooth",
"umdapi_percent_dc_smooth_low",
"umdapi_percent_dc_smooth_high",
"umdapi_percent_dc_unw_smooth",
"umdapi_percent_dc_unw_smooth_low",
"umdapi_percent_dc_unw_smooth_high",
"umdapi_percent_hf_smooth",
"umdapi_percent_hf_smooth_low",
"umdapi_percent_hf_smooth_high",
"umdapi_percent_hf_unw_smooth",
"umdapi_percent_hf_unw_smooth_low",
"umdapi_percent_hf_unw_smooth_high"
)

# Data from UMD Symptom Survey via Challenge
umdchl_data <- c(
# "umdchl_date", # Redundant
# "umdchl_population", # Redundant
"umdchl_total_responses",
"umdchl_pct_cli",
"umdchl_pct_ili",
"umdchl_pct_fever",
"umdchl_pct_cough",
"umdchl_pct_difficulty_breathing",
"umdchl_pct_fatigue",
"umdchl_pct_stuffy_runny_nose",
"umdchl_pct_aches_muscle_pain",
"umdchl_pct_sore_throat",
"umdchl_pct_chest_pain",
"umdchl_pct_nausea",
"umdchl_pct_anosmia_ageusia",
"umdchl_pct_eye_pain",
"umdchl_pct_headache",
"umdchl_pct_cmnty_sick",
"umdchl_pct_ever_tested",
"umdchl_pct_tested_recently",
"umdchl_pct_worked_outside_home",
"umdchl_pct_grocery_outside_home",
"umdchl_pct_ate_outside_home",
"umdchl_pct_spent_time_with_non_hh",
"umdchl_pct_attended_public_event",
"umdchl_pct_used_public_transit",
"umdchl_pct_direct_contact_with_non_hh",
"umdchl_pct_wear_mask_all_time",
"umdchl_pct_wear_mask_most_time",
"umdchl_pct_wear_mask_half_time",
"umdchl_pct_wear_mask_some_time",
"umdchl_pct_wear_mask_none_time",
"umdchl_pct_no_public",
"umdchl_pct_feel_nervous_all_time",
"umdchl_pct_feel_nervous_most_time",
"umdchl_pct_feel_nervous_some_time",
"umdchl_pct_feel_nervous_little_time",
"umdchl_pct_feel_nervous_none_time",
"umdchl_pct_feel_depressed_all_time",
"umdchl_pct_feel_depressed_most_time",
"umdchl_pct_feel_depressed_some_time",
"umdchl_pct_feel_depressed_little_time",
"umdchl_pct_feel_depressed_none_time",
"umdchl_pct_worried_ill_covid19_very",
"umdchl_pct_worried_ill_covid19_somewhat",
"umdchl_pct_worried_ill_covid19_nottooworried",
"umdchl_pct_worried_ill_covid19_notworried",
"umdchl_pct_enough_toeat_very_worried",
"umdchl_pct_enough_toeat_somewhat_worried",
"umdchl_pct_enough_toeat_nottoo_worried",
"umdchl_pct_enough_toeat_not_worried",
"umdchl_pct_chills",
"umdchl_pct_finances_very_worried",
"umdchl_pct_finances_somewhat_worried",
"umdchl_pct_finances_nottoo_worried",
"umdchl_pct_finances_not_worried"
)

umdchl_data_smooth <- c(
"umdchl_pct_cli_smooth",
"umdchl_pct_cli_smooth_low",
"umdchl_pct_cli_smooth_high",
"umdchl_pct_ili_smooth",
"umdchl_pct_ili_smooth_low",
"umdchl_pct_ili_smooth_high",
"umdchl_pct_fever_smooth",
"umdchl_pct_fever_smooth_low",
"umdchl_pct_fever_smooth_high",
"umdchl_pct_cough_smooth",
"umdchl_pct_cough_smooth_low",
"umdchl_pct_cough_smooth_high",
"umdchl_pct_difficulty_breathing_smooth",
"umdchl_pct_difficulty_breathing_smooth_low",
"umdchl_pct_difficulty_breathing_smooth_high",
"umdchl_pct_fatigue_smooth",
"umdchl_pct_fatigue_smooth_low",
"umdchl_pct_fatigue_smooth_high",
"umdchl_pct_stuffy_runny_nose_smooth",
"umdchl_pct_stuffy_runny_nose_smooth_low",
"umdchl_pct_stuffy_runny_nose_smooth_high",
"umdchl_pct_aches_muscle_pain_smooth",
"umdchl_pct_aches_muscle_pain_smooth_low",
"umdchl_pct_aches_muscle_pain_smooth_high",
"umdchl_pct_sore_throat_smooth",
"umdchl_pct_sore_throat_smooth_low",
"umdchl_pct_sore_throat_smooth_high",
"umdchl_pct_chest_pain_smooth",
"umdchl_pct_chest_pain_smooth_low",
"umdchl_pct_chest_pain_smooth_high",
"umdchl_pct_nausea_smooth",
"umdchl_pct_nausea_smooth_low",
"umdchl_pct_nausea_smooth_high",
"umdchl_pct_anosmia_ageusia_smooth",
"umdchl_pct_anosmia_ageusia_smooth_low",
"umdchl_pct_anosmia_ageusia_smooth_high",
"umdchl_pct_eye_pain_smooth",
"umdchl_pct_eye_pain_smooth_low",
"umdchl_pct_eye_pain_smooth_high",
"umdchl_pct_headache_smooth",
"umdchl_pct_headache_smooth_low",
"umdchl_pct_headache_smooth_high",
"umdchl_pct_cmnty_sick_smooth",
"umdchl_pct_cmnty_sick_smooth_low",
"umdchl_pct_cmnty_sick_smooth_high",
"umdchl_pct_ever_tested_smooth",
"umdchl_pct_ever_tested_smooth_low",
"umdchl_pct_ever_tested_smooth_high",
"umdchl_pct_tested_recently_smooth",
"umdchl_pct_tested_recently_smooth_low",
"umdchl_pct_tested_recently_smooth_high",
"umdchl_pct_worked_outside_home_smooth",
"umdchl_pct_worked_outside_home_smooth_low",
"umdchl_pct_worked_outside_home_smooth_high",
"umdchl_pct_grocery_outside_home_smooth",
"umdchl_pct_grocery_outside_home_smooth_low",
"umdchl_pct_grocery_outside_home_smooth_high",
"umdchl_pct_ate_outside_home_smooth",
"umdchl_pct_ate_outside_home_smooth_low",
"umdchl_pct_ate_outside_home_smooth_high",
"umdchl_pct_spent_time_with_non_hh_smooth",
"umdchl_pct_spent_time_with_non_hh_smooth_low",
"umdchl_pct_spent_time_with_non_hh_smooth_high",
"umdchl_pct_attended_public_event_smooth",
"umdchl_pct_attended_public_event_smooth_low",
"umdchl_pct_attended_public_event_smooth_high",
"umdchl_pct_used_public_transit_smooth",
"umdchl_pct_used_public_transit_smooth_low",
"umdchl_pct_used_public_transit_smooth_high",
"umdchl_pct_direct_contact_with_non_hh_smooth",
"umdchl_pct_direct_contact_with_non_hh_smooth_low",
"umdchl_pct_direct_contact_with_non_hh_smooth_high",
"umdchl_pct_wear_mask_all_time_smooth",
"umdchl_pct_wear_mask_all_time_smooth_low",
"umdchl_pct_wear_mask_all_time_smooth_high",
"umdchl_pct_wear_mask_most_time_smooth",
"umdchl_pct_wear_mask_most_time_smooth_low",
"umdchl_pct_wear_mask_most_time_smooth_high",
"umdchl_pct_wear_mask_half_time_smooth",
"umdchl_pct_wear_mask_half_time_smooth_low",
"umdchl_pct_wear_mask_half_time_smooth_high",
"umdchl_pct_wear_mask_some_time_smooth",
"umdchl_pct_wear_mask_some_time_smooth_low",
"umdchl_pct_wear_mask_some_time_smooth_high",
"umdchl_pct_wear_mask_none_time_smooth",
"umdchl_pct_wear_mask_none_time_smooth_low",
"umdchl_pct_wear_mask_none_time_smooth_high",
"umdchl_pct_no_public_smooth",
"umdchl_pct_no_public_smooth_low",
"umdchl_pct_no_public_smooth_high",
"umdchl_pct_feel_nervous_all_time_smooth",
"umdchl_pct_feel_nervous_all_time_smooth_low",
"umdchl_pct_feel_nervous_all_time_smooth_high",
"umdchl_pct_feel_nervous_most_time_smooth",
"umdchl_pct_feel_nervous_most_time_smooth_low",
"umdchl_pct_feel_nervous_most_time_smooth_high",
"umdchl_pct_feel_nervous_some_time_smooth",
"umdchl_pct_feel_nervous_some_time_smooth_low",
"umdchl_pct_feel_nervous_some_time_smooth_high",
"umdchl_pct_feel_nervous_little_time_smooth",
"umdchl_pct_feel_nervous_little_time_smooth_low",
"umdchl_pct_feel_nervous_little_time_smooth_high",
"umdchl_pct_feel_nervous_none_time_smooth",
"umdchl_pct_feel_nervous_none_time_smooth_low",
"umdchl_pct_feel_nervous_none_time_smooth_high",
"umdchl_pct_feel_depressed_all_time_smooth",
"umdchl_pct_feel_depressed_all_time_smooth_low",
"umdchl_pct_feel_depressed_all_time_smooth_high",
"umdchl_pct_feel_depressed_most_time_smooth",
"umdchl_pct_feel_depressed_most_time_smooth_low",
"umdchl_pct_feel_depressed_most_time_smooth_high",
"umdchl_pct_feel_depressed_some_time_smooth",
"umdchl_pct_feel_depressed_some_time_smooth_low",
"umdchl_pct_feel_depressed_some_time_smooth_high",
"umdchl_pct_feel_depressed_little_time_smooth",
"umdchl_pct_feel_depressed_little_time_smooth_low",
"umdchl_pct_feel_depressed_little_time_smooth_high",
"umdchl_pct_feel_depressed_none_time_smooth",
"umdchl_pct_feel_depressed_none_time_smooth_low",
"umdchl_pct_feel_depressed_none_time_smooth_high",
"umdchl_pct_worried_ill_covid19_very_smooth",
"umdchl_pct_worried_ill_covid19_very_smooth_low",
"umdchl_pct_worried_ill_covid19_very_smooth_high",
"umdchl_pct_worried_ill_covid19_somewhat_smooth",
"umdchl_pct_worried_ill_covid19_somewhat_smooth_low",
"umdchl_pct_worried_ill_covid19_somewhat_smooth_high",
"umdchl_pct_worried_ill_covid19_nottooworried_smooth",
"umdchl_pct_worried_ill_covid19_nottooworried_smooth_low",
"umdchl_pct_worried_ill_covid19_nottooworried_smooth_high",
"umdchl_pct_worried_ill_covid19_notworried_smooth",
"umdchl_pct_worried_ill_covid19_notworried_smooth_low",
"umdchl_pct_worried_ill_covid19_notworried_smooth_high",
"umdchl_pct_enough_toeat_very_worried_smooth",
"umdchl_pct_enough_toeat_very_worried_smooth_low",
"umdchl_pct_enough_toeat_very_worried_smooth_high",
"umdchl_pct_enough_toeat_somewhat_worried_smooth",
"umdchl_pct_enough_toeat_somewhat_worried_smooth_low",
"umdchl_pct_enough_toeat_somewhat_worried_smooth_high",
"umdchl_pct_enough_toeat_nottoo_worried_smooth",
"umdchl_pct_enough_toeat_nottoo_worried_smooth_low",
"umdchl_pct_enough_toeat_nottoo_worried_smooth_high",
"umdchl_pct_enough_toeat_not_worried_smooth",
"umdchl_pct_enough_toeat_not_worried_smooth_low",
"umdchl_pct_enough_toeat_not_worried_smooth_high",
"umdchl_pct_chills_smooth",
"umdchl_pct_chills_smooth_low",
"umdchl_pct_chills_smooth_high",
"umdchl_pct_finances_very_worried_smooth",
"umdchl_pct_finances_very_worried_smooth_low",
"umdchl_pct_finances_very_worried_smooth_high",
"umdchl_pct_finances_somewhat_worried_smooth",
"umdchl_pct_finances_somewhat_worried_smooth_low",
"umdchl_pct_finances_somewhat_worried_smooth_high",
"umdchl_pct_finances_nottoo_worried_smooth",
"umdchl_pct_finances_nottoo_worried_smooth_low",
"umdchl_pct_finances_nottoo_worried_smooth_high",
"umdchl_pct_finances_not_worried_smooth",
"umdchl_pct_finances_not_worried_smooth_low",
"umdchl_pct_finances_not_worried_smooth_high"
)

cmu_data <- c(
# "cmu_date", # Redundant
# "cmu_iso2", # Constant for a country/region
"cmu_raw_cli",
"cmu_smoothed_cli",
"cmu_raw_ili",
"cmu_smoothed_ili",
"cmu_raw_wcli",
"cmu_smoothed_wcli",
"cmu_raw_wili",
"cmu_smoothed_wili",
"cmu_raw_hh_cmnty_cli",
"cmu_smoothed_hh_cmnty_cli",
"cmu_raw_nohh_cmnty_cli",
"cmu_smoothed_nohh_cmnty_cli",
"cmu_smoothed_wearing_mask",
"cmu_smoothed_others_masked",
"cmu_smoothed_travel_outside_state_5d",
"cmu_smoothed_work_outside_home_1d",
"cmu_smoothed_shop_1d",
"cmu_smoothed_restaurant_1d",
"cmu_smoothed_spent_time_1d",
"cmu_smoothed_large_event_1d",
"cmu_smoothed_public_transit_1d",
"cmu_smoothed_tested_14d",
"cmu_smoothed_tested_positive_14d",
"cmu_smoothed_wanted_test_14d",
"cmu_smoothed_anxious_5d",
"cmu_smoothed_depressed_5d",
"cmu_smoothed_felt_isolated_5d",
"cmu_smoothed_worried_become_ill",
"cmu_smoothed_worried_finances"
)

# Google mobility data
gmob_data <- c(
#"gmob_country_region_code", # Constant for a country/region
#"gmob_country_region", # Constant for a country/region
#"gmob_sub_region_1", # Constant for a country/region
#"gmob_sub_region_2", # Constant for a country/region
#"gmob_metro_area", # Constant for a country/region
#"gmob_iso_3166_2_code", # Constant for a country/region
#"gmob_census_fips_code",  # Constant for a country/region
#"gmob_date",  # Redundant
"gmob_retail_and_recreation_percent_change_from_baseline",
"gmob_grocery_and_pharmacy_percent_change_from_baseline",
"gmob_parks_percent_change_from_baseline",
"gmob_transit_stations_percent_change_from_baseline",
"gmob_workplaces_percent_change_from_baseline",
"gmob_residential_percent_change_from_baseline"
)
