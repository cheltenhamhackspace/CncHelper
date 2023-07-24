library(shinyBS)

inline <- function(..., extra_style = '') {
  return(
    div(
      style = paste0('display: inline-block;', extra_style),
      ...
    )
  )
}

format_decimal <- function(decimal, places = 0) {
  return(format(round(decimal, places), nsmall = places))
}

ui <- fluidPage(
  shinyjs::useShinyjs(),
  
  titlePanel('CNC Mill Feeds and Speeds Helper'),
  
  sidebarLayout(
    sidebarPanel(
      h3('Select Workpiece Parameters'),
      selectizeInput(
        inputId = 'select_work_material',
        label = 'Workpiece Material',
        choices = get_work_materials()
      ),
      h3('Select Tool Parameters'),
      selectizeInput(
        inputId = 'select_tool_material',
        label = 'Tool Material',
        choices = get_tool_materials()
      ),
      selectizeInput(
        inputId = 'select_tool_type',
        label = 'Tool Type',
        choices = get_tool_types()
      ),
      numericInput(
        inputId = 'select_tool_diameter',
        label = 'Tool Diameter',
        value = 6,
        min = 0,
        max = 100,
        step = 1
      ),
      numericInput(
        inputId = 'select_tool_flutes',
        label = 'Tool Flute Count',
        value = 2,
        min = 1,
        max = 10,
        step = 1
      ),
      h3('Select Cutting Parameters'),
      conditionalPanel(
        condition = 'output.select_tool_is_side_cutter',
        selectizeInput(
          inputId = 'select_cut_type',
          label = 'Cut Type',
          choices = get_cut_types()
        )
      ),
      conditionalPanel(
        condition = 'output.select_cut_is_sideways',
        numericInput(
          inputId = 'select_tool_stepover',
          label = 'Tool Stepover',
          value = 2,
          min = 0,
          max = 100,
          step = 0.5
        ),
        numericInput(
          inputId = 'select_tool_stepdown',
          label = 'Tool stepdown',
          value = 4,
          min = 0,
          max = 40,
          step = 0.5
        )
      ),
      numericInput(
        inputId = 'select_tool_advance',
        label = 'Tool Advance Distance per Flute',
        value = 0.01,
        min = 0,
        max = 1,
        step = 0.005
      )
    ),
    
    mainPanel(
      h2('Suggested Feeds and Speeds'),
      div(
        inline(h4('Spindle Speed:')),
        inline(textOutput(outputId = 'spindle_speed_text', inline = TRUE)),
        inline(p('RPM'))
      ),
      div(
        inline(h4('Axis Feed Rate:')),
        inline(textOutput(outputId = 'axis_feed_text', inline = TRUE)),
        inline(p('mm per minute'))
      ),
      conditionalPanel(
        'output.select_cut_is_sideways',
        div(
          inline(h4('Axis Feed Rate (Including Chip-Thinning):')),
          inline(textOutput(outputId = 'axis_feed_ct_text', inline = TRUE)),
          inline(p('mm per minute'))
        )
      ),
      
      hr(),
      
      bsCollapse(
        id = 'record_parameters',
        bsCollapsePanel(
          title = 'Click here to record your own parameters',
          
          inline(
            extra_style = 'vertical-align: top;',
            h3('Workpiece Parameters'),
            selectizeInput(
              inputId = 'record_work_material',
              label = 'Workpiece Material',
              choices = get_work_materials()
            ),
            h3('Tool Parameters'),
            selectizeInput(
              inputId = 'record_tool_material',
              label = 'Tool Material',
              choices = get_tool_materials()
            ),
            selectizeInput(
              inputId = 'record_tool_type',
              label = 'Tool Type',
              choices = get_tool_types()
            ),
            numericInput(
              inputId = 'record_tool_diameter',
              label = 'Tool Diameter',
              value = 6,
              min = 0,
              max = 100,
              step = 1
            ),
            numericInput(
              inputId = 'record_tool_flutes',
              label = 'Tool Flute Count',
              value = 2,
              min = 1,
              max = 10,
              step = 1
            )
          ),
          inline(
            extra_style = 'vertical-align: top;',
            h3('Cutting Parameters'),
            conditionalPanel(
              condition = 'output.record_tool_is_side_cutter',
              selectizeInput(
                inputId = 'record_cut_type',
                label = 'Cut Type',
                choices = get_cut_types()
              )
            ),
            conditionalPanel(
              condition = 'output.record_cut_is_sideways',
              numericInput(
                inputId = 'record_tool_stepover',
                label = 'Tool Stepover',
                value = 2,
                min = 0,
                max = 100,
                step = 0.5
              ),
              numericInput(
                inputId = 'record_tool_stepdown',
                label = 'Tool stepdown',
                value = 4,
                min = 0,
                max = 40,
                step = 0.5
              )
            ),
            numericInput(
              inputId = 'record_tool_advance',
              label = 'Tool Advance Distance per Flute',
              value = 0.01,
              min = 0,
              max = 1,
              step = 0.005
            ),
            numericInput(
              inputId = 'record_spindle_speed',
              label = 'Spindle Speed',
              value = 500,
              min = 0,
              max = 10000,
              step = 100
            ),
            numericInput(
              inputId = 'record_feed_rate',
              label = 'Feed Rate',
              value = 100,
              min = 0,
              max = 10000,
              step = 100
            ),
            checkboxInput(
              inputId = 'record_success',
              label = 'Successful?',
              value = TRUE
            ),
            textAreaInput(
              inputId = 'record_notes',
              label = "Notes",
              placeholder = 'Snapped/Cooked cutter?\nAny Chatter?\nStalled spindle?'
            )
          ),
          div(
            actionButton(inputId = 'record_submit', label = 'Submit')
          )
        )
      ),
      
      h3('Member Recommendations'),
      
      bsCollapse(
        id = 'filters',
        bsCollapsePanel(
          title = 'Click for filters',
          checkboxInput(inputId = 'filter_work_material', label = "Workpiece Material", value = TRUE),
          checkboxInput(inputId = 'filter_tool_material', label = "Tool Material", value = TRUE),
          checkboxInput(inputId = 'filter_tool_diameter', label = "Tool Diameter", value = TRUE),
          checkboxInput(inputId = 'filter_tool_type', label = "Tool Type", value = TRUE),
          checkboxInput(inputId = 'filter_tool_flutes', label = "Tool Flute Count", value = TRUE),
          checkboxInput(inputId = 'filter_cut_type', label = "Cut Type", value = TRUE),
          checkboxInput(inputId = 'filter_success', label = "Successful", value = TRUE)
        )
      ),
      uiOutput(outputId = 'records_list')
    )
  )
)

server <- function(input, output, session) {
  # Calculate feeds and speeds
  calculated_rpm <- reactive({
    return(calculate_spindle_speed(
      input$select_work_material,
      input$select_tool_material,
      input$select_tool_diameter,
      input$select_tool_type))
  })
  
  calculated_feed <- reactive({
    return(calculate_axis_feed(calculated_rpm(), input$select_tool_flutes, input$select_tool_advance))
  })
  
  output$spindle_speed_text <- renderText({
    return(format_decimal(calculated_rpm()))
  })
  
  output$axis_feed_text <- renderText({
    return(format_decimal(calculated_feed()))
  })
  
  output$axis_feed_ct_text <- renderText({
    chip_thinned_feed <- calculate_axis_feed_with_chip_thinning(
      calculated_feed(),
      input$select_tool_diameter,
      input$select_cut_type,
      input$select_tool_stepover
    )
    return(format_decimal(chip_thinned_feed))
  })
  
  select_tool_is_side_cutter <- reactive({
    return(tool_cuts_laterally(input$select_tool_type))
  })
  
  record_tool_is_side_cutter <- reactive({
    return(tool_cuts_laterally(input$record_tool_type))
  })
  
  select_cut_is_sideways <- reactive({
    return(is_side_cut(input$select_cut_type))
  })
  
  record_cut_is_sideways <- reactive({
    return(is_side_cut(input$record_cut_type))
  })
  
  output$select_tool_is_side_cutter <- select_tool_is_side_cutter
  outputOptions(output, 'select_tool_is_side_cutter', suspendWhenHidden = FALSE)
  
  output$record_tool_is_side_cutter <- record_tool_is_side_cutter
  outputOptions(output, 'record_tool_is_side_cutter', suspendWhenHidden = FALSE)
  
  output$select_cut_is_sideways <- select_cut_is_sideways
  outputOptions(output, 'select_cut_is_sideways', suspendWhenHidden = FALSE)
  
  output$record_cut_is_sideways <- record_cut_is_sideways
  outputOptions(output, 'record_cut_is_sideways', suspendWhenHidden = FALSE)
  
  observe({
    if (!select_tool_is_side_cutter()) {
      updateSelectizeInput(inputId = 'select_cut_type', selected = 'Plunge')
    }
  })
  
  observe({
    if (!record_tool_is_side_cutter()) {
      updateSelectizeInput(inputId = 'record_cut_type', selected = 'Plunge')
    }
  })
  
  # Submit parameters to database
  observeEvent(
    input$record_submit,
    {
      tryCatch(
        {
          submit_record(
            input$record_work_material,
            input$record_tool_material,
            input$record_tool_type,
            input$record_tool_diameter,
            input$record_tool_flutes,
            input$record_cut_type,
            ifelse(select_tool_is_side_cutter(), input$record_tool_stepover, NA),
            ifelse(select_tool_is_side_cutter(), input$record_tool_stepdown, NA),
            input$record_tool_advance,
            input$record_spindle_speed,
            input$record_feed_rate,
            input$record_success,
            input$record_notes
          )
          shinyalert::shinyalert(
            title = 'Submission accepted',
            closeOnClickOutside = TRUE,
            timer = 3000
          )
        },
        error = function(cond) {
          shinyalert::shinyalert(
            title = 'Submission failed',
            closeOnClickOutside = TRUE,
            timer = 3000
          )
        },
        finally = {
          shinyBS::updateCollapse(
            session = session,
            id = 'record_parameters',
            close = c('Click here to record your own parameters'))
        }
      )
    }
  )
  
  # Fetch suggestions from database
  output$records_list <- renderUI({
    # Take dependency on record submit button
    input$record_submit
    
    create_suggestions_panel(
      get_records(
        ifelse(input$filter_work_material, input$select_work_material, NA),
        ifelse(input$filter_tool_material, input$select_tool_material, NA),
        ifelse(input$filter_tool_type, input$select_tool_type, NA),
        ifelse(input$filter_tool_diameter, input$select_tool_diameter, NA),
        ifelse(input$filter_tool_flutes, input$select_tool_flutes, NA),
        ifelse(input$filter_cut_type, input$select_cut_type, NA),
        input$filter_success
      )
    )
  })
}

# Run the application
shinyApp(ui = ui, server = server)
