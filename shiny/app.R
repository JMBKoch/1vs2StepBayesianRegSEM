# Load necessary libraries
library(shiny)
library(ggplot2)
library(ggthemes)
library(papaja)

# gaat uit dat je in een shiny-map zit met de datapprep.R en da app.R script erin

if(!file.exists("svnp_samples.Rds") && !file.exists("rhsp_samples.Rds")){
message("generating samples. This may take a while.")
  source("dataprep.R")
  svnp_samples <- readRDS("svnp_samples.Rds")
  rhsp_samples <- readRDS("rhsp_samples.Rds")
}else{
  svnp_samples <- readRDS("svnp_samples.Rds")
  rhsp_samples <- readRDS("rhsp_samples.Rds") 
}

# Define UI
ui <- fluidPage(
  titlePanel("Comparison of Priors"),
  sidebarLayout(
    sidebarPanel(
      selectInput("sigma_select", 
                  "Select \u03c3\u00B2 Value for SVNP", 
                  choices = c(0.1, 0.01, 0.001), 
                  selected = 0.01),
      selectInput("scaleGlobal_select", 
                  "Select Scale Global for RHSP", 
                  choices = c(0.1, 1), 
                  selected = 1),
      selectInput("scaleLocal_select", 
                  "Select Scale Local for RHSP", 
                  choices = c(0.1, 1), 
                  selected = 1),
      selectInput("dfGlobal_select", 
                  "Select df Global for RHSP", 
                  choices = c(1, 3), 
                  selected = 1),
      selectInput("dfLocal_select", 
                  "Select df Local for RHSP", 
                  choices = c(1, 3), 
                  selected = 1),
      selectInput("nu_select", 
                  "Select Nu for RHSP", 
                  choices = c(1, 3), 
                  selected = 1),
      selectInput("scaleSlab_select", 
                  "Select Scale Slab for RHSP", 
                  choices = c(0.1, 1, 5), 
                  selected = 1)
    ),
    mainPanel(
      plotOutput("priorPlot")
    )
  )
)

# Define server function
server <- function(input, output, session) {
  # Reactive expression to fetch SVNP samples
  svnp_reactive <- reactive({
    key <- paste0("SVNP_sigma_", input$sigma_select)
    svnp_samples[[key]]
  })
  
  # Reactive expression to fetch RHSP samples
  rhsp_reactive <- reactive({
    key <- paste0("RHSP_nu_", input$nu_select,
                  "_scaleGlobal_", input$scaleGlobal_select,
                  "_scaleLocal_", input$scaleLocal_select,
                  "_dfGlobal_", input$dfGlobal_select,
                  "_dfLocal_", input$dfLocal_select,
                  "_scaleSlab_", input$scaleSlab_select)
    rhsp_samples[[key]]
  })
  
  # Render plot
  output$priorPlot <- renderPlot({
    svnp <- svnp_reactive()
    rhsp <- rhsp_reactive()
    
    data <- data.frame(
      dens = c(svnp, rhsp),
      prior = rep(c("SVNP", "RHSP"), each = length(svnp))
    )
    
    ggplot(data, aes(x = dens, fill = prior)) +
      geom_density(alpha = 0.5) +
      xlim(-0.5, 0.5) +
      labs(
        x = "Size Cross Loading",
        y = "Density",
        title = "Density Comparison of Priors"
      ) +
      theme_apa()
  })
}

# Run the app
shinyApp(ui = ui, server = server)
