#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
require(tidyverse)
require(leaflet)

 ui <- fluidPage(

    # Application title
    titlePanel("Incident search"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            textInput("address_search", "Address Search"),
            actionButton("address_search_btn", "Search"),
            tableOutput("addresses_returned"),
            width=3

        ),

        # Show a plot of the generated distribution
        mainPanel(
            leafletOutput("mymap", height = "600px")
        )
    )
)


