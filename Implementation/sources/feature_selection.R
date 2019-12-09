select_features <- function(m_config, f_config, method, dataset, y, parallel) {
  if (parallel) {
    num_cores <- parallel::detectCores() - 1
    stopifnot(f_config$name == "tsfresh")
  } else {
    num_cores <- 1
  }
  if (f_config$name == "no") {
    result <- colnames(dataset)
  } else {
    start <- idxrepr::tic()
    result <- classrepr::mgr_select_features(method, dataset, y, f_config$k,
                                             num_cores)
    duration_fs <- idxrepr::toc(start)
    print(paste("Duration for Selection:", duration_fs))
  }
  
  return(result)
}