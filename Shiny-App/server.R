# helper functions that are called on by server
change_df = function(min, max, sch_typ) {
  df %>%
    dplyr::filter(score >= min,
                  score <= max,
                  is.null(sch_typ) | school_type %in% sch_typ
    )
}


function(input, output, session) {
  ##### Map
  
  ##### Plots & Statistical Outputs
  
  ##### Data Explorer
  # updates data explorer table based on given inputs
  output$df_out = DT::renderDataTable({
    change_df(input$minScore, input$maxScore, input$schools)
  })
  
}  
