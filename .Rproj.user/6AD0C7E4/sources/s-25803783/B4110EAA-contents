require(tidyverse)
require(sf)
require(leaflet)
require(rvest)
require(shiny)

pub_cctv_sf_raw <- read_sf("data/pub-cctv/pub-cctv-geojson.geojson")
pub_sensor_sf_raw <- read_sf("data/pub-water-level-sensors/pub-water-level-sensors-kml.kml")
lta_roadcam_sf <- read_sf("data/lta-road-camera/lta-road-camera-shp/LTA_Road_Enforcement_Camera.shp") %>%
                    st_transform(4326)

# Convert html table nested within "Description" column into a list
xml_to_list <- function(xml_string) {
    xml_string %>%
        read_xml %>%
        html_table() %>%
        .[[1]] %>%
        setNames(c("key", "value")) %>%
        as.list() %>%
        {setNames(.$value, .$key)}
}

# Convert xml string to a list, unnest to columns, and remove Z coordinate
process_sf <- function(sf_raw) {
    sf_raw %>% 
    mutate(Description = Description %>% map(xml_to_list)) %>% 
    unnest_wider(Description) %>% 
    st_as_sf() %>% 
    st_zm()
}


pub_cctv_sf <- pub_cctv_sf_raw %>% process_sf
pub_sensor_sf <- pub_sensor_sf_raw %>% process_sf

pub_cctv_sf %>% leaflet %>% addTiles() %>% addMarkers()


# Access Onemap api -------------------------------------------------------

url <- "https://developers.onemap.sg/commonapi/search"

searchVal <- "Hougang block 576"
response <- httr::GET(url, query= list(searchVal=searchVal,
                                       returnGeom="Y",
                                       getAddrDetails='Y'))

results_sf <- httr::content(response, as="text", encoding = "UTF-8") %>%
                jsonlite::fromJSON() %>% 
                .$results %>% 
                as_tibble %>% 
                st_as_sf(coords=c("LONGITUDE", "LATITUDE")) %>% 
                st_set_crs(4326)

top_result <- results_sf %>% slice(1)


    

lta_roadcam_sf_join <- lta_roadcam_sf %>%
    mutate(ID = paste0("LTA", UNIQUE_ID)) %>% 
    select(ID, INC_CRC) %>% 
    mutate(NAME="")

pub_cctv_sf_join <- pub_cctv_sf %>% 
    select(ID=CCTVID, NAME=REF_NAME, INC_CRC) 

pub_sensor_sf_join <- pub_sensor_sf %>% 
    select(ID=STATION_ID, NAME=STATION_NAME, INC_CRC)


colors_df <- tibble(TYPE=c("lta_roadcam", "pub_cctv", "pub_sensor"),
                    color=c("lightgray", "blue", "green"),
                    icon=c("car", "camera", "tint")
                    )

combined_sf <- bind_rows(lta_roadcam = lta_roadcam_sf_join,
          pub_cctv = pub_cctv_sf_join,
          pub_sensor = pub_sensor_sf_join,
          .id = "TYPE") %>% 
          left_join(colors_df)


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


top_result %>% 
    leaflet() %>%
    addTiles() %>%
    addCircleMarkers(label=~ADDRESS, color="red") %>% 
    addAwesomeMarkers(data=combined_dist_sf,
                      icon=icons,
                      popup=~popup,
                      label=~label)
    

