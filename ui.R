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
            h3("Address Search"),
            textInput("address_search",
                      label=NULL,
                      value=initial_address,
                      placeholder = "Address, postal code etc."),
            actionButton("address_search_btn", label="Search", class ="btn btn-primary"),
            h3("Current address"),
            tableOutput("result_info"),
            h3("Nearest devices"),
            tableOutput("nearest_devices"),
            width=4

        ),

        # Show a plot of the generated distribution
        mainPanel(
            leafletOutput("mymap", height = "600px")
        )
    )
)


