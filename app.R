library(shiny)
library(leaflet)
library(sf)
library(plotly)

# see geo.R to see how these shape files were obtained
# also, leaflet currently requires this transform?
# https://github.com/rstudio/leaflet/blob/24a7dfa68528e32265aa325610eca7f8fa7a8050/R/normalize-sf.R#L86-L91
districts <- "data/geo/districts/CD_2011_SIMPLE.shp" %>%
  st_read() %>%
  st_transform(4326) %>%
  mutate(label = CDNAME)
  
municipals <- "data/geo/municipals/CSD_2011_SIMPLE.shp" %>%
  st_read() %>%
  st_transform(4326) %>%
  mutate(label = CSDNAME)

bb <- st_bbox(districts)

# see ptt.R 
ptt <- readr::read_csv("data/ptt/regional-district-weekly.csv")


# user interface
ui <- fluidPage(
  fluidRow(
    column(
      4, leafletOutput("map", height = 600)
    ),
    column(
      8,
      tabsetPanel(
        tabPanel(
          "BC", 
          selectInput("regionType", "Region Type:", c("districts", "municipals")),
          plotlyOutput("cog", height = 650), 
          value = "bc"
        ),
        tabPanel("Vancouver", plotlyOutput("vancouver"), value = "vancouver"),
        id = "tabset"
      ))
  )
)

# server-side logic
server <- function(input, output, session, ...) {
  
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles() %>%
      # TODO: why isn't fitBounds() consistent? Why does setView() lead to console errors?
      fitBounds(bb[["xmin"]], bb[["ymin"]], bb[["xmax"]], bb[["ymax"]])
      #setView(mean(bb[c("xmin", "xmax")]), mean(bb[c("ymin", "ymax")]), 4.5)
  })
  
  # redraw polygons upon changing the region type
  observeEvent(input$regionType, {
    
    d <- switch(
      input$regionType,
      districts = districts,
      municipals = municipals
    )
    
    leafletProxy("map", session) %>%
      clearShapes() %>%
      addPolygons(
        data = d,
        color = "black",
        weight = 1,
        highlightOptions = highlightOptions(fillOpacity = 1),
        label = ~label
      )
  })
  
  
  
  ## reusable reactive function to fit sensible bounds 
  #fitMapToLocation <- reactive({
  #  if (identical(input$tabset, "vancouver")) {
  #    districts <- districts %>% filter(CDNAME == "Greater Vancouver")
  #  } 
  #  bb <- st_bbox(districts)
  #  leafletProxy("map", session) %>%
  #    fitBounds(bb[["xmin"]], bb[["ymin"]], bb[["xmax"]], bb[["ymax"]])
  #})
  
}




shinyApp(ui, server)