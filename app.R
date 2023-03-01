#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above (in RStudio)
#
# 
#
#
#

# Required libraries
library(shiny)    # CRAN v1.7.4
library(ggplot2)  # CRAN v3.4.0
library(ggthemes) # CRAN v4.2.4
library(plotly)   # CRAN v4.10.1

# Required sourced functions
source("source/plot_rel_error.R") # plotting function
source("source/calculate_mu.R") # growth rate function dependency
source("source/calculate_sigma_mu.R") # sigma mu function dependency
source("source/create_test_dataset.R") # test dataset function



#### UI

# Define UI for application
ui <- fluidPage(
  theme = bslib::bs_theme(bootswatch = "united"),
  # Application title
  titlePanel("Raman SIP Incubation App"),
  # Set the layout:
    sidebarLayout(
      sidebarPanel(
        fluidRow(
          textInput("fls", label = "Label strengths (%), comma separated", value = "5, 10, 15, 20, 25, 30, 35, 40, 45, 50"),
        ),
        fluidRow(
          textInput("inc_times", label = "Incubation Times (days), comma separated", value = "1, 5, 7, 30, 60, 100"),
        ),
        fluidRow(
          sliderInput("assim_a", label = "Hydrogen Assimilation Efficiency (a)", value = 1, min = 0, max = 1),
        ),
        fluidRow(
          column(4, textInput("sassim_a", label = "Uncertainty in hydrogen assimilation efficiency", value = 0)),
          column(8, 
                 textInput("sfl", label = "SE of Label Strength (%)", value = 0),
                 textInput("sf2", label = "SE of Raman 2H measurements (%)", value = 2.5)
                 )
        ),
        fluidRow(
          column(8,
                 numericInput("dt", label = "Highlighted Incubation Time", value = 30),
                 numericInput("f_label", label = "Highlighted Tracer Strength (%)", value = 20),
                 sliderInput("xlimits", label = "Plot x limits", value = c(0, 300), min = 0, max = 1000)
                 )
        )
      ),
      # plots
      mainPanel(
        plotOutput("p_rel_error")
      )
    )
    
    # Diagnostic Print Statements
    # textOutput("greeting"),
    # verbatimTextOutput("fls"),
    # verbatimTextOutput("dts"),
    # verbatimTextOutput("assim_a"),
    # verbatimTextOutput("sassim_a"),
    # verbatimTextOutput("sfl"),
    # verbatimTextOutput("sf1"),

)





#### SERVER

# Define server logic required to plot
server <- function(input, output) {
  # Define reactive things
  # A greeting (deprecated)
  concat_str <- reactive({paste("A", input$dt, "day incubation time with", input$f_label, "% D2O:")})
  
  # A numeric vector of label strengths for test data (TD)
  fls_num <- reactive({as.numeric(str_split_1(input$fls, pattern = ","))})
  
  # A numeric vector of incubation times for TD
  incs_num <- reactive({as.numeric(str_split_1(input$inc_times, pattern = ","))})
  
  # Assimilation efficiency and error in assimilation efficiency for TD
  assim_a_dbl <- reactive({as.numeric(input$assim_a)})
  sassim_a_dbl <- reactive({as.numeric(input$sassim_a)})
  
  # error in isotope measurements for label (sfl) and raman (sf2)
  sfl_dbl <- reactive({as.numeric(input$sfl)})
  sf2_dbl <- reactive({as.numeric(input$sf2)})
  
  # Create simulated dataset from reactive objects
  simulated_data <- reactive({
    create_test_dataset(
      # input reactive objects as function arguments
      a = assim_a_dbl(),
      sigma_a = sassim_a_dbl(),
      sigma_FL = sfl_dbl(),
      sigma_F2 = sf2_dbl(),
      FL = fls_num(),
      dt = incs_num()
    )
  })
  
  
  # Define outputs
  # Print statements
  output$fls <- renderPrint({fls_num()})
  output$dts <- renderPrint({incs_num()})
  output$sassim_a <- renderPrint({sassim_a_dbl()})
  output$assim_a <- renderPrint({assim_a_dbl()})
  output$sfl <- renderPrint({sfl_dbl()})
  output$sf2 <- renderPrint({sf2_dbl()})
  
  # Plot output
  output$p_rel_error <- renderPlot({
    plot_rel_error(
      simulated_data(),
      d_t = input$dt,
      f_label = input$f_label,
      xlimits = input$xlimits,
      include_legend = TRUE
      )
  })
  
  output$p_rel_error_plotly <- renderPlot({
    plot_rel_error(
      simulated_data(),
      d_t = input$dt,
      f_label = input$f_label,
      xlimits = input$xlimits,
      include_legend = TRUE
    ) |> plotly::ggplotly() })

   
}

# Run the application 
shinyApp(ui = ui, server = server)
