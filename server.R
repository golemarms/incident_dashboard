source("helper.R")
options(shiny.reactlog=TRUE) 

server <- function(input, output, session) {

    search_input <- reactiveVal(value=initial_address)

    
    results_df <- reactive({
        search_input() %>% 
        get_results 
        
    })
    
    top_result <- reactive({
        req(nrow(results_df()) > 0) ## validation
        
        results_df() %>% 
        slice(1) %>% 
        tibble_to_sf 
    })
    
    ## augment dataframe with distance ranking
    combined_dist_sf <- reactive({
        req(nrow(results_df()) > 0) ## validation
        
        combined_sf %>% 
        mutate(distance=st_distance(., top_result(), by_element = T)) %>% 
        arrange(distance) %>% 
        mutate(dist_rank=1:nrow(.),
               dist_rank = ifelse(dist_rank<=max_rank, dist_rank, NA), 
               dist_m = units::set_units(distance, m) %>% as.numeric() %>% round(),
               label = glue::glue("Distance: {dist_m} m"))
    })
    
    ## create icons (reactive)
    icons <- reactive({
        awesomeIcons(
        icon = combined_dist_sf() %>% pull(icon),
        iconColor = 'black',
        library = 'fa',
        markerColor = combined_dist_sf() %>% pull(color),
        text= combined_dist_sf() %>% pull(dist_rank)
        )   
    })
    
    
    ## BBox of top x points
    bbox_bounds <- reactive({
        combined_dist_sf() %>%
        filter(!is.na(dist_rank)) %>% 
        st_union({top_result()}) %>% 
        st_bbox() %>% 
        as.double()
    })
    
    
    ## Initial rendering of map
    output$mymap <- renderLeaflet({
            combined_sf %>%
            leaflet() %>%
            addTiles() %>% 
            addLegend(data= colors_df, colors=~color, labels = ~TYPE) %>% 
            {exec("fitBounds", . , !!!(combined_sf %>% st_bbox() %>% as.double()))} 
    })
    
    
    top_coords <- reactive({top_result() %>%
            st_coordinates() %>% 
            as.double() 
        })
    
    
    
    ## Update map upon input
    observe({
        leafletProxy("mymap", data = combined_dist_sf()) %>% 
            clearMarkers() %>% 
            clearShapes() %>% 
            clearPopups() %>% 
            {exec("flyToBounds", . , !!!bbox_bounds() )} %>% 
            addAwesomeMarkers(icon=icons(),
                              popup=~popup,
                              label=~label,
                              clusterOptions = markerClusterOptions(
                                                                    # maxClusterRadius=20,
                                                                    disableClusteringAtZoom=14
                                                                    )
                              ) %>% 
            addCircleMarkers(data= top_result(),
                             color="red")  %>% 
            addPopups(lng = top_coords()[1],
                      lat = top_coords()[2],
            popup = top_result()[["ADDRESS"]],
            options = list(closeButton=T)
            )  
        })
    
    
    ## Create reactive source, update search_input (reactiveVal)

    observeEvent(input$address_search_btn,
                 {search_input(input$address_search)})
    
    
    ## Display additional info on current address 
    output$result_info <- renderTable({
          validate( need(nrow(results_df()) > 0, "Invalid search"))
    
          results_df() %>% 
          slice(1) %>% 
          select(ADDRESS, POSTAL) %>% 
          pivot_longer(cols=everything())
        
    },
        striped = T,
        hover= T,
        bordered = T
    )
    
    
    ## Display additional info on top n search results in the form of a table
    output$nearest_devices <- renderTable({
        combined_dist_sf() %>% 
            as_tibble %>% 
            filter(!is.na(dist_rank)) %>% 
            select(RANK=dist_rank, `DISTANCE (m)`=dist_m, TYPE, ID, NAME)
    },
        digits=0,
        striped = T,
        hover= T,
        bordered = T
    )

    # observe({
    #     # print(top_result())
    #     cat("top crs", top_result() %>% st_crs() %>% .$epsg)
    #     print(combined_sf)
    #     cat("combined crs", combined_sf %>% st_crs() %>% .$epsg)
    # })
    # 
    # observe(print(top_coords()))
}
