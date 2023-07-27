
filter_panel_ui <- function(id) {
  ns = NS(id)
  
  return(
    fluidPage(
      div(
        inline(checkboxInput(inputId = ns('filter_work_material'), label = "Workpiece Material", value = TRUE)),
        inline(checkboxInput(inputId = ns('filter_tool_material'), label = "Tool Material", value = TRUE)),
        inline(checkboxInput(inputId = ns('filter_tool_diameter'), label = "Tool Diameter", value = TRUE)),
        inline(checkboxInput(inputId = ns('filter_tool_type'), label = "Tool Type", value = TRUE)),
        inline(checkboxInput(inputId = ns('filter_tool_flutes'), label = "Tool Flute Count", value = TRUE)),
        inline(checkboxInput(inputId = ns('filter_cut_type'), label = "Cut Type", value = TRUE)),
        inline(checkboxInput(inputId = ns('filter_success'), label = "Successful", value = TRUE))
      )
    )
  )
}

filter_panel_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    return(
      list(
        filter_work_material = reactive({ input$filter_work_material }),
        filter_tool_material = reactive({ input$filter_tool_material }),
        filter_tool_type = reactive({ input$filter_tool_type }),
        filter_tool_diameter = reactive({ input$filter_tool_diameter }),
        filter_tool_flutes = reactive({ input$filter_tool_flutes }),
        filter_cut_type = reactive({ input$filter_cut_type }),
        filter_success = reactive({ input$filter_success })
      )
    )
  })
}
