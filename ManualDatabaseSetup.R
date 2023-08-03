secrets <- rjson::fromJSON(file = 'secrets.json')

con <- DBI::dbConnect(RPostgres::Postgres(),
                      dbname = secrets$database_name,
                      host = secrets$database_host,
                      port = secrets$database_port,
                      user = secrets$database_user,
                      password = secrets$database_password)

# fields = c(
#   work_material = 'string',
#   tool_material = 'string',
#   tool_type = 'string',
#   tool_diameter = 'numeric',
#   tool_flutes = 'integer',
#   cut_type = 'string',
#   tool_stepover = 'numeric',
#   tool_stepdown = 'numeric',
#   tool_advance = 'numeric',
#   spindle_speed = 'numeric',
#   axis_feed = 'numeric',
#   success = 'boolean',
#   notes = 'string'
# )

# DBI::dbRemoveTable(con, 'mill_records')
# DBI::dbRemoveTable(con, 'to_delete')
# DBI::dbCreateTable(con, 'mill_records', fields, 'PRIMARY KEY("id")')
# DBI::dbCreateTable(con, 'to_delete', fields)


# record_df <- data.frame(
#   work_material = "work_material",
#   tool_material = "tool_material",
#   tool_type = "tool_type",
#   tool_diameter = 19.3,
#   tool_flutes = 4,
#   cut_type = "cut_type",
#   tool_stepover = 17.2,
#   tool_stepdown = 11.1,
#   tool_advance = 1.1,
#   spindle_speed = 144.12,
#   axis_feed = 2.34,
#   success = TRUE,
#   notes = "notes"
# )
# 
# DBI::dbAppendTable(con, 'to_delete', record_df)

# result <- DBI::dbSendQuery(con, "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_CATALOG='machining'")
# DBI::dbFetch(result)
# DBI::dbClearResult(result)

result <- DBI::dbSendQuery(con, "SELECT column_name, data_type FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_CATALOG='machining' AND TABLE_NAME='mill_records'")
DBI::dbFetch(result)
DBI::dbClearResult(result)

# result <- DBI::dbSendQuery(con, "DELETE FROM mill_records WHERE rowid > 20")
# DBI::dbClearResult(result)

result <- DBI::dbSendQuery(con, "SELECT *, rowid FROM mill_records")
DBI::dbFetch(result)
DBI::dbClearResult(result)

DBI::dbDisconnect(con)
