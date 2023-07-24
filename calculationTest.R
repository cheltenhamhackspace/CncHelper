surface_speeds = data.frame(
  work_material = c('Plastic', 'Plastic', 'Aluminium', 'Aluminium', 'Steel', 'Steel', 'Stainless Steel', 'Stainless Steel'),
  tool_material = c('HSS', 'Carbide', 'HSS', 'Carbide', 'HSS', 'Carbide', 'HSS', 'Carbide'),
  surface_speed = c(60000, 0, 76000, 0, 24500, 0, 12250, 0)
)


library(dplyr)
surface_speeds %>%
dplyr::filter(work_material == 'Aluminium') %>%
dplyr::filter(tool_material == 'HSS')