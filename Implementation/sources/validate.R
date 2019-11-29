validate_run <- function(d_config, c_config, method, dataset, y, parallel) {
  labels <- sort(unique(y))
  y_map <- seq(0, length(labels) - 1)
  names(y_map) <- as.character(labels)
  labels_mapped <- unname(y_map[as.character(y)])
  
  fit <- classify_estimate(d_config, c_config, dataset, labels_mapped, parallel, validate = T)
  pred <- validate_use(d_config, c_config, method, dataset, labels_mapped, fit,
                       parallel)
  
  return(as.factor(labels[sapply(pred, function(pivot) {which(pivot == y_map)})]))
}

validate_use <- function(d_config, c_config, method, dataset, y, fit,
                         parallel) {
  if (c_config$name %in% c("dt", "svm")) {
    data <- as.data.frame(dataset)
    pred <- unname(predict(fit, data, type = "class"))
  } else if (c_config$name == "gbm") {
    if (fit$params$objective == "binary:logistic") {
      pred <- round(fit$pred)
    } else {
      pred <- fit$pred[, 1]  
    }
    # pred <- as.factor(sort(names(table(y)))[])
    # pred <- matrix(pred, ncol=num_class, byrow=TRUE)
    # pred <- as.factor(max.col(pred))
  } else if (c_config$name == "knn") {
    fold <- 10
    folds <- split_fold(y, fold)
    pred <- rep(NA, length(y))
    for (this_fold in folds) {
      pred[this_fold] <- my_knn(method, dataset[-this_fold, ], y[-this_fold], dataset[this_fold, ], c_config$k, parallel)
    }
  } else {
    stop("N/A")
  }
  
  return(pred)
}

split_fold <- function(y, fold) {
  labels <- sort(unique(y))
  idx_label <- vector("list", length(labels))
  for (i_label in seq(length(labels))) {
    label <- labels[i_label]
    idx <- which(y == label)
    f <- factor(round(seq(0.6, fold + 0.4, length.out = length(idx))), levels = seq(fold))
    idx_label[[i_label]] <- split(idx, f)
  }
  idx <- vector("list", fold)
  for (i_fold in seq(fold)) {
    result <- c()
    for (i_label in seq(length(labels))) {
      result <- c(result, idx_label[[i_label]][[i_fold]])
    }
    if (length(result) == 0) stop("split_fold could not provide non-void set")
    idx[[i_fold]] <- result
  }
  
  return(idx)
}

