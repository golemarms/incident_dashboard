source("setup.R")

 ui <- fluidPage(

    # Geolocation script
    tags$script('
      $(document).ready(function () {
        navigator.geolocation.getCurrentPosition(onSuccess, onError);
              
        function onError (err) {
          Shiny.onInputChange("geolocation", false);
        }
              
        function onSuccess (position) {
          setTimeout(function () {
            var coords = position.coords;
            console.log(coords.latitude + ", " + coords.longitude);
            Shiny.onInputChange("geolocation", true);
            Shiny.onInputChange("geolocate_lat", coords.latitude);
            Shiny.onInputChange("geolocate_long", coords.longitude);
          }, 1100)
        }
      });
             '),
    
    # Application title
    titlePanel("Incident search"),
    

    sidebarLayout(
        sidebarPanel(
            h3("Address Search"),
            textInput("address_search",
                      label=NULL,
                      value=initial_address,
                      placeholder = "Address, postal code etc."),
            actionButton("address_search_btn", label="Search", class ="btn btn-primary"),
            actionButton("geolocate_btn", label="My current location", class ="btn btn-secondary"),
            h3("Current address"),
            tableOutput("result_info"),
            h3("Nearest devices"),
            tableOutput("nearest_devices"),
            width=4

        ),

        # Show a plot of the generated distribution
        mainPanel(
            leafletOutput("mymap", height = "600px")
        )
    )
)


