# NOTE: this page has links to shape files for the different region types
# http://www.bcstats.gov.bc.ca/statisticsbysubject/geography/TranslationsDataSets.aspx

library(sf)

if (!dir.exists("data/geo")) {
  dir.create("data/geo")
}

# obtain/simplify shape files for the 28 district boundaries 
if (!dir.exists("data/geo/districts")) {
  dir.create("data/geo/districts")
  districts <- "http://www.bcstats.gov.bc.ca/Files/18885d4f-e4cf-443b-bb3b-d169651be62d/Boundaries-CensusDivisions2011.zip"
  target <- file.path("data/geo/districts",  basename(districts))
  curl::curl_download(districts, target)
  unzip(target, exdir = "data/geo/districts")
  unlink(target)
  # this shape file is super high resolution, simplify it!
  d <- st_read("data/geo/districts/CD_2011.shp")
  # str(d$geometry[[2]])
  #> List of 1
  #> $ :List of 1
  #> ..$ : num [1:4627, 1:2] 1392988 1393966 1394930 1395134 1395243 ...
  #> - attr(*, "class")= chr [1:3] "XY" "MULTIPOLYGON" "sfg"
  d2 <- st_simplify(d, dTolerance = 4000)
  # str(d2$geometry[[2]])
  #> List of 1
  #> $ : num [1:73, 1:2] 1392988 1413363 1429810 1436930 1468324 ...
  #> - attr(*, "class")= chr [1:3] "XY" "POLYGON" "sfg"
  st_write(d2, "data/geo/districts/CD_2011_SIMPLE.shp")
}

# obtain shape files for municipals
if (!dir.exists("data/geo/municipals")) {
  dir.create("data/geo/municipals")
  municipals <- "http://www.bcstats.gov.bc.ca/Files/28417d81-0bf6-43d8-b182-7257ed72768f/Boundaries-CensusSubdivisions2011.zip"
  target <- file.path("data/geo/municipals",  basename(municipals))
  curl::curl_download(municipals, target)
  unzip(target, exdir = "data/geo/municipals")
  unlink(target)
  # this shape file is super high resolution, simplify it!
  d <- st_read("data/geo/municipals/CSD_2011.shp")
  d2 <- st_simplify(d, dTolerance = 35)
  st_write(d2, "data/geo/municipals/CSD_2011_SIMPLE.shp")
}