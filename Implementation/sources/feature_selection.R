select_features <- function(f_config, dataset, meta) {
  
  
  # Correlation-based Feature Selection
  corr_matrix <- cor(dataset)
  high_corr <- caret::findCorrelation(corr_matrix, cutoff=0.75)
  dataset <- dataset[, -high_corr]
  
  # Random Forest
  sizes <- seq(min(ncol(dataset), f_config$k))
  control <- caret::rfeControl(functions = caret::rfFuncs, method = "cv", number = 10)
  results <- caret::rfe(dataset, meta$Code, sizes = sizes, rfeControl=control)
  return(predictors(results))
  # plot(results, type=c("g", "o"))  
}