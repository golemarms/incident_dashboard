source("helper.R")

# Define server logic required to draw a histogram
 server <- function(input, output, session) {

     
    output$mymap <- renderLeaflet({top_result %>%
            leaflet() %>%
            addTiles() %>%
            addCircleMarkers(label=~ADDRESS, color="red") %>%
            addAwesomeMarkers(data=combined_dist_sf,
                              icon=icons,
                              popup=~popup,
                              label=~label)

    })

}
