library(dplyr)
library(tidyverse)
path_symptom_lags <- "../data/estimates-symptom-lags/cutoffs/PlotData/"
filter <-".*-cases-25-60-penFALSE-alpha0.5-rmccTRUE-rmth0.9-smthFALSENA-limrangeTRUE-2020-11-20-2020-12-21-1-umdapi_data-cmu_data-estimates-lag-daily.csv"
desiredCutoff="2020-12-21"

file_in_pattern <- ".*alldf.csv"

files <- dir(path_symptom_lags, pattern = filter)

for (file in files){
  iso_code_country <- substr(file, 1, 2)
  fileoutname<-paste0(path_symptom_lags,iso_code_country,"-estimates.csv")
  fileoutnameforesync<-paste0(path_symptom_lags,iso_code_country,"-foresync.csv")
  df<-read.csv(paste0(path_symptom_lags,file))
  estimatesSync <- df %>% filter(cutoff==desiredCutoff & predType=="nearFuture" & !is.na(syncFore)) %>% dplyr::select(date, syncFore) %>% rename (estimate = syncFore)
  estimatesFore <- df %>% filter(cutoff==desiredCutoff & predType=="nearFuture" & is.na(syncFore)) %>% dplyr::select(date, fore) %>% rename (estimate = fore)
  estimatesForeSync <- df %>% filter(cutoff==desiredCutoff & predType=="nearFuture") %>% dplyr::select(date, fore, syncFore) 
  
  estimates<-bind_rows(estimatesFore, estimatesSync) %>% arrange(date)
  write.csv(estimates, fileoutname)
  write.csv(estimatesForeSync, fileoutnameforesync)
}