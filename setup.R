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

initial_address <- "Environment Building"