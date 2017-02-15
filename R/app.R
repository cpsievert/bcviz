#' Launch visualization
#' 
#' @export
#' @author Carson Sievert
#' @examples 
#' 
#' launch()

launch <- function() {
  
  data("geoDistricts", package = "bcviz")
  data("geoMunicipals", package = "bcviz")
  data("popDistricts", package = "bcviz")
  data("ptt", package = "bcviz")
  
  bb <- st_bbox(geoDistricts)
  
  # user interface
  ui <- fluidPage(
    fluidRow(
      column(
        4, leafletOutput("map", height = 600),
        # TODO: should this be a conditional panel?
        selectInput("regionType", "Region Type:", c("districts", "municipals"))
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
    )
  )
  
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
      
      # always show all of BC
      d <- popDistricts[popDistricts$district %in% c(regions$selected, "British Columbia"), ]
      
      p <- ggplot(d, aes(Age, Population, color = Gender)) +
        geom_line(aes(group = interaction(Year, district)), alpha = 0.1) +
        geom_line(aes(frame = Year)) + 
        facet_wrap(~district, ncol = 1, scales = "free_y") + 
        theme_BCStats() +
        labs(y = NULL)
      
      ggplotly(p, dynamicTicks = TRUE, tooltip = "Gender") %>%
        style(showlegend = FALSE, traces = 3:100) %>%
        animation_opts(100)
    })
    
    # redraw polygons upon changing the region type
    observeEvent(input$regionType, {
      
      d <- switch(
        input$regionType,
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
  
  shinyApp(ui, server)
}
