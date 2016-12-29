library(rvest)
library(tibble)
library(tidyr)
library(dplyr)

# this script should create this file if it doesn't already exist
path <- "data/pop-overall.csv"

if (!file.exists(path)) {
  
  domain <- "http://www.bcstats.gov.bc.ca"
  
  src <- html(
    file.path(domain, "/StatisticsBySubject/Demography/PopulationEstimates.aspx")
  )
  
  # exract hyperlink from page
  link <- src %>%
    html_nodes("a") %>%
    html_attr("href") %>%
    grep("BCquarterlypopulationestimates\\.csv$", ., value = TRUE)
  
  # download the data
  curl::curl_download(
    paste0(domain, link), path
  )
  
}


# read it in to clean it up a bit
qdat <- readr::read_csv(path, col_names = FALSE, skip = 3)

qdat <- qdat %>%
  setNames(c("year", "Q1", "Q2", "Q3", "Q4")) %>%
  gather(variable, value, -year)
  
# wtf???
qdat[76, ]

# create a grid of all possible quarters
rng <- range(qdat$year, na.rm = TRUE)
g <- expand.grid(
  seq.int(rng[1], rng[2]),
  paste0("Q", 1:4)
)
g <- setNames(as_tibble(g), c("year", "variable"))

# join and clean-up
newdat <- left_join(g, qdat)
newdat$value[newdat$value == "-"] <- NA
newdat$value <- as.numeric(newdat$value)
newdat$time <- with(
  newdat, year + recode(variable, Q1 = 0, Q2 = 1/4, Q3 = 1/2, Q4 = 3/4)
)

# quick viz
plot_ly(newdat, x = ~time, y = ~value) %>% add_lines()