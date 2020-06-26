require(tidyverse)
require(sf)
require(leaflet)
require(rvest)

pub_cctv_sf_raw <- read_sf("data/pub-cctv/pub-cctv-geojson.geojson")
pub_sensor_sf_raw <- read_sf("data/pub-water-level-sensors/pub-water-level-sensors-kml.kml")
lta_roadcam_sf <- read_sf("data/lta-road-camera/lta-road-camera-shp/LTA_Road_Enforcement_Camera.shp")

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
