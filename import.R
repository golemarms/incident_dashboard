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
                left_join(colors_df) %>% 
                mutate(
                        popup = glue::glue("<b>Type:</b> {TYPE}",
                                           "<b>ID:</b> {ID}",
                                           "<b>Name:</b> {NAME}",
                                           .sep="<br>")
)


saveRDS(combined_sf, "data/cache/combined_sf.Rds")