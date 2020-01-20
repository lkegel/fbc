represent <- function(dataset, method, parallel) {
  if (parallel) {
    num_cores <- parallel::detectCores() - 1
    
    if (mgr_is_vectorized(method)) {
      dec <- classrepr::mgr_dec(method, dataset, num_cores)
      return(classrepr::mgr_red(method, dec, num_cores))
    } else {
      cl <- parallel::makeCluster(num_cores)
      parallel::clusterEvalQ(cl, library(classrepr))
      parallel::clusterExport(cl, "dataset", environment())
      parallel::clusterExport(cl, "method", environment())
      repr <- parallel::parApply(cl, dataset, 1, function(x) {
        dec <- classrepr::mgr_dec(method, x)
        return(classrepr::mgr_red(method, dec))
      })
      parallel::stopCluster(cl)
      repr <- t(repr)
    }
  } else {
    # Decomposition
    start <- tictoc::tic()
    if (mgr_is_vectorized(method)) {
      dsl <- classrepr::mgr_dec(method, dataset)
    } else {
      dsl <- lapply(as.list(seq(nrow(dataset))), function(i) {
        classrepr::mgr_dec(method, dataset[i, ])
      })
    }
    duration_dec <- tictoc::toc(start)
    
    # Reduction
    
    if (mgr_is_vectorized(method)) {
      start <- tictoc::tic()
      repr <- classrepr::mgr_red(method, dsl)
      duration_red <- tictoc::toc(start)
    } else if (class(method) == "rld") {
      print(microbenchmark::microbenchmark(classrepr::mgr_red(method, dsl[[1]])))
      start <- tictoc::tic()
      fs <- classrepr::mgr_red(method, dsl[[1]])
      repr <- matrix(NA, nrow = nrow(dataset), ncol = length(fs))
      colnames(repr) <- names(fs)
      repr[1, ] <- fs 
      for (i in seq_along(dsl)[-1]) {
        row <- classrepr::mgr_red(method, dsl[[i]])
        while (ncol(repr) < length(row)) {
          repr <- cbind(repr, NA_real_)
          colnames(repr)[ncol(repr)] <- paste0("V", ncol(repr))
        }
        repr[i, ] <- c(row, rep(NA, ncol(repr) - length(row)))
      }
      duration_red <- tictoc::toc(start)
    } else {
      
      start <- tictoc::tic()
      repr <- t(sapply(dsl, classrepr::mgr_red, method = method))
      duration_red <- tictoc::toc(start)
    }
    
    print(paste("Duration for Decomposition:", duration_dec))
    print(paste("Duration for Reduction:", duration_red))
  }

  return(repr)
}