run_info <- function(run_name, d_config, ...) {
  dc <- util_get_filepath(d_config, "foo")
  ids <- unlist(lapply(list(...), function(x) x[[1]]))
  id_names <- unlist(lapply(list(...), function(x) names(x)[1]))
  print(paste("Run", run_name, "for", dc, paste(id_names, ids, sep = "_", collapse = ",")))
}

run_method <- function(d_configs, m_configs, force = T) {
  for (d_config in d_configs) {
    for (m_config in m_configs) {
      if (force || 
          !intermediate_exists(dataset_config, method_config, "method")) {
        run_info("method", d_config, m_config)
        method <- method_get(d_config, m_config)
        intermediate_save(d_config, method, "method", m_config)
      }
    }
  }
}

run_represent <- function(d_configs, m_configs, force = T, parallel = F) {
  fn <- function(name, I) {
    dataset <- util_read_dataset(d_config, "dataset", I)
    repr <- represent(dataset, method, parallel)
    intermediate_save(d_config, repr, paste0("represent-", name), m_config)
  }
  
  for (d_config in d_configs) {
    for (m_config in m_configs) {
      if (force || 
          !intermediate_exists(dataset_config, method_config, "method")) {
        method <- intermediate_read(d_config, "method", m_config)
        run_info("represent-data", d_config, m_config)
        fn("dataset", d_config$I - d_config$Q)
        fn("queryset", d_config$Q)
      }
    }
  }
}