require(tidyverse)
require(sf)
require(leaflet)
require(rvest)
require(shiny)

# install.packages("lwgeom")


colors_df <- tibble(TYPE=c("pub_cctv", "pub_sensor", "lta_roadcam", "lta_emas", "lta_speedcam"),
                    color=c("blue", "green", "lightgray", "purple", "red"),
                    icon=c("camera", "tint", "car", "car", "car")
)

max_rank <- 5

initial_address <- "Environment Building"

CRS <- 4326 