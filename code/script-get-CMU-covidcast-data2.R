# load library
library(covidcast)
library(dplyr)
library(stringr)

ox_region_path <- "../data/oxford/region/" # Oxford data
output_path <- "../data/CMU-covidcast/"

start_date <- "2020-01-01"
end_date <- Sys.Date()

cmu_ili_cli_signals <- c(
"raw_cli", 
"smoothed_cli",
"raw_ili", 
"smoothed_ili",
"raw_wcli", 
"smoothed_wcli",
"raw_wili", 
"smoothed_wili",
"raw_hh_cmnty_cli", 
"smoothed_hh_cmnty_cli",
"raw_nohh_cmnty_cli", 
"smoothed_nohh_cmnty_cli"
)

cmu_behavior_signals <- c(
"smoothed_wearing_mask",
"smoothed_others_masked",
"smoothed_travel_outside_state_5d",
"smoothed_work_outside_home_1d",
"smoothed_shop_1d",
"smoothed_restaurant_1d",
"smoothed_spent_time_1d",
"smoothed_large_event_1d",
"smoothed_public_transit_1d"
)

cmu_testing_signals <- c(
"smoothed_tested_14d",
"smoothed_tested_positive_14d",
"smoothed_wanted_test_14d"
)

cmu_mental_health_signals <- c(
"smoothed_anxious_5d",
"smoothed_depressed_5d",
"smoothed_felt_isolated_5d",
"smoothed_worried_become_ill",
"smoothed_worried_finances"
)

all_signals <- c(cmu_ili_cli_signals, cmu_behavior_signals, cmu_testing_signals, cmu_mental_health_signals)

state_files <- list.files(ox_region_path, pattern="*.csv", full.names=TRUE)
state_files <- state_files[grep("US", state_files, fixed =TRUE)]
# Reads all files
df_all <- lapply(state_files, read.csv)

state_files <- list.files(ox_region_path, pattern="*.csv", full.names=FALSE)
state_files <- state_files[grep("US", state_files, fixed =TRUE)]
iso2 <- word(state_files,1,sep = "-")
state_codes <- tolower(word(iso2,2,sep = "_"))
names(df_all) <- state_codes

for (code in state_codes) {
  cat("Init ", code, "\n")
  
  df_all[[code]] <- df_all[[code]] %>%
    select(date=Date, iso2)
  df_all[[code]]$date <- as.Date(df_all[[code]]$date)
}
  
for (signal in all_signals){
  cat("--signal ", signal, "\n")
  df_signal <- suppressMessages(
    covidcast_signal(data_source = "fb-survey", signal = signal, 
                     start_day = start_date, end_day = end_date, 
                     geo_type = "state")
  )
  for (code in state_codes) {
    df_aux <- df_signal[df_signal$geo_value == code,]
    df_aux$date <- as.Date(df_aux$time_value)
    df_aux[signal] <- df_aux$value
    df_aux <- df_aux[, c("date", signal)]
    df_all[[code]] <- df_all[[code]] %>% full_join(df_aux, by = "date")
  }
  for (i in 1:length(state_codes)) {
    cat("Writing ", state_codes[i], "\n")
    
    write.csv(df_all[[state_codes[i]]], paste0(output_path, iso2[i], "-estimate.csv"), row.names = FALSE)
  }
}





# for (state in state_files) {
#   cat(state, "\n")
#   df_all <- read.csv(paste0(ox_region_path, state))
#   df_all <- df_all %>%
#     select(date=Date, iso2)
#   df_all$date <- as.Date(df_all$date)
#   iso2 <- word(state,1,sep = "-")
#   state_code <- tolower(word(iso2,2,sep = "_"))
#   
#   for (signal in all_signals){
#     cat("--signal ", signal, "\n")
#     df_aux <- suppressMessages(
#       covidcast_signal(data_source = "fb-survey", signal = signal, 
#                                start_day = start_date, end_day = end_date, 
#                                geo_type = "state", geo_value = state_code)
#     )
#     df_aux$date <- as.Date(df_aux$time_value)
#     df_aux[signal] <- df_aux$value
#     df_aux <- df_aux[, c("date", signal)]
#     df_all <- df_all %>% full_join(df_aux, by = "date")
#   }
#   write.csv(df_all, paste0(output_path, iso2, "-estimate.csv"), row.names = FALSE)
# }
# 
# 
# # states <- tolower(word(interest,2,sep = "_"))
# # 
# # cli <- suppressMessages(
# #   covidcast_signal(data_source = "fb-survey", signal = "smoothed_cli", 
# #                    start_day = "2020-05-01", end_day = "2020-05-07", 
# #                    geo_type = "state")
# # )
# # knitr::kable(head(cli))
# 
# 
# 
# 
# 
# 
# 
