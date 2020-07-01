require(tidyverse)
require(sf)
require(leaflet)
require(rvest)
require(shiny)

# install.packages("lwgeom")

combined_sf <- readRDS("data/cache/combined_sf.Rds") %>% st_set_crs(4326)

colors_df <- tibble(TYPE=c("lta_roadcam", "pub_cctv", "pub_sensor"),
                    color=c("lightgray", "blue", "green"),
                    icon=c("car", "camera", "tint")
)

max_rank <- 5

initial_address <- "Environment Building"