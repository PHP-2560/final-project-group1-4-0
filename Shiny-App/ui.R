ui = navbarPage("UniversityRankings", id="nav",
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
                                  numericInput("maxScore", "Max Score", value = 100,min=0, max=101)
                           )
                         ),
                         hr(),
                         DT::dataTableOutput("df_out")
                ),
                
                ##### Statistical Analysis
                tabPanel("Statistical Analysis",
                         theme = shinytheme("cerulean"),
                         
                         
                         # Application title
                         titlePanel("PHP2560/1560 Shiny App"),
                         
                         # Sidebar layout with a input and output definitions
                         sidebarLayout(
                           
                           # Inputs
                           sidebarPanel(
                             
                             # Select variable for y-axis
                             selectInput(inputId = "y", 
                                         label = "Y-axis:",
                                         choices = c("Endowment", "Median_Start_Sal", "Acc_Rate", "Score", "Tuition"), 
                                         selected = "Score"),
                             
                             # Select variable for x-axis
                             selectInput(inputId = "x", 
                                         label = "X-axis:",
                                         choices = c("Endowment", "Median_Start_Sal", "Acc_Rate", "Score", "Tuition"), 
                                         selected = "Acc_Rate"),
                             
                             # Select variable for color
                             selectInput(inputId = "z", 
                                         label = "Color by:",
                                         choices = c("School_Type", "Religion"),
                                         selected = "School_Type"),
                             
                             # Enter text for plot title
                             textInput(inputId = "plot_title", 
                                       label = "Plot title", 
                                       placeholder = "Enter text to be used as plot title"),
                             
                             # Select which types of school
                             checkboxGroupInput(inputId = "selected_type",
                                                label = "Select school type:",
                                                choices = c("Public", "Private", "Proprietary"),
                                                selected = "Private")
                           ),
                           
                           # Outputs
                           mainPanel(
                             plotOutput(outputId = "scatterplot"),
                             plotOutput(outputId = "densityplot", height = 200),
                             verbatimTextOutput(outputId = "lmoutput") # regression output
                           )
                         )
                ),
                conditionalPanel("true", icon("crosshair")),
                singleton(shiny::tags$head(
                  shiny::tags$script(src="//cdnjs.cloudflare.com/ajax/libs/annyang/2.6.0/annyang.min.js"),
                  includeScript('voice.js')
                ))
)

           
