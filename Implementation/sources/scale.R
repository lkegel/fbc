scale_run <- function(repr_data, repr_query, s_config) {
  if (s_config$name == "donothing") {
    result_data <- repr_data
    result_query <- repr_query
  } else {
    # impute
    imputer <- new("Impute")
    impute_data <- as.data.frame(lapply(as.data.frame(repr_data), function(col) {
      return(imputer$scale(col))
    }))
    impute_query <- as.data.frame(repr_query)
    for (j in seq(ncol(impute_data))) {
      impute_query[, j] <- imputer$copyAttributes(impute_query[, j], 
                                                  impute_data[, j])
      impute_query[, j] <- imputer$scale(impute_query[, j])
    }
    result_data <- impute_data <- as.matrix(impute_data)
    result_query <- impute_query <- as.matrix(impute_query)
    
    if (s_config$name != "No Scaling") {
      scaler_map <- c(`01 Scaling` = "Norm01", `01 Scaling with Outlier` = "Norm01_Outlier", `Z Scaling` = "ZNorm")
      scaler <- new(scaler_map[s_config$name])
      scale_data <- as.data.frame(lapply(as.data.frame(impute_data), function(col) {
        return(scaler$scale(col))
      }))
      scale_query <- as.data.frame(impute_query)
      for (j in seq(ncol(repr_data))) {
        scale_query[, j] <- scaler$copyAttributes(scale_query[, j], 
                                                  scale_data[, j])
        scale_query[, j] <- scaler$scale(scale_query[, j])
      }
      result_data <- as.matrix(scale_data)
      result_query <- as.matrix(scale_query)
    } 
  }
  return(list(result_data, result_query)) 
}
