feeds_and_speeds_panel_ui <- function(id) {
  ns = NS(id)
  
  return(
    div(
      h2('Suggested Feeds and Speeds'),
      div(
        inline(h4('Spindle Speed:')),
        inline(textOutput(outputId = ns('spindle_speed_text'), inline = TRUE))
      ),
      div(
        inline(h4('Axis Feed Rate:')),
        inline(textOutput(outputId = ns('axis_feed_text'), inline = TRUE))
      ),
      conditionalPanel(
        condition = 'output.select_cut_is_sideways',
        ns = ns,
        div(
          inline(h4('Axis Feed Rate (Including Chip-Thinning):')),
          inline(textOutput(outputId = ns('axis_feed_ct_text'), inline = TRUE))
        )
      )
    )
  )
}

format_decimal <- function(decimal) {
  return(signif(decimal, digits = 3))
}


feeds_and_speeds_panel_server <- function(id,
                                          select_work_material,
                                          select_tool_material,
                                          select_tool_type,
                                          select_tool_diameter,
                                          select_tool_flutes,
                                          select_cut_type,
                                          select_tool_stepover,
                                          select_tool_advance,
                                          select_cut_is_sideways) {
  moduleServer(id, function(input, output, session) {
    
    output$select_cut_is_sideways <- select_cut_is_sideways
    outputOptions(output, 'select_cut_is_sideways', suspendWhenHidden = FALSE)

    # Calculate feeds and speeds
    calculated_rpm <- reactive({
      return(
        calculate_spindle_speed(
          select_work_material(),
          select_tool_material(),
          select_tool_diameter(),
          select_tool_type()
        )
      )
    })
    
    calculated_feed <- reactive({
      return(calculate_axis_feed(calculated_rpm(), select_tool_flutes(), select_tool_advance()))
    })
    
    calculated_limited_feed <- reactive({
      return(calculate_axis_feed(min(calculated_rpm(), get_max_rpm()), select_tool_flutes(), select_tool_advance()))
    })

    output$spindle_speed_text <- renderText({
      if (calculated_rpm() <= get_max_rpm()) {
        return(paste0(format_decimal(calculated_rpm()), "RPM"))
      }
        
      return(paste0(format_decimal(get_max_rpm()), "RPM (Spindle Limited from ", format_decimal(calculated_rpm()), "RPM)"))
    })

    output$axis_feed_text <- renderText({
      if (calculated_feed() == calculated_limited_feed()) {
        return(paste0(format_decimal(calculated_feed()), "mm per minute"))
      }
      
      return(paste0(format_decimal(calculated_limited_feed()), "mm per minute (Spindle Limited from ", format_decimal(calculated_feed()), "mm per minute)"))
    })
    
    output$axis_feed_ct_text <- renderText({
      chip_thinned_feed <- calculate_axis_feed_with_chip_thinning(
        calculated_feed(),
        select_tool_diameter(),
        select_cut_type(),
        select_tool_stepover()
      )
      limited_chip_thinned_feed <- calculate_axis_feed_with_chip_thinning(
        calculated_limited_feed(),
        select_tool_diameter(),
        select_cut_type(),
        select_tool_stepover()
      )
      
      if (chip_thinned_feed == limited_chip_thinned_feed) {
        return(paste0(format_decimal(chip_thinned_feed), "mm per minute"))
      }
      
      return(paste0(format_decimal(limited_chip_thinned_feed), "mm per minute (Spindle Limited from ", format_decimal(chip_thinned_feed), "mm per minute)"))
    })
  })
}