library(dplyr)
library(stringr)

ox_country_path <- "../data/oxford/country/" # Oxford data
confirmed_country_path <- "../data/estimates-confirmed/" # Confirmed data from ECDC
ccfr_country_path <- "../data/estimates-ccfr-based/" # CCFR estimates
hospital_country_path <- "../data/estimates-confirmed-hospital/" # Hospital data from ECDC
W_country_path <- "../data/estimates-W/past_smooth/" # Estimates from the CoronaSurveys poll
umd_api_country_path <- "../data/estimates-umd-symptom-survey/" # Data from UMD Symptom Survey via API
umd_challenge_country_path <- "../data/estimates-umd-unbatched/PlotData/" # Data from UMD Symptom Survey via Challenge

output_path <- "../data/all_giant_df2/"

start_date <- "2020-01-01"

#countryname.x	countrycode.x	regionname	regioncode	jurisdiction	date	c1_school.closing	c1_flag	c2_workplace.closing	c2_flag	c3_cancel.public.events	c3_flag	c4_restrictions.on.gatherings	c4_flag	c5_close.public.transport	c5_flag	c6_stay.at.home.requirements	c6_flag	c7_restrictions.on.internal.movement	c7_flag	c8_international.travel.controls	e1_income.support	e1_flag	e2_debt.contract.relief	e3_fiscal.measures	e4_international.support	h1_public.information.campaigns	h1_flag	h2_testing.policy	h3_contact.tracing	h4_emergency.investment.in.healthcare	h5_investment.in.vaccines	h6_facial.coverings	h6_flag	h7_vaccination.policy	h7_flag	m1_wildcard	confirmedcases	confirmeddeaths	stringencyindex	stringencyindexfordisplay	stringencylegacyindex	stringencylegacyindexfordisplay	governmentresponseindex	governmentresponseindexfordisplay	containmenthealthindex	containmenthealthindexfordisplay	economicsupportindex	economicsupportindexfordisplay	countrycode2	population.x	cases.x	deaths.x	cases_prev_week	deaths_prev_week.x	cases_infected.x	cum_deaths.x	cases_contagious.x	cases_active.x	p_cases_infected.x	p_cases.x	p_cases_contagious.x	p_cases_active.x	countrycode.y	population.y	cases.y	deaths.y	cum_cases	cum_deaths.y	deaths_prev_week.y	cases_infected.y	cases_infected_low	cases_infected_high	cases_daily	cases_contagious.y	cases_active.y	p_cases_infected.y	p_cases_infected_low	p_cases_infected_high	p_cases_daily	p_cases_contagious.y	p_cases_active.y	year_week	countrycode	countryname.y	hosp_occupancy	icu_occupancy	hosp_weekly_admission	icu_weekly_admission	p_cases.y	p_cases_recent	p_cases_fatalities	p_cases_stillsick	p_cases_past_smooth	p_cases_recent_past_smooth	p_cases_stillsick_past_smooth	iso_code	country	sample_size	percent_cli	cli_se	percent_cli_unw	cli_se_unw	percent_ili	ili_se	percent_ili_unw	ili_se_unw	percent_mc	mc_se	percent_mc_unw	mc_se_unw	percent_dc	dc_se	percent_dc_unw	dc_se_unw	percent_hf	hf_se	percent_hf_unw	hf_se_unw	percent_cli_past_smooth	percent_cli_unw_past_smooth	percent_ili_past_smooth	percent_ili_unw_past_smooth	percent_mc_past_smooth	percent_mc_unw_past_smooth	percent_dc_past_smooth	percent_dc_unw_past_smooth	percent_hf_past_smooth	percent_hf_unw_past_smooth	population.x.x	total_responses	pct_cli	pct_ili	pct_fever	pct_cough	pct_difficulty_breathing	pct_fatigue	pct_stuffy_runny_nose	pct_aches_muscle_pain	pct_sore_throat	pct_chest_pain	pct_nausea	pct_anosmia_ageusia	pct_eye_pain	pct_headache	pct_cmnty_sick	pct_ever_tested	pct_tested_recently	pct_worked_outside_home	pct_grocery_outside_home	pct_ate_outside_home	pct_spent_time_with_non_hh	pct_attended_public_event	pct_used_public_transit	pct_direct_contact_with_non_hh	pct_wear_mask_all_time	pct_wear_mask_most_time	pct_wear_mask_half_time	pct_wear_mask_some_time	pct_wear_mask_none_time	pct_no_public	pct_feel_nervous_all_time	pct_feel_nervous_most_time	pct_feel_nervous_some_time	pct_feel_nervous_little_time	pct_feel_nervous_none_time	pct_feel_depressed_all_time	pct_feel_depressed_most_time	pct_feel_depressed_some_time	pct_feel_depressed_little_time	pct_feel_depressed_none_time	pct_worried_ill_covid19_very	pct_worried_ill_covid19_somewhat	pct_worried_ill_covid19_nottooworried	pct_worried_ill_covid19_notworried	pct_enough_toeat_very_worried	pct_enough_toeat_somewhat_worried	pct_enough_toeat_nottoo_worried	pct_enough_toeat_not_worried	pct_chills	pct_finances_very_worried	pct_finances_somewhat_worried	pct_finances_nottoo_worried	pct_finances_not_worried	pct_cli_past_smooth	pct_ili_past_smooth	pct_fever_past_smooth	pct_cough_past_smooth	pct_difficulty_breathing_past_smooth	pct_fatigue_past_smooth	pct_stuffy_runny_nose_past_smooth	pct_aches_muscle_pain_past_smooth	pct_sore_throat_past_smooth	pct_chest_pain_past_smooth	pct_nausea_past_smooth	pct_anosmia_ageusia_past_smooth	pct_eye_pain_past_smooth	pct_headache_past_smooth	pct_cmnty_sick_past_smooth	pct_ever_tested_past_smooth	pct_tested_recently_past_smooth	pct_worked_outside_home_past_smooth	pct_grocery_outside_home_past_smooth	pct_ate_outside_home_past_smooth	pct_spent_time_with_non_hh_past_smooth	pct_attended_public_event_past_smooth	pct_used_public_transit_past_smooth	pct_direct_contact_with_non_hh_past_smooth	pct_wear_mask_all_time_past_smooth	pct_wear_mask_most_time_past_smooth	pct_wear_mask_half_time_past_smooth	pct_wear_mask_some_time_past_smooth	pct_wear_mask_none_time_past_smooth	pct_no_public_past_smooth	pct_feel_nervous_all_time_past_smooth	pct_feel_nervous_most_time_past_smooth	pct_feel_nervous_some_time_past_smooth	pct_feel_nervous_little_time_past_smooth	pct_feel_nervous_none_time_past_smooth	pct_feel_depressed_all_time_past_smooth	pct_feel_depressed_most_time_past_smooth	pct_feel_depressed_some_time_past_smooth	pct_feel_depressed_little_time_past_smooth	pct_feel_depressed_none_time_past_smooth	pct_worried_ill_covid19_very_past_smooth	pct_worried_ill_covid19_somewhat_past_smooth	pct_worried_ill_covid19_nottooworried_past_smooth	pct_worried_ill_covid19_notworried_past_smooth	pct_enough_toeat_very_worried_past_smooth	pct_enough_toeat_somewhat_worried_past_smooth	pct_enough_toeat_nottoo_worried_past_smooth	pct_enough_toeat_not_worried_past_smooth	pct_chills_past_smooth	pct_finances_very_worried_past_smooth	pct_finances_somewhat_worried_past_smooth	pct_finances_nottoo_worried_past_smooth	pct_finances_not_worried_past_smooth	population.y.y

load_and_combine_country <- function(code, nsum = FALSE) {
  
  cat("\n working on ", code, "\n")
  
  # Initialize with Oxford data
  df_giant <- read.csv(paste0(ox_country_path, code, "-estimate.csv"))
  names(df_giant) <- tolower(names(df_giant))
  df_giant$date <- as.Date(df_giant$date)
  
  prefix <- "conf_"
  file_name <- paste0(confirmed_country_path, code, "-estimate.csv")
  if (file.exists(file_name)){
    cat("File", file_name, "exists!\n")
    df_aux <- read.csv(file_name)
    names(df_aux) <- tolower(names(df_aux))
    names(df_aux) <- paste0(prefix, names(df_aux))
    df_aux$date <- as.Date(df_aux$conf_date)
#    df_aux <- df_aux %>% select(-c(population))
    df_giant <- df_giant %>% full_join(df_aux, by = "date")
  }
  
  file_name <- paste0(ccfr_country_path, code, "-estimate.csv")
  if (file.exists(file_name)){
    cat("File", file_name, "exists!\n")
    df_aux <- read.csv(file_name)
    names(df_aux) <- tolower(names(df_aux))
    df_aux$date <- as.Date(df_aux$date)
    df_aux <- df_aux %>% select(-c(countrycode, population))
    df_giant <- df_giant %>% full_join(df_aux, by = "date")
  }
  
  file_name <- paste0(hospital_country_path, code, "-hospital-icu.csv")
  if (file.exists(file_name)){
    cat("File", file_name, "exists!\n")
    df_aux <- read.csv(file_name)
    names(df_aux) <- tolower(names(df_aux))
    df_aux$date <- as.Date(df_aux$date)
    df_aux <- df_aux %>% select(-c(countryname, countrycode))
    df_giant <- df_giant %>% full_join(df_aux, by = "date")
  }
  
  file_name <- paste0(W_country_path, code, "-estimate-past-smooth.csv")
  if (file.exists(file_name)){
    cat("File", file_name, "exists!\n")
    df_aux <- read.csv(file_name)
    names(df_aux) <- tolower(names(df_aux))
    df_aux$date <- as.Date(df_aux$date)
#    df_aux <- df_aux %>% select(-c(countryname, countrycode))
    df_giant <- df_giant %>% full_join(df_aux, by = "date")
  }
  
  
  file_name <- paste0(umd_api_country_path, code, "-estimate.csv")
  if (file.exists(file_name)){
    cat("File", file_name, "exists!\n")
    df_aux <- read.csv(file_name)
    names(df_aux) <- tolower(names(df_aux))
    df_aux$date <- as.Date(df_aux$date)
#    df_aux <- df_aux %>% select(-c(countryname, countrycode))
    df_giant <- df_giant %>% full_join(df_aux, by = "date")
  }
  
  file_name <- paste0(umd_challenge_country_path, code, "_UMD_country_nobatch_past_smooth.csv")
  if (file.exists(file_name)){
    cat("File", file_name, "exists!\n")
    df_aux <- read.csv(file_name)
    names(df_aux) <- tolower(names(df_aux))
    df_aux$date <- as.Date(df_aux$date)
#    df_aux <- df_aux %>% select(-c(countryname, countrycode))
    df_giant <- df_giant %>% full_join(df_aux, by = "date")
  }
  
  
  # ## Load and clean official data targets
  # loaded_confirmed_df <- read.csv(paste0("../data/estimates-confirmed/PlotData/", code, "-estimate.csv"))
  # df_confirmed <- loaded_confirmed_df %>%
  #     mutate(date = as.Date(date)) %>%
  #     dplyr::select(date, deaths, cases, population)
  #   # df_confirmed$cases = pmax(df_confirmed$cases, 0) # get rid of negatives
  #   # df_confirmed$deaths = pmax(df_confirmed$deaths, 0) # get rid of negatives
  #   df_confirmed$deaths[df_confirmed$deaths < 0] <- NA
  #   df_confirmed$cases[df_confirmed$cases < 0] <- NA
  #   
  #   pop <- loaded_confirmed_df$population[1]
  #   cat("[loaded confirmed]")
  #   
  #   #    cat(colnames(loaded_confirmed_df))
  #   
  #   ## Load and clean UMD regressors ----
  #   loaded_umd_df <- read.csv(paste0("../data/estimates-umd-unbatched/PlotData/",
  #                                    code, "_UMD_country_nobatch_past_smooth.csv"))
  #   df_umd <- loaded_umd_df %>% dplyr::select(starts_with("pct"))
  #   df_umd <- df_umd * pop / 100
  #   df_umd$date <- as.Date(loaded_umd_df$date)
  #   
  #   cat("[loaded UMD]")
  #   #    cat(colnames(loaded_umd_df))
  #   
  #   ## Load and clean CCFR regressors
  #   loaded_ccfr_df <- read.csv(paste0("../data/estimates-ccfr-based/PlotData/",
  #                                     code, "-estimate.csv"))
  #   
  #   df_ccfr <- loaded_ccfr_df %>%
  #     mutate(date = as.Date(date)) %>%
  #     dplyr::select(date, cases_daily, cases_contagious, cases_active)
  #   
  #   cat("[loaded CCFR]")
  #   #    cat(colnames(loaded_ccfr_df))
  #   
  #   ## Load NSUM and clean regressors, not all countries have this
  #   if (nsum) {
  #     loaded_nsum_df <- read.csv(paste0("../data/estimates-W/past_smooth/", code, "-estimate-past-smooth.csv"))
  #     
  #     # df_nsum <- loaded_nsum_df %>% dplyr::select(p_cases, p_cases_recent, p_cases_fatalities, p_cases_stillsick)
  #                                                 # p_cases_past_smooth, p_cases_fatalities_past_smooth,
  #                                                 # p_cases_recent_past_smooth, p_cases_stillsick_past_smooth)
  #     df_nsum <- subset(loaded_nsum_df, select = -c(date) )
  #     df_nsum <- df_nsum * pop
  #     df_nsum$date <- as.Date(loaded_nsum_df$date)
  #     
  #     cat("[loaded NSUM]")
  #   }
  #   
  #   ## Stitch together data frames ...
  #   
  #   all_df <- df_confirmed %>% full_join(df_ccfr, by = "date")
  #   
  #   if (nsum)
  #   {
  #     all_df <- all_df %>% full_join(df_nsum, by = "date")
  #   }
  #   
  #   all_df <- all_df %>% full_join(df_umd, by = "date")
    
    #    cat(colnames(all_df))
  
  df_giant <- df_giant[df_giant$date >= start_date,]
  df_giant <- df_giant[order(df_giant$date),]
  out_path <- paste0(output_path, code, "_alldf.csv")
  write.csv(df_giant, out_path, row.names = FALSE)
  cat("[saved data]")
}

#save data for countries of interest

interest <- list.files(ox_country_path, pattern="*.csv", full.names=FALSE)
interest <- substring(interest, 1, 2)

dd <- sapply(interest, load_and_combine_country, nsum = F)


