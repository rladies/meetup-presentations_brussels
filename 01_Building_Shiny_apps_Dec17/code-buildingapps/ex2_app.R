library(shiny)

ui <- fluidPage(
  headerPanel(title="Personal Information"),
  sidebarPanel(textInput("name","Name"),
               
               textInput("age","Age"),
               
               selectInput(inputId = "city",label = "City",
                           choices = list("","Brussels","Brugge", "Antwerpen")),
               radioButtons("gender", "Select the gender", list("Male","Female"), "")
  ),#endsidebarPanel
  mainPanel(
    textOutput("myname"),
    textOutput("myage"),
    textOutput("mycity"),
    textOutput("mygender")
            
  )
)

server <- function(input, output) {
  

  output$myname <- renderText({input$name})
  output$myage <- renderText({input$age})
  output$mygender <- renderText({input$gender})
  output$mycity <- renderText({input$city})
}

shinyApp(ui = ui, server = server)