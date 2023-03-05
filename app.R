library(shiny)
library(tidyverse)

temp <- read_delim("UAH-lower-troposphere-long.csv.bz2")
ui <- fluidPage(
    tabsetPanel(
      tabPanel("About",
               p("This app shows the average temperature deviation (deg C) 
                 from 1978 to 2023 based on region"),
               p("This data set has", strong(nrow(temp)), "rows and", strong(ncol(temp)), "columns" ),
               em("This dataset come from UAH"),
               p("Here are some random sample of the datadet"),
               mainPanel(
                 tableOutput("sample")
               )
               ),
      tabPanel("Plots", 
               sidebarLayout(
                 sidebarPanel(
                   p("This graph shows the change of temperature deviation from 1978 to 2023.
                   You can select the region that you want to discover and the color of the 
                   graph that you like."),
                   radioButtons("color",
                               "Color Palette",
                               choices = c("set1", "set2")),
                   uiOutput("checkboxCut")
                 ),
                 mainPanel(
                   plotOutput("plot"),
                   textOutput("text1")
                 )
               )
            ),
      tabPanel("Tables", 
               sidebarLayout(
                sidebarPanel(
                p("This table shows the change of temperature deviation of globel by different time period"),
                 radioButtons("time",
                       "Select time period",
                       choices = c("month", "year"))
                ),
                  mainPanel(
                    textOutput("text2"),
                    tableOutput("data")
                  )
              )
            )
    )
)

server <- function(input, output) {
  output$sample <- renderTable({
    temp %>% 
      sample_n(6)
  })
  output$checkboxCut <- renderUI({
    checkboxGroupInput("region", "Select Region",
                       choices = unique(temp$region),
                       select = temp$region[1])
  })
  output$plot <- renderPlot({
    graph <- temp %>%
      filter(region %in% input$region) %>%
      mutate(time = year + (month/100)) %>%
      ggplot(aes(year, temp, col = region))+
      geom_point()+
      labs(x = "Year", y = "Temperature deviation", 
           title = "Temperature deviation of region from 1978 to 2019")
    if(input$color == "set1"){
      graph
    }else if(input$color == "set2"){
      graph + scale_color_brewer(palette="Accent")
    }
  })
  
  output$data <- renderTable({
    if(input$time == "month"){
      temp %>% 
        filter(region == "globe") %>% 
        select(year, month, temp)
    }else{
      temp %>%
        filter(region == "globe") %>% 
        group_by(year) %>% 
        summarize(averageTemp = mean(temp))
    }
  })
  
  output$text1 <- renderText({
     paste("You have select", str_flatten_comma(input$region))
  })

  output$text2 <- renderText({
    if(input$time == "month"){
      min_max <- temp %>% 
        filter(region == "globe") %>% 
        summarize(n = min(temp), m = max(temp)) 
         paste("The range is between", min_max $n, "to", min_max $m)
    }else{
      min_max <- temp %>% 
        filter(region == "globe") %>%
        group_by(year) %>% 
        summarize(averageTemp = mean(temp)) %>% 
        summarize(n = min(averageTemp), m = max(averageTemp)) 
      paste("The range is between", min_max $n, "to", min_max $m)
    }
  })
}

shinyApp(ui = ui, server = server)
