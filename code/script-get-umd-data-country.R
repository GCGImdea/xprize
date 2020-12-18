## Libraries
library(dplyr)
library(ggplot2)
library(httr)
library(jsonlite)
library(stringr)
library(stringi)

countries_data <- "../data/common-data/oxford-umd-country-population.csv"

## Load smoothing function ----
#source("smooth_column_past.R")
source("smooth_column-v2.R")

smooth_param <- 25

## Function to extract updated data from UMD api: ----
UMD_api <- function(country, type = "daily", indicator = "covid", date_start = NA, date_end = NA){
  
  country <- str_replace_all(country, " ", "%")
  
  # first date available:
  if (is.na(date_start)) {
    request <- GET(url = paste0("https://covidmap.umd.edu/api/datesavail?country=",
                                country,"%"))
    
    # make sure the content is encoded with 'UTF-8'
    response <- content(request, as = "text", encoding = "UTF-8")
    
    # now we can have a dataframe for use!
    date_start <- fromJSON(response, flatten = TRUE) %>% data.frame() 
    
    date_start = min(date_start$data.survey_date)
  }
  
  # today:
  if (is.na(date_end)) {
    date_end = format(Sys.time(), "%Y%m%d")
  }
  
  # adding url
  path <- paste0("https://covidmap.umd.edu/api/resources?indicator=", indicator,
                 "&type=", type, 
                 "&country=", country, 
                 "&daterange=", date_start, "-", date_end) 
  
  # request data from api
  request <- GET(url = path)
  
  # make sure the content is encoded with 'UTF-8'
  response <- content(request, as = "text", encoding = "UTF-8")
  
  # now we can have a dataframe for use!
  coviddata <- fromJSON(response, flatten = TRUE) %>% data.frame()
  
  return(coviddata)
}

# ## List of countries: ----
# 
# ## Function to create csv with available countries ---
# ## It adds populations and iso codes (alpha 2 and 3)
# create_countries_pop_iso <- function(){
#   request <- GET(url = "https://covidmap.umd.edu/api/country")
#   
#   response <- content(GET(url = "https://covidmap.umd.edu/api/country"),
#                       as = "text", encoding = "UTF-8")
#   
#   # available countries:
#   countries <- fromJSON(response, flatten = TRUE) %>% data.frame() 
#   
#   # country data: iso codes and population:
#   countries_pop <- read.csv("../data/common-data/country_population_ecdc.csv", 
#                             header = T) %>% 
#     select(country_territory, countryterritoryCode, geo_id, population)
#   
#   colnames(countries_pop) <- c("country", "iso_alpha3", "iso_alpha2", "population")
#   
#   countries_pop$country <- str_replace_all(countries_pop$country, "_", " ")
#   
#   countries <- left_join(countries, countries_pop, by = "country")
#   
#   countries[countries$country == "Côte d'Ivoire", 2:4] <- 
#     countries_pop[countries_pop$country == "Cote dIvoire", 2:4]
#   
#   countries[countries$country == "Czech Republic", 2:4] <- 
#     countries_pop[countries_pop$country == "Czechia", 2:4]
#   
#   levels(countries$iso_alpha2) <- c(levels(countries$iso_alpha2), "HK")
#   levels(countries$iso_alpha3) <- c(levels(countries$iso_alpha3), "HKG")
#   countries[countries$country == "Hong Kong", "iso_alpha3"] <- "HKG"
#   countries[countries$country == "Hong Kong", "iso_alpha2"] <- "HK"
#   countries[countries$country == "Hong Kong", "population"] <- 7496981
#   
#   countries[countries$country == "Puerto Rico, U.S.", 2:4] <- 
#     countries_pop[countries_pop$country == "Puerto Rico", 2:4]
#   
#   levels(countries$iso_alpha2) <- c(levels(countries$iso_alpha2), "TW")
#   levels(countries$iso_alpha3) <- c(levels(countries$iso_alpha3), "TWN")
#   countries[countries$country == "Taiwan", "iso_alpha3"] <- "TWN"
#   countries[countries$country == "Taiwan", "iso_alpha2"] <- "TW"
#   countries[countries$country == "Taiwan", "population"] <- 23568378
#   
#   countries[countries$country == "Tanzania", 2:4] <- 
#     countries_pop[countries_pop$country == "United Republic of Tanzania", 2:4]
#   
#   write.csv(countries, file = "../data/common-data/country_population_umd.csv")
# }

## The csv is already created, uncomment if needed again:
# create_countries_pop_iso()


umd_batch_symptom_country <- function(countries_2_try){
  for (country in countries_2_try) {
    
    print(paste0("Downloading and smoothing: ", country, "'s UMD data"))
    
    ## Load data 
    # Indicator covid , flu , mask ,contact or finance
    dt <- UMD_api(country, indicator = "covid")

    # remove "data." from column names:
    colnames(dt) <- str_replace_all(colnames(dt), "data.", "")
    # set dates:
    
    dt <- dt %>% mutate(date = paste0( str_sub(survey_date, 1, 4), "-",
                                       str_sub(survey_date, 5, 6), "-",
                                       str_sub(survey_date, 7, 8))) %>% 
      mutate(date = as.Date(date)) %>%
      select(date, iso_code, country, sample_size, percent_cli, cli_se, percent_cli_unw, cli_se_unw)

    dt_aux <- UMD_api(country, indicator = "flu")
    colnames(dt_aux) <- str_replace_all(colnames(dt_aux), "data.", "")
    dt_aux <- dt_aux %>% mutate(date = paste0( str_sub(survey_date, 1, 4), "-",
                                       str_sub(survey_date, 5, 6), "-",
                                       str_sub(survey_date, 7, 8))) %>% 
      mutate(date = as.Date(date)) %>%
      select(date, percent_ili, ili_se, percent_ili_unw, ili_se_unw)
    dt <- dt %>% full_join(dt_aux, by = "date")
 
    dt_aux <- UMD_api(country, indicator = "mask")
    colnames(dt_aux) <- str_replace_all(colnames(dt_aux), "data.", "")
    dt_aux <- dt_aux %>% mutate(date = paste0( str_sub(survey_date, 1, 4), "-",
                                               str_sub(survey_date, 5, 6), "-",
                                               str_sub(survey_date, 7, 8))) %>% 
      mutate(date = as.Date(date)) %>%
      select(date, percent_mc, mc_se, percent_mc_unw, mc_se_unw)
    dt <- dt %>% full_join(dt_aux, by = "date")

    dt_aux <- UMD_api(country, indicator = "contact")
    colnames(dt_aux) <- str_replace_all(colnames(dt_aux), "data.", "")
    dt_aux <- dt_aux %>% mutate(date = paste0( str_sub(survey_date, 1, 4), "-",
                                               str_sub(survey_date, 5, 6), "-",
                                               str_sub(survey_date, 7, 8))) %>% 
      mutate(date = as.Date(date)) %>% 
      select(date, percent_dc, dc_se=mc_se, percent_dc_unw, dc_se_unw)
    dt <- dt %>% full_join(dt_aux, by = "date")

    dt_aux <- UMD_api(country, indicator = "finance")
    colnames(dt_aux) <- str_replace_all(colnames(dt_aux), "data.", "")
    dt_aux <- dt_aux %>% mutate(date = paste0( str_sub(survey_date, 1, 4), "-",
                                               str_sub(survey_date, 5, 6), "-",
                                               str_sub(survey_date, 7, 8))) %>% 
      mutate(date = as.Date(date)) %>%
      select(date, percent_hf, hf_se, percent_hf_unw, hf_se_unw)
    dt <- dt %>% full_join(dt_aux, by = "date")

    to_smooth <- c("percent_cli", "percent_cli_unw",
                   "percent_ili", "percent_ili_unw",
                   "percent_mc", "percent_mc_unw",
                   "percent_dc", "percent_dc_unw",
                   "percent_hf", "percent_hf_unw")

    for (col in to_smooth) {
      cat("Smoothing ", col, "\n")
      try(
        dt <- smooth_column(dt, col, 
                                 basis_dim = smooth_param, 
                                 link_in ="log", monotone = F)
        , silent = F)
      }
    
    # add population:
    dt$population <- countries[countries$country_umd==country, "population"]

    country_code <- countries[countries$country_umd==country, "geo_id"]
    
    write.csv(dt,
              paste0("../data/estimates-umd-symptom-survey/", country_code , "-estimate.csv"),
              row.names = FALSE)
    
  } # end-for-countries_2_try
} #end-function: umd_batch_symptom_country

## Available countries ----
countries <- read.csv(countries_data, header = T)

x <- countries$country_umd
x <- stri_remove_empty_na(x)
x <- x[x != "Burkina Faso"]
x <- x[x != "Côte d'Ivoire"]
x <- x[x != "South Africa"]
x <- x[x != "United States of America"]
countries_b <- x

umd_batch_symptom_country(countries_b)

