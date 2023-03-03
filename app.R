library(shiny)
library(tidyverse)

ui <- fluidPage(
    tabsetPanel(
      tabPanel("About"),
      tabPanel("Plots", 
               titlePanel("Old Faithful Geyser Data"),
               
               sidebarLayout(
                 sidebarPanel(
                   sliderInput("bins",
                               "Number of bins:",
                               min = 1,
                               max = 50,
                               value = 30)
                 ),
                 mainPanel(
                   plotOutput("distPlot")
                 )
               )
            ),
      tabPanel("Tables")
    )
    
)

server <- function(input, output) {

}

# Run the application 
shinyApp(ui = ui, server = server)
