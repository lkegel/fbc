method_get <- function(d_config, m_config) {
  method <- classrepr::mgr_init(m_config$name)
  
  if(class(method) == "fbr") {
    method$w_strength <- as.logical(m_config$w_strength)
    method$w_mask <- as.logical(m_config$w_mask)
    
    method$frequency <- d_config$frequency
    
    ti <- util_read(d_config, "timestamps")
    
    ymd <- strftime(ti, "%Y-%m-%d", tz = "UTC")
    method$ymdf <- as.factor(ymd)
    method$ymdc <- unname(table(ymd))
    
    ym <- strftime(ti, "%Y-%m", tz = "UTC")
    method$ymf <- as.factor(ym)
    method$ymc <- unname(table(ym))
    
    rm(ti)
    
    if (d_config$max >= d_config$frequency * 365 * 2) {
      method$w_year <- T
    } else {
      method$w_year <- F
    }
  } else if (class(method) == "rld") {
    # pass
  } else if (class(method) == "dwt") {
    # pass
  } else if (class(method) == "tsfresh") {
    method$ti <- util_read(d_config, "timestamps")
  } else {
    stop("N/A")
  }
  
  return(method)
}