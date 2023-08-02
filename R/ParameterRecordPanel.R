parameter_record_input_panel_ui <- function(id) {
  ns = NS(id)
  
  return(
    div(
      inline(
        extra_style = 'vertical-align: top;',
        h3('Select Workpiece Parameters'),
        selectizeInput(
          inputId = ns('record_work_material'),
          label = 'Workpiece Material',
          choices = get_work_materials()
        ),
        h3('Select Tool Parameters'),
        selectizeInput(
          inputId = ns('record_tool_material'),
          label = 'Tool Material',
          choices = get_tool_materials()
        ),
        selectizeInput(
          inputId = ns('record_tool_type'),
          label = 'Tool Type',
          choices = get_tool_types()
        ),
        numericInput(
          inputId = ns('record_tool_diameter'),
          label = 'Tool Diameter',
          value = 6,
          min = 0,
          max = 100,
          step = 1
        ),
        numericInput(
          inputId = ns('record_tool_flutes'),
          label = 'Tool Flute Count',
          value = 2,
          min = 1,
          max = 10,
          step = 1
        )
      ),
      inline(
        extra_style = 'vertical-align: top;',
        h3('Select Cutting Parameters'),
        conditionalPanel(
          condition = 'output.record_tool_is_side_cutter == true',
          ns = ns,
          selectizeInput(
            inputId = ns('record_cut_type'),
            label = 'Cut Type',
            choices = get_cut_types()
          )
        ),
        conditionalPanel(
          condition = 'output.record_cut_is_sideways == true',
          ns = ns,
          numericInput(
            inputId = ns('record_tool_stepover'),
            label = 'Tool Stepover',
            value = 2,
            min = 0,
            max = 100,
            step = 0.5
          ),
          numericInput(
            inputId = ns('record_tool_stepdown'),
            label = 'Tool stepdown',
            value = 4,
            min = 0,
            max = 40,
            step = 0.5
          )
        ),
        numericInput(
          inputId = ns('record_tool_advance'),
          label = 'Tool Advance Distance per Flute (Optional)',
          value = NA,
          min = 0,
          max = 1,
          step = 0.005
        ),
        numericInput(
          inputId = ns('record_spindle_speed'),
          label = 'Spindle Speed',
          value = 500,
          min = 0,
          max = 10000,
          step = 100
        ),
        numericInput(
          inputId = ns('record_feed_rate'),
          label = 'Feed Rate',
          value = 100,
          min = 0,
          max = 10000,
          step = 100
        )
      ),
      inline(
        extra_style = 'vertical-align: top;',
        h3('Cutting Results'),
        checkboxInput(
          inputId = ns('record_success'),
          label = 'Successful?',
          value = TRUE
        ),
        textAreaInput(
          inputId = ns('record_notes'),
          label = "Notes",
          placeholder = 'Snapped/Cooked cutter?\nAny Chatter?\nStalled spindle?'
        )
      ),
      div(
        actionButton(inputId = ns('record_submit'), label = 'Submit')
      )
    )
  )
}

parameter_record_input_panel_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    record_tool_is_side_cutter <- reactive({
      return(tool_cuts_laterally(input$record_tool_type))
    })
    
    record_cut_is_sideways <- reactive({
      return(is_side_cut(input$record_cut_type))
    })
    
    output$record_tool_is_side_cutter <- record_tool_is_side_cutter
    outputOptions(output, 'record_tool_is_side_cutter', suspendWhenHidden = FALSE)
    
    output$record_cut_is_sideways <- record_cut_is_sideways
    outputOptions(output, 'record_cut_is_sideways', suspendWhenHidden = FALSE)
    
    observe({
      if (!record_tool_is_side_cutter()) {
        updateSelectizeInput(inputId = 'record_cut_type', selected = 'Plunge')
      }
    })
    
    record_submitted <- reactiveVal(FALSE)
    
    # Submit parameters to database
    observeEvent(
      input$record_submit,
      {
        parameters <- c(
          'Tool Diameter' = input$record_tool_diameter,
          'Tool Flutes' = input$record_tool_flutes,
          'Tool Stepover' = if (record_tool_is_side_cutter()) input$record_tool_stepover else NULL,
          'Tool Stepdown' = if (record_tool_is_side_cutter()) input$record_tool_stepdown else NULL,
          'Spindle Speed' = input$record_spindle_speed,
          'Feed Rate' = input$record_feed_rate
        )
        missing_parameters <- parameters[is.na(parameters)]
        if (length(missing_parameters) > 0) {
          shinyalert::shinyalert(
            title = paste0('Missing Parameter(s):\n', paste0(names(missing_parameters), collapse = '\n')),
            type = 'error',
            closeOnClickOutside = TRUE,
            timer = 3000
          )
          return()
        }
        
        tryCatch(
          {
            submit_record(
              input$record_work_material,
              input$record_tool_material,
              input$record_tool_type,
              input$record_tool_diameter,
              input$record_tool_flutes,
              input$record_cut_type,
              ifelse(record_tool_is_side_cutter(), input$record_tool_stepover, NA),
              ifelse(record_tool_is_side_cutter(), input$record_tool_stepdown, NA),
              input$record_tool_advance,
              input$record_spindle_speed,
              input$record_feed_rate,
              input$record_success,
              input$record_notes
            )
            shinyalert::shinyalert(
              title = 'Submission accepted',
              type = 'success',
              closeOnClickOutside = TRUE,
              timer = 3000
            )
            record_submitted(TRUE)
            record_submitted(FALSE)
          },
          error = function(cond) {
            shinyalert::shinyalert(
              title = 'Submission failed',
              type = 'error',
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
    
    return(
      list(record_submit = record_submitted)
    )
  })
}