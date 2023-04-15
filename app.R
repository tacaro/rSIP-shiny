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
library(cowplot)  # CRAN v1.1.1 
library(latex2exp)

# Required sourced functions
source("source/plot_rel_error.R") # plotting function for gen_time
source("source/calculate_mu.R") # growth rate function dependency
source("source/calculate_sigma_mu.R") # sigma mu function dependency
source("source/create_test_dataset.R") # test dataset function
source("source/plot_rel_error_at2H.R") # plotting function for 2F
source("source/plotly_rel_error_at2H.R") # plotly function for 2F!
source("source/plotly_rel_error.R") # plotly function for gen_time!

#### UI

# Define UI for application
ui <- fluidPage(
  theme = bslib::bs_theme(bootswatch = "united"),
  # Application title
  titlePanel("Raman SIP Incubation App"),
  # Set the layout:
  tabsetPanel(
  tabPanel("Plots",
        fluidRow(
          textInput("fls", label = "Label strengths (%), comma separated", value = "5, 10, 15, 20, 25, 30, 35, 40, 45, 50"),
          textInput("inc_times", label = "Incubation Times (days), comma separated", value = "1, 5, 7, 30, 60, 100"),
          sliderInput("assim_a", label = "Hydrogen Assimilation Efficiency (a)", value = 0.85, min = 0, max = 1),
          textInput("sassim_a", label = "Uncertainty in hydrogen assimilation efficiency", value = 0.017),
          textInput("sfl", label = "Uncertainty of Label Strength (%)", value = 0),
          textInput("sf2", label = "Uncertainty of Raman 2H measurements (%)", value = 2.5),
          numericInput("dt", label = "Highlighted Incubation Time", value = 30),
          numericInput("f_label", label = "Highlighted Tracer Strength (%)", value = 30),
          sliderInput("xlimits_gen", label = "Plot 1 x-limits", value = c(0, 300), min = 0, max = 1000),
          sliderInput("xlimits_2F", label = "Plot 2 x-limits", value = c(0, 60), min = 0, max = 100)
        ),
      # plots
      fluidRow(
        plotOutput("p_rel_error"),
        width = 8,
        height = 20
      )
  ),
  tabPanel("Interactive Plots",
           withMathJax(
             plotlyOutput("p_rel_error_plotly")),
             plotlyOutput("p_rel_error_plotly_at2H")
           ),
  tabPanel("About this App",
           fluidRow(
             textOutput("about_page")
             )
           )
)
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
    cowplot::plot_grid(
    plot_rel_error(
      simulated_data(),
      d_t = input$dt,
      f_label = input$f_label,
      xlimits = input$xlimits_gen,
      include_legend = TRUE
      ),
    plot_rel_error_at2H(
      test_dataset = simulated_data(),
      d_t = input$dt,
      f_label = input$f_label,
      xlimits = input$xlimits_2F,
      include_legend = TRUE,
      include_caption = TRUE
    ),
    ncol = 2
    )
  })

  output$p_rel_error_plotly_at2H <- renderPlotly({
    plotly_rel_error_at2H(
      simulated_data(),
      d_t = input$dt
    )
    })
  
  output$p_rel_error_plotly <- renderPlotly({
    plotly_rel_error(
      simulated_data(),
      d_t = input$dt,
      f_label = input$f_label,
      xlimits = input$xlimits_gen
    )
  })

  
  # Define about page
  output$about_page <- renderText({
    "This app was designed by Tristan Caro at the University of Colorado Boulder. Its purpose is to allow researchers
    interested in applying deuterium stable isotope probing (SIP) to a sample and quantifying microbial growth rates using
    Raman spectroscopy. 
    
    I am happy to answer questions! tristan.caro@colorado.edu"
    })
}

# Run the application 
shinyApp(ui = ui, server = server)

