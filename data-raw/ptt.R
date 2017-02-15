# Apparently we might get better/more granular data...

library(rvest)
library(curl)

# NOTE: to update, go to https://catalogue.data.gov.bc.ca/dataset/property-transfer-tax-data
# click permalink, replace this link below with that link
src <- html("https://catalogue.data.gov.bc.ca/dataset/9c9b8d35-d59b-436a-a350-f581ea71a798")
# grab links to csvs
sources <- src %>%
  html_nodes(".resource-url-analytics") %>%
  html_attrs() %>%
  sapply("[[", "href") %>%
  grep("\\.csv$", ., value = TRUE)

targets <- file.path("data-raw", basename(sources))

for (i in seq_along(targets)) {
  target <- targets[[i]]
  if (!file.exists(target)) curl_download(sources[[i]], target)
}

ptt <- readr::read_csv("data-raw/regional-district-weekly.csv")
devtools::use_data(ptt, overwrite = TRUE)
