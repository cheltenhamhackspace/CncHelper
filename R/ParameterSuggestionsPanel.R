
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
