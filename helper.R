source("setup.R")

# Access Onemap api -------------------------------------------------------

url <- "https://developers.onemap.sg/commonapi/search"

combined_sf <- readRDS("data/cache/combined_sf2.Rds") %>% st_set_crs(CRS)

get_results <- function(searchVal){
    #  Calls onemap API, and returns tibble of results
    
    result_df <- httr::GET(url, query= list(searchVal=searchVal,
                               returnGeom="Y",
                               getAddrDetails='Y')) %>% 
    httr::content(as="text", encoding = "UTF-8") %>% 
    jsonlite::fromJSON() %>% 
    .$results %>% 
    as_tibble
    
    
    return(result_df)
}

tibble_to_sf <- function(results_df) {
    results_df %>% 
    st_as_sf(coords=c("LONGITUDE", "LATITUDE")) %>% 
    st_set_crs(CRS)
}







    

