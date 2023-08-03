
suggestions_panel_ui <- function(id, suggestions) {
  ns = NS(id)
  
  if (nrow(suggestions) == 0) {
    return()
  }
  
  div(
    style = "overflow-y: scroll; height:70vh;",
    lapply(
      1:nrow(suggestions),
      function(row) {
        suggestion_item_ui(ns(row), suggestions[row,])
      }
    )
  )
}

suggestion_item_ui <- function(id, row) {
  ns = NS(id)
  
  style = 'word-wrap: break-word; border: 2px solid gray; border-radius: 5px; margin: 2px; padding: 0px 5px 0px 5px; overflow: hidden;'
  if (row$success) {
    style <- paste0(style, ' background: #eeffee;')
  } else {
    style <- paste0(style, ' background: #ffeeee;')
  }
  
  record_is_side_cut = !is.na(row$tool_stepover)
  record_has_advance = !is.na(row$tool_advance)
  
  line_1 <- paste0(row$tool_flutes, '-flute ', row$tool_diameter, 'mm ', row$tool_material, ' ', row$tool_type)
  line_2 <- paste0(row$cut_type, ' cutting ', row$work_material, ' at ', row$spindle_speed, 'RPM and ', row$axis_feed, 'mm per min')
  line_3 <- paste0(
    'With ',
    ifelse(is.na(row$tool_stepover), '', paste0(row$tool_stepover, 'mm stepover and ')),
    ifelse(is.na(row$tool_stepdown), '', paste0(row$tool_stepdown, 'mm stepdown')),
    ifelse(record_is_side_cut & record_has_advance, ' and ', ''),
    ifelse(is.na(row$tool_advance), '', paste0(row$tool_advance, 'mm advance per flute')),
    '.'
  )
  line_4 <- paste0(ifelse(stringr::str_length(row$notes) == 0, '', '\nNotes:\n'), row$notes)
  
  return(
    div(
      style = style,
      inline(
        line_1,
        br(),
        line_2,
        br(),
        line_3,
        br(),
        strong(line_4)
      ),
      div(
        id = ns("delete"),
        style = "float: right; cursor: pointer;",
        HTML("&#128473;")
      )
    )
  )
}

suggestions_panel_server <- function(id, suggestions, records_changed) {
  moduleServer(id, function(input, output, session) {
    lapply(
      1:nrow(suggestions),
      function(row) {
        suggestion_item_server(row, suggestions$rowid[row], records_changed)
      }
    )
  })
}

suggestion_item_server <- function(id, db_id, records_changed) {
  moduleServer(id, function(input, output, session) {
    observe({
      shinyjs::onclick(
        id = "delete",
        {
          confirm <- shinyalert::shinyalert(
            title = 'Are you sure you want to delete this record?',
            type = 'warning',
            showCancelButton = TRUE,
            callbackR = function(confirm) {
              if (!confirm) {
                return()
              }
              
              shinyalert::shinyalert(
                title = 'Deleted Record',
                type = 'success',
                closeOnClickOutside = TRUE,
                timer = 3000
              )
              delete_record(db_id)
              records_changed(TRUE)
              records_changed(FALSE)
            }
          )
        }
      )
    })
  })
}
