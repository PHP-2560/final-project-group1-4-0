server <- function(input, output) {
  ##### Data Explorer
  # filter function based on given minimum/maximum scores & school type(s)
  change_df = function(min, max, sch_typ) {
    df %>%
      dplyr::filter(Score >= min,
                    Score <= max,
                    is.null(sch_typ) | School_Type %in% sch_typ
      )
  }
  
  ##### Statistical Analysis
  # updates data table based on given inputs
  output$df_out = DT::renderDataTable({
    change_df(input$minScore, input$maxScore, input$schools)
  })
  
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
  
  
  
  
  # Create the scatterplot object the plotOutput function is expecting
  # output$scatterplot <- renderPlot({
  #  ggplot(data = df, aes_string(x = input$x, y = input$y,
  #                                  color = input$z)) +
  #  geom_point()
  
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
