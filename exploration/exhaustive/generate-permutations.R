library(dplyr)
library(stringr)
library(tidyverse)
library(lubridate)

dance_file <- "./dance_iplan.csv"
hammer_file <- "./hammer_iplan.csv"
output_dir <- "ips-vectors/"
ips <- c("C1_School closing", 
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
max_val <- c(3,3,2,4,2,3,2,4,2,3,2,4)

dancedf <- read.csv(dance_file, check.names = FALSE)

# Generate vectors with 2 values not 0
for (i in 1:11) {
  for (j in (i+1):12) {
    for (k in 1:max_val[i]) {
      for (l in 1:max_val[j]) {
        df <- dancedf
        df[ips[i]] <- k
        df[ips[j]] <- l
        write.csv(df, paste0(output_dir, "iplan-", str_sub(ips[i],1,2),"-", k,
                             "-", str_sub(ips[j],1,2), "-", l, ".csv"), row.names = F)
      }
    }
  }
}



# Generate vectors with 2 values to 0
hammerdf <- read.csv(hammer_file, check.names = FALSE)

for (i in 1:11) {
  for (j in (i+1):12) {
        df <- hammerdf
        df[ips[i]] <- 0
        df[ips[j]] <- 0
        write.csv(df, paste0(output_dir, "iplan-no", str_sub(ips[i],1,2),
                             "-no", str_sub(ips[j],1,2), ".csv"), row.names = F)
  }
}


