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
    
    search_input <- eventReactive(
                        input$address_search_btn,
                        input$address_search)
    
    output$addresses_returned <- renderTable({search_input() %>%
                                              get_results %>% 
                                              slice(1) %>% 
                                              select(ADDRESS, POSTAL, LATITUDE, LONGTITUDE) %>% 
                                              pivot_longer(cols=everything())})
}
