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
  
if (!dir.exists("data/ptt")) {
  dir.create("data/ptt")
}

targets <- file.path("data/ptt", basename(sources))

res <- Map(curl_download, sources, targets)

