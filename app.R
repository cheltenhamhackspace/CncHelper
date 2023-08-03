library(shinyBS)

ui <- fluidPage(
  shinyjs::useShinyjs(),
  
  titlePanel('CNC Mill Feeds and Speeds Helper'),
  
  sidebarLayout(
    sidebarPanel(
      parameter_input_panel_ui(id = 'select_parameters')
    ),
    
    mainPanel(
      feeds_and_speeds_panel_ui(id = 'feeds_and_speeds'),
      
      hr(),
      
      bsCollapse(
        id = 'record_parameters',
        bsCollapsePanel(
          title = 'Click here to record your own parameters',
          parameter_record_input_panel_ui('record_parameters')
        )
      ),
      
      h3('Member Recommendations'),
      
      bsCollapse(
        id = 'filters',
        bsCollapsePanel(
          title = 'Click for filters',
          filter_panel_ui(id = 'filter_panel')
        )
      ),
      
      uiOutput(outputId = 'records_list')
    )
  )
)

server <- function(input, output, session) {
  
  select_reactives = parameter_input_panel_server(id = 'select_parameters')
  
  select_work_material <- select_reactives$select_work_material
  select_tool_material <- select_reactives$select_tool_material
  select_tool_type <- select_reactives$select_tool_type
  select_tool_diameter <- select_reactives$select_tool_diameter
  select_tool_flutes <- select_reactives$select_tool_flutes
  select_cut_type <- select_reactives$select_cut_type
  select_tool_stepover <- select_reactives$select_tool_stepover
  select_tool_stepdown <- select_reactives$select_tool_stepdown
  select_tool_advance <- select_reactives$select_tool_advance
  
  feeds_and_speeds_panel_server(
    id = 'feeds_and_speeds',
    select_work_material,
    select_tool_material,
    select_tool_type,
    select_tool_diameter,
    select_tool_flutes,
    select_cut_type,
    select_tool_stepover,
    select_tool_advance,
    select_reactives$select_cut_is_sideways
  )
  
  records_changed <- parameter_record_input_panel_server('record_parameters')$record_submit
  
  filter_reactives <- filter_panel_server(id = 'filter_panel')
  
  filter_work_material <- filter_reactives$filter_work_material
  filter_tool_material <- filter_reactives$filter_tool_material
  filter_tool_type <- filter_reactives$filter_tool_type
  filter_tool_diameter <- filter_reactives$filter_tool_diameter
  filter_tool_flutes <- filter_reactives$filter_tool_flutes
  filter_cut_type <- filter_reactives$filter_cut_type
  filter_success <- filter_reactives$filter_success
  
  records <- reactive({
    # Take dependency on record submit button
    records_changed()
    
    # Retrieve filtered records
    records_df <- get_records(
      ifelse(filter_work_material(), select_work_material(), NA),
      ifelse(filter_tool_material(), select_tool_material(), NA),
      ifelse(filter_tool_type(), select_tool_type(), NA),
      ifelse(filter_tool_diameter(), select_tool_diameter(), NA),
      ifelse(filter_tool_flutes(), select_tool_flutes(), NA),
      ifelse(filter_cut_type(), select_cut_type(), NA),
      filter_success()
    )
    
    # Return sorted data frame of records
    return(records_df[order(records_df$axis_feed, decreasing = TRUE), ])
  })
  
  # Fetch suggestions from database
  output$records_list <- renderUI({
    suggestions_panel_ui(
      id = 'mill_suggestions',
      records()
    )
  })
  
  observe({
    suggestions_panel_server('mill_suggestions', records(), records_changed)
  })
}

# Run the application
shinyApp(ui = ui, server = server)
