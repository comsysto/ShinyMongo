#
# ShinyMongo App
# a simple R based MongoDB - Viewer
# 
# Markus Schmidberger, markus.schmidberger@comsysto.com
# June, 2013

library(shiny)

# Define UI for miles per gallon application
shinyUI(pageWithSidebar(
  
  # Application title
  headerPanel("ShinyMongo"),
  
  # Sidebar
  sidebarPanel(
    
    textInput("host", "Host:", "localhost"),
    textInput("username", "Username:", ""),
    textInput("password", "Password:", ""),
    
    uiOutput("dbs"),
   
    uiOutput("collections"),
    
    uiOutput("query"),

    br(),br(),
    helpText("Development: markus.schmidberger@comsysto.com"),
    helpText("more at https://github.com/comsysto/ShinyMongo")
    ),
  
  # main window
  mainPanel(
    
    textOutput("connection"),
    
    conditionalPanel(
      condition = "input.collections_input == '-'",
      h4("Collections overview:"),
      tableOutput("view_collections")
    ),
    
    conditionalPanel(
      condition = "input.collections_input != '-'",
      h4(textOutput("view_head")),
      tableOutput("view")
    )
    
  )

))
