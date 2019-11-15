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

run_scale <- function(d_configs, m_configs, s_configs, force = T) {
  for (d_config in d_configs) {
    for (m_config in m_configs) {
      for (s_config in s_configs) {
        if (force ||  !intermediate_exists(dataset_config, method_config,
                                           "scale", s_config)) {
          repr_data <- intermediate_read(d_config, paste0("represent-dataset"),
                                         m_config)
          repr_query <- intermediate_read(d_config,
                                          paste0("represent-queryset"),
                                          m_config)
          run_info("scale", d_config, m_config, s_config)
          scaled <- scale_run(repr_data, repr_query, s_config)
          scaled_data <- scaled[[1]]
          scaled_query <- scaled[[2]]
          intermediate_save(d_config, scaled_data, "scaled-dataset", m_config,
                            s_config)
          intermediate_save(d_config, scaled_query, "scaled-queryset", m_config,
                            s_config)
        }
      }
    }
  }
}

run_feature_selection <- function(d_configs, m_configs, s_configs, f_configs, force = T) {
  for (d_config in d_configs) {
    for (m_config in m_configs) {
      for (s_config in s_configs) {
        for (f_config in f_configs) {
          if (force ||  !intermediate_exists(d_config,
                                             "feature-selection",
                                             m_config,
                                             s_config,
                                             f_config)) {
            run_info("feature_selection", d_config, m_config, s_config, f_config)
            if (s_config$name == "scaleno") {
              dataset <- intermediate_read(d_config, paste0("represent-dataset"),
                                              m_config)  
            } else {
              dataset <- intermediate_read(d_config, paste0("scaled-dataset"),
                                              m_config, s_config)
            }
            
            fp <- util_get_filepath(d_config, "dataset", ext = "csv")
            meta <- read.table(fp, header = T, sep = ";")
            selected_features <- select_features(f_config, dataset, meta)
            
            intermediate_save(d_config, selected_features, "feature-selection",
                              m_config, s_config, f_config)
          }
        }
      }
    }
  }
}