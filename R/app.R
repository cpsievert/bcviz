#' Launch visualization
#' 
#' @param prompt whether or not to prompt the default browser to open the app. 
#' By default, a browser is prompted when R is being used interactively.
#' @export
#' @author Carson Sievert
#' @examples 
#' 
#' launch()

launch <- function(prompt = interactive()) {
  
  # geographic data
  data("geoDevelopments", package = "bcviz")
  data("geoDistricts", package = "bcviz")
  data("geoMunicipals", package = "bcviz")
  
  # population estimates
  data("popDistricts", package = "bcviz")
  
  # property tax transfer
  data("ptt", package = "bcviz")
  
  bb <- st_bbox(geoDistricts)
  
  # user interface
  ui <- fluidPage(fluidRow(
    column(
      4, leafletOutput("map", height = 400),
      # TODO: should this be a conditional panel?
      selectInput(
        "regionType", "Region Type:", selected = "districts",
        c("Development Regions" = "developments", 
          "Regional Districts" = "districts", 
          "Municipalities" = "municipals")
      )
    ),
    column(
      8,
      tabsetPanel(
        tabPanel(
          "BC",
          # TODO: dynamically adjust height!
          plotlyOutput("pop", height = 650), 
          value = "bc"
        ),
        tabPanel("Vancouver", plotlyOutput("vancouver"), value = "vancouver"),
        id = "tabset"
      ))
  ))
  
  # server-side logic
  server <- function(input, output, session, ...) {
    
    regions <- reactiveValues(
      selected = NULL
    )
    
    output$map <- renderLeaflet({
      leaflet() %>%
        addTiles() %>%
        # TODO: why isn't fitBounds() consistent? Why does setView() lead to console errors?
        fitBounds(bb[["xmin"]], bb[["ymin"]], bb[["xmax"]], bb[["ymax"]])
      #setView(mean(bb[c("xmin", "xmax")]), mean(bb[c("ymin", "ymax")]), 4.5)
    })
    
    # update reactive values upon clicking the map and modify opacity sensibly
    observeEvent(input$map_shape_click, {
      print(input$map_shape_click)
      regions$selected <- c(regions$selected, input$map_shape_click)
      
      d <- switch(
        input$regionType,
        developments = geoDevelopments,
        districts = geoDistricts,
        municipals = geoMunicipals
      )
      
      d <- d[d$label %in% input$map_shape_click$id, ]
      
      
      leafletProxy("map", session) %>%
        removeShape(layerId = input$map_shape_click$id) %>%
        addPolygons(
          data = d,
          color = "black",
          fillOpacity = 1,
          weight = 1,
          highlightOptions = highlightOptions(fillOpacity = 0.2),
          label = ~label,
          layerId = ~label
        )
      
    })
    
    
    output$pop <- renderPlotly({
      
      # always show overall BC population
      d <- popDistricts[popDistricts$district %in% c(regions$selected, "British Columbia"), ]
      
      p <- ggplot(d, aes(Age, Population, color = Gender)) +
        geom_line(aes(group = interaction(Year, district)), alpha = 0.1) +
        geom_line(aes(frame = Year)) + 
        facet_wrap(~district, ncol = 1, scales = "free_y") + 
        theme_BCStats() +
        labs(y = NULL)
      
      ggplotly(p, dynamicTicks = TRUE, tooltip = "Gender") %>%
        #style(showlegend = FALSE, traces = 3:100) %>%
        animation_opts(300)
    })
    
    # redraw polygons upon changing the region type
    observeEvent(input$regionType, {
      
      regions$selected <- NULL
      
      d <- switch(
        input$regionType,
        developments = geoDevelopments,
        districts = geoDistricts,
        municipals = geoMunicipals
      )
      
      leafletProxy("map", session) %>%
        clearShapes() %>%
        addPolygons(
          data = d,
          color = "black",
          weight = 1,
          highlightOptions = highlightOptions(fillOpacity = 1),
          label = ~label,
          layerId = ~label
        )
    })
    
  }
  
  shinyApp(
    ui, server, 
    options = list(launch.browser = prompt)
  )
}
