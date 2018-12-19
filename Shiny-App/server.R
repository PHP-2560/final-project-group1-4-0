function(input, output) {
  ##### Map
  # Set value for the minZoom and maxZoom settings.
  leaflet(options = leafletOptions(minZoom = 0, maxZoom = 18))

  # Make a color palette called pal for the values of `sector_label` using `colorFactor()`  
  # Colors should be: "red", "blue", and "#9b4a11" for "Public", "Private", and "For-Profit" colleges, respectively
  pal <- colorFactor(palette = c("red", "blue"), 
                     levels = c("Public", "Private"))
  
  hd2017 = read.csv("hd2017.csv", header = T)
  
  # joining datasets with dplyr 
  hd2017 = hd2017 %>%
    mutate(location = paste(CITY,",", sep = "")) %>%
    mutate(locationfinal = paste(location, STABBR, sep = " "))  %>%
    select(INSTNM, LATITUDE, LONGITUD, locationfinal)
  
  hd2017 = as.tbl(hd2017)

  df.latlon1 = left_join(df, hd2017, by = c("University" = "INSTNM"))
  df.latlon1 = as.tbl(df.latlon1)
  
  # create latitude and longitude variables
  names(df.latlon1)[which(names(df.latlon1) == "LONGITUD")] = "lng"
  names(df.latlon1)[which(names(df.latlon1) == "LATITUDE")] = "lat"
  
  names(df.latlon1)
  
  # Create data frame called public with only public colleges
  public1 <- filter(df.latlon1, School_Type == "Public")  
  private <- filter(df.latlon1, School_Type == "Private") 
  
  output$ShinyAppMap <- renderLeaflet({
    leaflet() %>% 
      addTiles(group = "OSM") %>% 
      addProviderTiles("CartoDB", group = "Carto") %>% 
      addProviderTiles("Esri", group = "Esri") %>% 
      addCircleMarkers(data = public1, radius = 2, label = ~htmlEscape(University),
                       color = ~pal(School_Type), group = "Public") %>%
      addCircleMarkers(data = private, radius = 2, label = ~htmlEscape(University),
                       color = ~pal(School_Type), group = "Private", clusterOptions = markerClusterOptions()) %>% 
      addLayersControl(baseGroups = c("OSM", "Carto", "Esri"), 
                       overlayGroups = c("Public", "Private")) %>% 
      setView(lat = 39.8282, lng = -98.5795, zoom = 4) 
  })
  
  
  ##### Data Explorer
  # filter function based on given minimum/maximum scores & school type(s)
  change_df = function(min, max, sch_typ) {
    df %>%
      dplyr::filter(Score >= min,
                    Score <= max,
                    is.null(sch_typ) | School_Type %in% sch_typ
      )
  }
  # updates data table based on given inputs
  output$df_out = DT::renderDataTable({
    change_df(input$minScore, input$maxScore, input$schools)
  })
  
  
  ##### Statistical Analysis
  # Create a subset of data filtering for selected title types
  schools_subset <- reactive({
    req(input$selected_type)
    filter(df, School_Type %in% input$selected_type)
  })
  # Convert plot_title toTitleCase
  pretty_plot_title <- reactive({ toTitleCase(input$plot_title) })
  
  # Create scatterplot object the plotOutput function is expecting
  output$scatterplot <- renderPlot({
    ggplot(data = schools_subset(), 
           aes_string(x = input$x, y = input$y, color = input$z)) +
      geom_point() +
      labs(title = pretty_plot_title())
  })  
  
  # Create descriptive text
  output$description <- renderText({
    paste0("The plot above titled '", pretty_plot_title(), "' visualizes the relationship between ", 
           input$x, " and ", input$y, ", conditional on ", input$z, ".")
  })
  
  #creating density plot
  output$densityplot <- renderPlot({
    ggplot(data = df, aes_string(x = input$x)) +
      geom_density()
  })
  
  # Create regression output
  output$lmoutput <- renderPrint({
    x <- df %>% pull(input$x)
    y <- df %>% pull(input$y)
    summ <- summary(lm(y ~ x, data = df)) 
    print(summ, digits = 3, signif.stars = FALSE)
  })
  
}