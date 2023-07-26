secrets <- rjson::fromJSON(file = 'secrets.json')

with_database <- function(action) {
  con <- DBI::dbConnect(RPostgres::Postgres(),
                        dbname = secrets$database_name,
                        host = secrets$database_host,
                        port = secrets$database_port,
                        user = secrets$database_user,
                        password = secrets$database_password)
  on.exit({
    DBI::dbDisconnect(con)
  })
  
  return(action(con))
}

append_query_filter <- function(existing_filter, field_name, field_value) {
  if (is.null(field_value) || is.na(field_value)) {
    return(existing_filter)
  }
  
  filter <- existing_filter
  if (stringr::str_length(filter) == 0) {
    filter <- paste0(filter, paste0(' WHERE '))
  } else {
    filter <- paste0(filter, paste0(' AND '))
  }
  
  if (is.character(field_value)) {
    return(paste0(filter, paste0(field_name, '=', DBI::dbQuoteString(DBI::ANSI(), field_value))))
  } else {
    return(paste0(filter, paste0(field_name, '=', field_value)))
  }
}

get_records <- function(work_material = NULL, tool_material = NULL,
                        tool_type = NULL, tool_diameter = NULL,
                        tool_flutes = NULL, cut_type = NULL, success = TRUE) {
  filter <- ''
  filter <- append_query_filter(filter, 'work_material', work_material)
  filter <- append_query_filter(filter, 'tool_material', tool_material)
  filter <- append_query_filter(filter, 'tool_type', tool_type)
  filter <- append_query_filter(filter, 'tool_diameter', tool_diameter)
  filter <- append_query_filter(filter, 'tool_flutes', tool_flutes)
  filter <- append_query_filter(filter, 'cut_type', cut_type)
  if (success) {
    filter <- append_query_filter(filter, 'success', success)
  }
  
  query <- paste0('SELECT * FROM mill_records', filter)
  
  return(
    with_database(function(con) {
      result <- DBI::dbSendQuery(con, query)
      df <- DBI::dbFetch(result)
      DBI::dbClearResult(result)
      return(df)
    })
  )
}

submit_record <- function(work_material, tool_material, tool_type, tool_diameter,
                         tool_flutes, cut_type, tool_stepover, tool_stepdown, tool_advance,
                         spindle_speed, axis_feed, success, notes) {
  df <- data.frame(
    work_material = DBI::dbQuoteString(DBI::ANSI(), work_material),
    tool_material = DBI::dbQuoteString(DBI::ANSI(), tool_material),
    tool_type = DBI::dbQuoteString(DBI::ANSI(), tool_type),
    tool_diameter = tool_diameter,
    tool_flutes = tool_flutes,
    cut_type = DBI::dbQuoteString(DBI::ANSI(), cut_type),
    tool_stepover = tool_stepover,
    tool_stepdown = tool_stepdown,
    tool_advance = tool_advance,
    spindle_speed = spindle_speed,
    axis_feed = axis_feed,
    success = success,
    notes = DBI::dbQuoteString(DBI::ANSI(), notes)
  )
  
  with_database(function(db_connection) {
    DBI::dbAppendTable(db_connection, 'mill_records', df)
  })
}