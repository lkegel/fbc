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
          !intermediate_exists(d_config, m_config, "method")) {
        run_info("method", d_config, m_config)
        method <- method_get(d_config, m_config)
        intermediate_save(d_config, method, "method", m_config)
      }
    }
  }
}

run_represent <- function(d_configs, m_configs, force = T, parallel = F) {
  fn <- function(name, I) {
    dataset <- util_read_dataset(d_config, name, I)
    repr <- represent(dataset, method, parallel)
    intermediate_save(d_config, repr, paste0("represent-", name), m_config)
  }
  
  for (d_config in d_configs) {
    for (m_config in m_configs) {
      if (force || 
          !intermediate_exists(d_config, "represent-dataset", m_config)) {
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
        if (force ||  !intermediate_exists(d_config, "scaled-dataset", m_config,
                                           s_config)) {
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

run_feature_selection <- function(d_configs, m_configs, s_configs, f_configs,
                                  force = T, parallel = F) {

  all_configs <- list()
  idx <- 1
  
  for (d_config in d_configs) {
    for (m_config in m_configs) {
      for (s_config in s_configs) {
        for (f_config in f_configs) {
          if (force ||  !intermediate_exists(d_config,
                                             "feature-selection",
                                             m_config,
                                             s_config,
                                             f_config)) {
            all_configs[[idx]] <- list(D = d_config,
                                       M = m_config,
                                       S = s_config,
                                       F = f_config)
            idx <- idx + 1
          }
        }
      }
    }
  }
  
  run_fn <- function(all_config) {
    d_config <- all_config$D
    m_config <- all_config$M
    s_config <- all_config$S
    f_config <- all_config$F
    
    run_info("feature_selection", d_config, m_config, s_config, f_config)
    dataset <- intermediate_read(d_config, paste0("scaled-dataset"),
                                 m_config, s_config)
    fp <- util_get_filepath(d_config, "dataset", ext = "csv")
    y <- read.table(fp, header = T, sep = ";")[, "Code"]
    
    # Hack to avoid issues with not frequent Payment classes
    if (d_config$name == "Payment" && f_config$name == "fbr") {
      idx<- which(y %in% c(3, 4))
      dataset <- dataset[-idx, ]
      y <- y[-idx]
    }
    
    if (f_config$name == "no") {
      method <- NA
    } else {
      method <- intermediate_read(d_config, "method",
                                  list(mid = f_config$mid))
    }
    
    selected_features <- select_features(m_config, f_config, method,
                                         dataset, y, F)
    intermediate_save(d_config, selected_features, "feature-selection",
                      m_config, s_config, f_config)
    return(0)
  }
  
  if (parallel) {
    tf <- tmpfile()
    print(paste("Feature Selection Tempfile:", tf))
    num_cores <- parallel::detectCores() - 1
    cl <- parallel::makeCluster(num_cores, outfile = tf)
    parallel::clusterEvalQ(cl, setwd(file.path(Sys.getenv("FBC"))))
    parallel::clusterEvalQ(cl, source("Implementation/init.R"))
    
    parallel::parLapplyLB(cl, all_configs, run_fn)
    
    parallel::stopCluster(cl)
  } else {
    lapply(all_configs, run_fn)
  }
}

run_validate <- function(d_configs, m_configs, s_configs, f_configs, c_configs,
                         force = T, parallel = F) {
  for (d_config in d_configs) {
    for (m_config in m_configs) {
      for (s_config in s_configs) {
        for (f_config in f_configs) {
          for (c_config in c_configs) {
            if (force ||  !intermediate_exists(d_config,
                                               "validate",
                                               m_config,
                                               s_config,
                                               f_config,
                                               c_config)) {
              run_info("validate", d_config, m_config, s_config, f_config,
                       c_config)
              method <- intermediate_read(d_config, "method", m_config)
              dataset <- intermediate_read(d_config, paste0("scaled-dataset"),
                                           m_config, s_config)
              
              fp <- util_get_filepath(d_config, "dataset", ext = "csv")
              y <- read.table(fp, header = T, sep = ";")[, "Code"]
              selected_features <- intermediate_read(d_config,
                                                     "feature-selection",
                                                     m_config, s_config,
                                                     f_config)

              pred <- validate_run(d_config, c_config, method,
                                   dataset[, selected_features],
                                   y, parallel)
              
              intermediate_save(d_config, pred, "validate", m_config, s_config,
                                f_config, c_config)
              
            }
          }
        }
      }
    }
  }
}

run_best <- function(d_configs, m_configs, c_configs, s_configs, f_configs,
                     force = T, parallel = F) {
  for (d_config in d_configs) {
    mname <- list(mname = m_configs[[1]]$name)
    cname <- list(cname = c_configs[[1]]$name)
    dt <- NA
    
    fp <- util_get_filepath(d_config, "dataset", ext = "csv")
    y <- factor(read.table(fp, header = T, sep = ";")[, "Code"])
    
    for (m_config in m_configs) {
      for (c_config in c_configs) {
        for (s_config in s_configs) {
          for (f_config in f_configs) {
            pred <- intermediate_read(d_config, "validate", m_config, s_config,
                                      f_config, c_config)
            
            if (is.data.table(dt)) {
              dt <- rbindlist(list(dt, list(m_config[[1]], c_config[[1]],
                                            s_config[[1]], f_config[[1]],
                                            acc(y, pred))))
            } else {
              dt <- data.table(mid = m_config[[1]], cid = c_config[[1]],
                               sid = s_config[[1]], fid = f_config[[1]],
                               acc = acc(y, pred))
            }
          }
        }
      }
    }
    
    dt <- dt[order(acc, decreasing = T)]
    print(dt)
    
    intermediate_save(d_config, dt, "best", mname, cname)
  }
}

run_classify <- function(d_configs, m_configs, s_configs, f_configs, c_configs,
                                  force = T, parallel = F) {
  for (d_config in d_configs) {
    for (m_config in m_configs) {
      for (s_config in s_configs) {
        for (f_config in f_configs) {
          for (c_config in c_configs) {
            if (force ||  !intermediate_exists(d_config,
                                               "classify",
                                               m_config,
                                               s_config,
                                               f_config,
                                               c_config)) {
              run_info("classify", d_config, m_config, s_config, f_config,
                       c_config)
              method <- intermediate_read(d_config, "method", m_config)
              dataset <- intermediate_read(d_config, paste0("scaled-dataset"),
                                           m_config, s_config)
              queryset <- intermediate_read(d_config, paste0("scaled-queryset"),
                                           m_config, s_config)
            
              fp <- util_get_filepath(d_config, "dataset", ext = "csv")
              y <- read.table(fp, header = T, sep = ";")[, "Code"]
              selected_features <- intermediate_read(d_config,
                                                     "feature-selection",
                                                     m_config, s_config,
                                                     f_config)
              # Hack for rld
              selected_features_query <- intersect(selected_features,
                                                   colnames(queryset))
              pred <- classify_run(d_config, c_config, method,
                                   dataset[, selected_features],
                                   y, queryset[, selected_features_query],
                                   parallel)
              
              intermediate_save(d_config, pred, "classify", m_config, s_config,
                                f_config, c_config)
              
            }
          }
        }
      }
    }
  }
}