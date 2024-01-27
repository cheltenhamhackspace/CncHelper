parameter_input_panel_ui <- function(id) {
  ns = NS(id)
  
  return(
    div(
      h3('Select Workpiece Parameters'),
      selectizeInput(
        inputId = ns('select_work_material'),
        label = 'Workpiece Material',
        choices = get_work_materials()
      ),
      h3('Select Tool Parameters'),
      selectizeInput(
        inputId = ns('select_tool_material'),
        label = 'Tool Material',
        choices = get_tool_materials()
      ),
      selectizeInput(
        inputId = ns('select_tool_type'),
        label = 'Tool Type',
        choices = get_tool_types()
      ),
      numericInput(
        inputId = ns('select_tool_diameter'),
        label = 'Tool Diameter',
        value = 6,
        min = 0,
        max = 100,
        step = 1
      ),
      numericInput(
        inputId = ns('select_tool_flutes'),
        label = 'Tool Flute Count',
        value = 2,
        min = 1,
        max = 10,
        step = 1
      ),
      h3('Select Cutting Parameters'),
      conditionalPanel(
        condition = 'output.select_tool_is_side_cutter',
        ns = ns,
        selectizeInput(
          inputId = ns('select_cut_type'),
          label = 'Cut Type',
          choices = get_cut_types()
        )
      ),
      conditionalPanel(
        condition = 'output.select_cut_is_sideways',
        ns = ns,
        numericInput(
          inputId = ns('select_tool_stepover'),
          label = 'Tool Stepover',
          value = 2,
          min = 0,
          max = 100,
          step = 0.5
        )
      ),
      numericInput(
        inputId = ns('select_tool_advance'),
        label = 'Tool Advance Distance per Flute',
        value = 0.01,
        min = 0,
        max = 1,
        step = 0.005
      )
    )
  )
}

parameter_input_panel_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    select_tool_is_side_cutter <- reactive({
      return(tool_cuts_laterally(input$select_tool_type))
    })
    
    select_cut_is_sideways <- reactive({
      return(is_side_cut(input$select_cut_type))
    })
    
    output$select_tool_is_side_cutter <- select_tool_is_side_cutter
    outputOptions(output, 'select_tool_is_side_cutter', suspendWhenHidden = FALSE)
    
    output$select_cut_is_sideways <- select_cut_is_sideways
    outputOptions(output, 'select_cut_is_sideways', suspendWhenHidden = FALSE)
    
    observe({
      if (!select_tool_is_side_cutter()) {
        updateSelectizeInput(inputId = 'select_cut_type', selected = 'Plunge')
      }
    })
    
    return(
      list(
        select_work_material = reactive({ input$select_work_material }),
        select_tool_material = reactive({ input$select_tool_material }),
        select_tool_type = reactive({ input$select_tool_type }),
        select_tool_diameter = reactive({ input$select_tool_diameter }),
        select_tool_flutes = reactive({ input$select_tool_flutes }),
        select_cut_type = reactive({ input$select_cut_type }),
        select_tool_stepover = reactive({ input$select_tool_stepover }),
        select_tool_advance = reactive({ input$select_tool_advance }),
        select_cut_is_sideways = select_cut_is_sideways
      )
    )
  })
}