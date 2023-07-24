
create_suggestions_panel <- function(suggestions) {
  if (nrow(suggestions) == 0) {
    return()
  }
  
  div(
    style = "overflow-y: scroll; height:70vh;",
    lapply(
      seq(1, nrow(suggestions)),
      function(row) {
        create_suggestion_item(suggestions[row,])
      }
    )
  )
}

create_suggestion_item <- function(row) {
  style = 'word-wrap: break-word; border: 2px solid gray; border-radius: 5px; margin: 2px; padding: 0px 5px 0px 5px;'
  if (row$success) {
    style <- paste0(style, ' background: #eeffee;')
  } else {
    style <- paste0(style, ' background: #ffeeee;')
  }
  
  line_1 <- paste0(row$tool_flutes, '-flute ', row$tool_diameter, 'mm ', row$tool_material, ' ', row$tool_type)
  line_2 <- paste0(row$cut_type, ' cutting ', row$work_material, ' at ', row$spindle_speed, 'RPM and ', row$axis_feed, 'mm per min')
  line_3 <- paste0(
    'With ',
    ifelse(is.na(row$tool_stepover), '', paste0(row$tool_stepover, 'mm stepover and ')),
    ifelse(is.na(row$tool_stepdown), '', paste0(row$tool_stepdown, 'mm stepdown and ')),
    row$tool_advance, 'mm advance per flute'
  )
  line_4 <- paste0(ifelse(stringr::str_length(row$notes) == 0, '', '\nNotes:\n'), row$notes)
  
  return(
    div(
      style = style,
      line_1,
      br(),
      line_2,
      br(),
      line_3,
      br(),
      strong(line_4)
    )
  )
}
