library(dplyr)
library(stringr)
library(tidyverse)
library(lubridate)

hammer_plan <- "./hammer_iplan.csv"

hammer_file <- "./hammer_full.csv"

start_date <- ymd("2020-01-01")
end_date <- ymd("2021-12-31")
#end_date <- ymd("2020-01-03")




process_country_region <- function(df) {
  
  cat("\n working on ", df$CountryName[1], df$RegionName[1], "\n")
  
  df$Date <- as.Date(df$Date)
  df$RegionName[is.na(df$RegionName)] <- ""
  
  df <- df %>% 
    complete(Date = seq.Date(start_date, end_date, by="day")) %>% 
    fill(CountryName, RegionName, 
         "C1_School closing", 
         "C2_Workplace closing",
         "C3_Cancel public events",
         "C4_Restrictions on gatherings",
         "C5_Close public transport",
         "C6_Stay at home requirements",
         "C7_Restrictions on internal movement",
         "C8_International travel controls",
         "H1_Public information campaigns",
         "H2_Testing policy",
         "H3_Contact tracing",
         "H6_Facial Coverings")
  
  return(df)
}


df <- read.csv(hammer_plan, check.names = FALSE)
df$Date <- as.Date(df$Date)

n <- nrow(df)

df2 <- process_country_region(as.data.frame(df[1,]))

for (i in 2:n) {
  dfaux <- as.data.frame(df[i,])
  df2 <- bind_rows(df2, process_country_region(dfaux))
}

df2 <- df2[order(df2$CountryName,df2$RegionName,df2$Date),]
write.csv(df2, hammer_file, row.names = F)
