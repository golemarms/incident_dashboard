source("setup.R")

pub_cctv_sf_raw <- read_sf("data/cctv_layers/PUB_CCTV_PUBLIC.shp")
pub_sensor_sf_raw <- read_sf("data/cctv_layers/PUB_WATERLEVELSENSORS.shp")
lta_roadcam_sf_raw <- read_sf("data/cctv_layers/LTA_ROAD_ENFORCEMENT_CAMERA.shp")
lta_emas_sf_raw <- read_sf("data/cctv_layers/GIS_EMAS_WEBCAM.shp")
lta_speedcam_sf_raw <- read_sf("data/cctv_layers/MCE_KPE_SPEED_CAMERA.shp")

pub_cctv_sf <- pub_cctv_sf_raw %>% 
    select(ID=CCTVID, NAME=REF_NAME, INC_CRC)

pub_sensor_sf <- pub_sensor_sf_raw %>% 
    select(ID=STATION_ID, NAME=STATION_NA, INC_CRC)

lta_roadcam_sf <- lta_roadcam_sf_raw %>% 
    transmute(ID=as.character(UNIQUE_ID), INC_CRC)

lta_emas_sf <- lta_emas_sf_raw %>% 
    select(ID=EQT_ID, INC_CRC)

lta_speedcam_sf <- lta_speedcam_sf_raw %>% 
    select(ID=CAM_ID, INC_CRC)

combined_sf <- bind_rows(pub_cctv = pub_cctv_sf,
                         pub_sensor = pub_sensor_sf,
                         lta_roadcam = lta_roadcam_sf,
                         lta_emas = lta_emas_sf,
                         lta_speedcam = lta_speedcam_sf,
                         .id = "TYPE") %>% 
    left_join(colors_df) %>% 
    mutate(
        popup = glue::glue("<b>Type:</b> {TYPE}",
                           "<b>ID:</b> {ID}",
                           "<b>Name:</b> {NAME}",
                           .sep="<br>")
    ) %>%
    st_transform(CRS)  
            

saveRDS(combined_sf, "data/cache/combined_sf2.Rds")