require(tidyverse)
require(sf)
require(leaflet)
require(rvest)
require(shiny)


combined_sf <- readRDS("data/cache/combined_sf.Rds")
# Access Onemap api -------------------------------------------------------

url <- "https://developers.onemap.sg/commonapi/search"

searchVal <- "Hougang"
response <- httr::GET(url, query= list(searchVal=searchVal,
                                       returnGeom="Y",
                                       getAddrDetails='Y'))


get_results <- function(searchVal){
    #  Calls onemap API, and returns tibble of results
    
    httr::GET(url, query= list(searchVal=searchVal,
                               returnGeom="Y",
                               getAddrDetails='Y')) %>% 
    httr::content(response, as="text", encoding = "UTF-8") %>% 
    jsonlite::fromJSON() %>% 
    .$results %>% 
    as_tibble
}

tibble_to_sf <- function(results_df) {
    results_df %>% 
    st_as_sf(coords=c("LONGITUDE", "LATITUDE")) %>% 
    st_set_crs(4326)
}

results_sf <- searchVal %>%
                get_results %>% 
                tibble_to_sf

top_result <- results_sf %>% slice(1)




colors_df <- tibble(TYPE=c("lta_roadcam", "pub_cctv", "pub_sensor"),
                    color=c("lightgray", "blue", "green"),
                    icon=c("car", "camera", "tint")
                    )

combined_dist_sf <- combined_sf %>% 
                        mutate(distance=st_distance(., top_result, by_element = T)) %>% 
                        arrange(distance) %>% 
                        mutate(dist_rank=1:nrow(.),
                               dist_rank = ifelse(dist_rank<=10, dist_rank, NA), 
                               dist_m = units::set_units(distance, m) %>% as.numeric() %>% round(),
                               popup = glue::glue("<b>Type:</b> {TYPE}",
                                                  "<b>ID:</b> {ID}",
                                                  "<b>Name:</b> {NAME}",
                                                  .sep="<br>"),
                               label = glue::glue("Distance: {dist_m} m"))
                        

icons <- awesomeIcons(
    icon = combined_dist_sf %>% pull(icon),
    iconColor = 'black',
    library = 'fa',
    markerColor = combined_dist_sf %>% pull(color),
    text= combined_dist_sf %>% pull(dist_rank)
)    



    

