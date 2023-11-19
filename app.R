# Load required packages
# commented packages are called but dont need to be loaded in-full
library(shiny)     # CRAN v1.7.4

#library(dplyr)     # CRAN v1.1.3
#library(tidyr)     # CRAN v1.3.0
#library(stringr)   # CRAN v1.5.0
#library(ggplot2)   # CRAN v3.4.0
#library(ggthemes)  # CRAN v4.2.4
#library(plotly)    # CRAN v4.10.1
#library(cowplot)   # CRAN v1.1.1 
#library(latex2exp) # CRAN v0.9.6

# Required sourced functions
source("source/plot_rel_error.R") # plotting function for gen_time
source("source/calculate_mu.R") # growth rate function dependency
source("source/calculate_sigma_mu.R") # sigma mu function dependency
source("source/create_test_dataset.R") # test dataset function
source("source/plot_rel_error_at2H.R") # plotting function for 2F
source("source/plotly_rel_error_at2H.R") # plotly function for 2F!
source("source/plotly_rel_error.R") # plotly function for gen_time!
source("source/plot_rel_error_inc.R") # plotting function for multiple incubation times
source("source/tabulate_data.R") # summarize the results of the model

#### UI

# Define UI for application
ui <- fluidPage(
  # Set the theme
  theme = bslib::bs_theme(bootswatch = "yeti"),
  
  # Application title
  titlePanel("Shiny rSIP"),
  
  # define the layout
  sidebarLayout(
    # what's in the sidebar (left of page)
    sidebarPanel(
      textInput("fls", label = "Label strengths (%), comma separated", value = "5, 10, 15, 20, 25, 30, 35, 40, 45, 50"),
      textInput("inc_times", label = "Incubation Times (days), comma separated", value = "1, 5, 7, 30, 60, 100"),
      sliderInput("assim_a", label = "Hydrogen Assimilation Efficiency (a)", value = 0.85, min = 0, max = 1),
      textInput("sassim_a", label = "Uncertainty in hydrogen assimilation efficiency", value = 0.017),
      textInput("sfl", label = "Uncertainty of Label Strength (%)", value = 0),
      textInput("sf2", label = "Uncertainty of Raman 2H measurements (%)", value = 2.5),
      selectInput("f_label", "Highlighted Label Strength", choices = c(35)),
      selectInput("dt", "Highlighted Incubation Time", choices = c(30)),
      #numericInput("dt", label = "Highlighted Incubation Time", value = 30),
      #numericInput("f_label", label = "Highlighted Label Strength (%)", value = 30),
      sliderInput("xlimits_gen", label = "Plot 1 x-limits", value = c(0, 300), min = 0, max = 1000),
      sliderInput("xlimits_2F", label = "Plot 2 x-limits", value = c(0, 60), min = 0, max = 100)
    ),
    
    # what's in the main panel (center of page):
    mainPanel(
      tabsetPanel(
        tabPanel(
          "Plots",
          fluidRow(),
           # top two plots:
           fluidRow(
             h4("Plot: Multiple Label Strengths"),
             plotOutput("p_rel_error"),
             width = 8,
             height = 20
           ),
           # bottom plot:
           fluidRow(
             h4("Plot: Multiple Incubation Times"),
             plotOutput("p_rel_error_inc"),
             width = 6,
             height = 20
           ),
        ),
        
        # tabulated output
        tabPanel(
          title = "Table Output",
          h6("Please be patient - it may take a moment to render the tables."),
          h3("Summary of Results"),
          tableOutput(outputId = "tabulated_results"),
          h3("Downloads"),
          downloadButton(outputId = "downloadtabulated",
                         label = "Download Summary"),
          # Button
          downloadButton(outputId = "downloadmodeldata", 
                         label = "Download All Model Output"),
          # Uncomment to show all the model output in the GUI --
          # Slows down the app a LOT!
          #tableOutput(outputId = "model_output")
        ),
        
        # plotly plots
        tabPanel(
          "Interactive Plots",
          withMathJax(
            plotlyOutput("p_rel_error_plotly")),
          plotlyOutput("p_rel_error_plotly_at2H")
        ),
        
        # howto .md file
        tabPanel(
          "How-To",
          fluidRow(includeMarkdown("howto.md"))
        ),
        
        # about .md file
        tabPanel(
          "About",
          fluidRow(
            includeMarkdown("about.md")
          )
        )
      )
    )
  )
)



#### SERVER

# Define server logic required to plot
server <- function(input, output) {

  # define observe that allows updating the label choices based off user input
  observeEvent(input$fls, {
    fl_choices <- as.numeric(str_split_1(input$fls, pattern = ","))
    print(fl_choices)
    # Can use character(0) to remove all choices
    if (is.null(fl_choices))
      fl_choices <- character(0)

    selected <- NULL
    if (input$f_label %in% fl_choices) 
      selected <- input$f_label
    
    ### This breaks the app!! Why ?? :c
    updateSelectInput(inputId = "f_label", choices = fl_choices, selected = selected)
  })

  # define observe that allows updating the incubation time choices based off user input
  observeEvent(input$inc_times, {
    dt_choices <- as.numeric(str_split_1(input$inc_times, pattern = ","))
    print(dt_choices)
    # Can use character(0) to remove all choices
    if (is.null(dt_choices))
      dt_choices <- character(0)
    
    selected.dt <- NULL
    if (input$dt %in% dt_choices) 
      selected.dt <- input$dt
    
    ### This breaks the app!! Why ?? :c
    updateSelectInput(inputId = "dt", choices = dt_choices, selected = selected.dt)
  })
  
  
  # Define reactive things
  # A greeting (deprecated)
  concat_str <- reactive({paste("A", input$dt, "day incubation time with", input$f_label, "% D2O:")})
  fls_num <- reactive({as.numeric(str_split_1(input$fls, pattern = ","))})
  
  # A numeric vector of incubation times for TD
  incs_num <- reactive({as.numeric(str_split_1(input$inc_times, pattern = ","))})
  
  # Assimilation efficiency and error in assimilation efficiency for TD
  assim_a_dbl <- reactive({as.numeric(input$assim_a)})
  sassim_a_dbl <- reactive({as.numeric(input$sassim_a)})
  
  # error in isotope measurements for label (sfl) and raman (sf2)
  sfl_dbl <- reactive({as.numeric(input$sfl)})
  sf2_dbl <- reactive({as.numeric(input$sf2)})
  
  # Create simulated dataset reactive object from other reactives
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
  
  # create an outcome summary reactive from the simulated_data reactive
  outcome_summary <- reactive({
    tabulate_data(simulated_data(),
                  d_t = input$dt,
                  f_label = input$f_label)
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
  
  output$p_rel_error_inc <- renderPlot({
    plot_rel_error_inc(
      simulated_data(),
      d_t = input$dt,
      f_label = input$f_label,
      xlimits = input$xlimits_gen,
      include_legend = TRUE
    )
  })
  
 
  
  # output a DT ---
  output$tabulated_results <- renderTable(outcome_summary())
  output$model_output <- renderTable(simulated_data())
  
  # downloadable csv of dataset ---
  output$downloadmodeldata <- downloadHandler(
    filename = "rSIP_model_output.csv",
    content = function(file) {
      write.csv(simulated_data(), file, row.names = FALSE)
    }
  )
  
  output$downloadtabulated <- downloadHandler(
    filename = "rSIP_summary.csv",
    content = function(file) {
      write.csv(outcome_summary(), file, row.names = FALSE)
    }
  )
  
}

# Run the application 
shinyApp(ui = ui, server = server)

