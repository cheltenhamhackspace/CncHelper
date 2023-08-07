library(dplyr)

max_rpm = 4000

tools = data.frame(
  name = c(),
  side_cutter = c(),
  speed_multiplier = c()
)

tools <- tools %>%
  rbind(data.frame(name = 'End Mill', side_cutter = TRUE, speed_multiplier = 1)) %>%
  rbind(data.frame(name = 'Drill', side_cutter = FALSE, speed_multiplier = 1)) %>%
  rbind(data.frame(name = 'Reamer', side_cutter = FALSE, speed_multiplier = 0.5))

surface_speeds = data.frame(
  work_material = c(),
  tool_material = c(),
  surface_speed = c()
)

surface_speeds <- surface_speeds %>%
  rbind(data.frame(work_material = 'Aluminium', tool_material = 'HSS', surface_speed = 76000)) %>%
  rbind(data.frame(work_material = 'Plastic', tool_material = 'HSS', surface_speed = 60000)) %>%
  rbind(data.frame(work_material = 'Brass', tool_material = 'HSS', surface_speed = 60000)) %>%
  rbind(data.frame(work_material = 'Copper', tool_material = 'HSS', surface_speed = 36500)) %>%
  rbind(data.frame(work_material = 'Bronze', tool_material = 'HSS', surface_speed = 30500)) %>%
  rbind(data.frame(work_material = 'Steel', tool_material = 'HSS', surface_speed = 24500)) %>%
  rbind(data.frame(work_material = 'Cast Iron', tool_material = 'HSS', surface_speed = 15000)) %>%
  rbind(data.frame(work_material = 'Stainless Steel', tool_material = 'HSS', surface_speed = 12000)) %>%
  
  rbind(data.frame(work_material = 'Aluminium', tool_material = 'Carbide', surface_speed = 152000)) %>%
  rbind(data.frame(work_material = 'Plastic', tool_material = 'Carbide', surface_speed = 180000)) %>%
  rbind(data.frame(work_material = 'Brass', tool_material = 'Carbide', surface_speed = 150000)) %>%
  rbind(data.frame(work_material = 'Copper', tool_material = 'Carbide', surface_speed = 73000)) %>%
  rbind(data.frame(work_material = 'Bronze', tool_material = 'Carbide', surface_speed = 61000)) %>%
  rbind(data.frame(work_material = 'Steel', tool_material = 'Carbide', surface_speed = 80000)) %>%
  rbind(data.frame(work_material = 'Cast Iron', tool_material = 'Carbide', surface_speed = 60000)) %>%
  rbind(data.frame(work_material = 'Stainless Steel', tool_material = 'Carbide', surface_speed = 50000))

get_max_rpm <- function() {
  return(max_rpm)
}

get_work_materials <- function() {
  return(sort(unique(surface_speeds$work_material)))
}

get_tool_types <- function() {
  return(sort(tools$name))
}

get_tool_materials <- function() {
  return(unique(surface_speeds$tool_material))
}

tool_cuts_laterally <- function(tool_type) {
  return(tools$side_cutter[tools$name == tool_type])
}

is_side_cut <- function(cut_type) {
  return(cut_type != 'Plunge')
}

get_cut_types <- function() {
  return(c('Plunge', 'Side Mill'))
}

get_surface_speed <- function(work_material, tool_material, tool_type) {
  row <- surface_speeds$surface_speed[surface_speeds$work_material == work_material & surface_speeds$tool_material == tool_material]
  tool_speed_multipler <- tools$speed_multiplier[tools$name == tool_type]
  
  return(row * tool_speed_multipler)
}

calculate_spindle_speed <- function(work_material, tool_material, tool_diameter, tool_type) {
  if (is.na(tool_diameter)) {
    return(NA)
  }
  
  return(get_surface_speed(work_material, tool_material, tool_type) / (pi * tool_diameter))
}

calculate_axis_feed <- function(spindle_speed, tool_flute_count, advance_per_flute) {
  return(spindle_speed * tool_flute_count * advance_per_flute)
}

calculate_axis_feed_with_chip_thinning <- function(axis_feed, tool_diameter, cut_type, tool_stepover) {
  if (is.na(tool_stepover)) {
    return(NA)
  }
  
  if (!is_side_cut(cut_type) || tool_stepover >= tool_diameter / 2) {
    return(axis_feed)
  }
  
  chip_thinning_factor <- 1 / sqrt(1 - (1 - (2 * tool_stepover / tool_diameter)) ^ 2)
  return(axis_feed * chip_thinning_factor)
}