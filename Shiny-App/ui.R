navbarPage("UniversityRankings",
           id="nav",
           ##### Map
           # tab for map
           
           ##### Plots & Statistical Outputs
           # tab for ggplots & statistic outputs
           
          
           ##### Data Explorer
           # tab for data explorer 
           tabPanel("Data explorer",
                    # option to filter by public schools, private schools, or both
                    fluidRow(
                      column(3,
                             selectInput("schools", "Schools", c("Public", "Private"), multiple=TRUE)
                      )
                    ),
                    # option to filter by a minimum and maximum score (as rated by US News)
                    # defaults to show all schools
                    fluidRow(
                      column(1,
                             numericInput("minScore", "Min Score", value = 0, min=0, max=100)
                      ),
                      column(1,
                             numericInput("maxScore", "Max Score", value = 100,min=0, max=100)
                      )
                    ),
                    hr(),
                    DT::dataTableOutput("df_out")
           ),
           conditionalPanel("true", icon("crosshair"))
)

           
