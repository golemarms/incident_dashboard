library(shiny)
library(shinyWidgets)

ui <- fluidPage(
    tags$h2("Update searchinput"),
    searchInput(
        inputId = "search", label = "Enter your text",
        placeholder = "A placeholder",
        btnSearch = icon("search"),
        btnReset = icon("remove"),
        width = "450px"
    ),
    br(),
    verbatimTextOutput(outputId = "res"),
    br(),
    textInput(
        inputId = "update_search",
        label = "Update search"
    ),
    checkboxInput(
        inputId = "trigger_search",
        label = "Trigger update search",
        value = TRUE
    )
)

server <- function(input, output, session) {
    
    output$res <- renderPrint({
        input$search
    })
    
    observeEvent(input$update_search, {
        updateSearchInput(
            session = session,
            inputId = "search",
            value = input$update_search,
            trigger = input$trigger_search
        )
    }, ignoreInit = TRUE)
}

shinyApp(ui, server)

