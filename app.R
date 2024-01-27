library(shinyBS)

ui <- fluidPage(
  tags$head(
    tags$link(rel = "apple-touch-icon", sizes = "180x180", href = "/apple-touch-icon.png"),
    tags$link(rel = "icon", type = "image/png", sizes = "32x32", href = "/favicon-32x32.png"),
    tags$link(rel = "icon", type = "image/png", sizes = "16x16", href = "/favicon-16x16.png"),
    tags$link(rel = "manifest", href = "/site.webmanifest")
  ),
  
  shinyjs::useShinyjs(),
  
  titlePanel('CNC Mill Feeds and Speeds Helper', windowTitle = "Cheltenham Hackspace CNC Calculator"),
  
  tabsetPanel(
    tabPanel(
      title = "Calculate",
      calculate_page_ui(id = "calculate")
    ),
    tabPanel(
      title = "Record",
      parameter_record_input_panel_ui(id = 'record_parameters')
    )
  )
)

server <- function(input, output, session) {
  records_changed <- parameter_record_input_panel_server(id = 'record_parameters')
  calculate_page_server(id = "calculate", records_changed = records_changed)
}

# Run the application
shinyApp(ui = ui, server = server)
