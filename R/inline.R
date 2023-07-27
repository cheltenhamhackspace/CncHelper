
inline <- function(..., extra_style = '') {
  return(
    div(
      style = paste0('display: inline-block;', extra_style),
      ...
    )
  )
}