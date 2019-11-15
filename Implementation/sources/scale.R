scale_run <- function(repr_data, repr_query, s_config) {
  if (s_config$name == "scaleno") {
    return(as.list(c(NA, NA)))
  } else {
    scaler <- new(s_config$name)
    scale_data <- as.data.frame(lapply(as.data.frame(repr_data), function(col) {
      return(scaler$scale(col))
    }))
    scale_query <- as.data.frame(repr_query)
    for (j in seq(ncol(repr_data))) {
      scale_query[, j] <- scaler$copyAttributes(scale_query[, j], 
                                                scale_data[, j])
      scale_query[, j] <- scaler$scale(scale_query[, j])
    }
    return(list(as.matrix(scale_data), as.matrix(scale_query))) 
  }
}
