library(rvest)
library(tibble)
library(tidyr)
library(dplyr)

# this script should create this file if it doesn't already exist
path <- "data/pop-region.csv"

if (!file.exists(path)) {
  
  domain <- "http://www.bcstats.gov.bc.ca"
  
  src <- html(
    file.path(domain, "/StatisticsBySubject/Demography/PopulationEstimates.aspx")
  )
  
  # exract hyperlinks from page
  links <- src %>%
    html_nodes("a") %>%
    html_attr("href") %>%
    grep("DistrictandMuncipalPopulationEstimates", ., value = TRUE)
  
  # download the data
  curl::curl_download(
    paste0(domain, link), path
  )
  
}

