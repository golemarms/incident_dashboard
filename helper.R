require(tidyverse)
require(sf)
require(leaflet)
require(rvest)
require(shiny)


combined_sf <- readRDS("data/cache/combined_sf.Rds")

colors_df <- tibble(TYPE=c("lta_roadcam", "pub_cctv", "pub_sensor"),
                    color=c("lightgray", "blue", "green"),
                    icon=c("car", "camera", "tint")
)

max_rank <- 5

# Access Onemap api -------------------------------------------------------

url <- "https://developers.onemap.sg/commonapi/search"


get_results <- function(searchVal){
    #  Calls onemap API, and returns tibble of results
    
    httr::GET(url, query= list(searchVal=searchVal,
                               returnGeom="Y",
                               getAddrDetails='Y')) %>% 
    httr::content(as="text", encoding = "UTF-8") %>% 
    jsonlite::fromJSON() %>% 
    .$results %>% 
    as_tibble
}

tibble_to_sf <- function(results_df) {
    results_df %>% 
    st_as_sf(coords=c("LONGITUDE", "LATITUDE")) %>% 
    st_set_crs(4326)
}







    

