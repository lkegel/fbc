classify_run <- function(d_config, c_config, method, dataset, y, queryset,
                         parallel) {
  labels <- sort(unique(y))
  y_map <- seq(0, length(labels) - 1)
  names(y_map) <- as.character(labels)
  labels_mapped <- unname(y_map[as.character(y)])
  
  fit <- classify_estimate(d_config, c_config, dataset, labels_mapped, parallel)
  pred <- classify_use(d_config, c_config, method, dataset, labels_mapped, queryset, fit,
                       parallel)
  
  return(as.factor(labels[sapply(pred, function(pivot) {which(pivot == y_map)})]))
}

classify_estimate <- function(d_config, c_config, dataset, y, parallel, validate = F) {
  if (c_config$name %in% c("dt", "svm")) {
    data <- as.data.frame(dataset)
    data$y <- as.factor(y)
    form <- as.formula(paste("y ~", paste(setdiff(colnames(data), "y"), collapse = " + ")))
    if (c_config$name == "dt") {
      fit <- rpart(form, data = data, method = "class", control = rpart.control())  
    } else if (c_config$name == "svm") {
      fit <- svm(formula = form, data = data, type = 'C-classification', scale = F,
                 kernel = c_config$kernel, cross = 10)
    } else stop("NA")
  } else if (c_config$name == "gbm") {
    params <- list(eta = c_config$eta, # [0, 1, default 0.3]
                   max_depth = c_config$max_depth, # [0, Inf, default 6]
                   booster = c_config$booster) # [gbtree, gblinear]

    if (d_config$C > 2) {
      params <- c(params, objective = "multi:softmax")
      params <- c(params, num_class = d_config$C)
    } else {
      params <- c(params, objective = "binary:logistic")
    }

    data <- xgboost::xgb.DMatrix(dataset, label = y)
    cv <- xgb.cv(params = params, data = data, nrounds = c_config$nrounds,
                 nfold = c_config$nfold, verbose = T, prediction = validate,
                 early_stopping_rounds = c_config$early_stopping_rounds)
    
    if (validate) {
      fit <- cv
    } else {
      fit <- xgb.train(params = params, data = data, nrounds = cv$best_iteration)  
    }
  }
  # else if (c_config$name == "gbm_grid") {
  #   xgb_meta <- expand.grid(
  #     nrounds = 1000,
  #     eta = c(0.2, 0.3, 0.4),
  #     max_depth = c(2, 4, 6, 8, 10),
  #     gamma = 1,
  #     booster = c("gbtree", "gblinear")
  #   )
  #   
  #   xgb_param <- trainControl(
  #     method = "cv",
  #     number = 5,
  #     verboseIter = TRUE,
  #     returnData = FALSE,
  #     returnResamp = "all",
  #     classProbs = TRUE,
  #     summaryFunction = multiClassSummary,
  #     allowParallel = TRUE
  #   )
  #   
  #   xgb_train <- train(
  #     x =  dataset,
  #     y = y, #as.factor(y),
  #     trControl = xgb_param,
  #     tuneGrid = xgb_meta,
  #     method = "xgbTree"
  #   )
  # }
  else if (c_config$name == "knn") {
    fit <- NA
  }
  
  return(fit)
}

classify_use <- function(d_config, c_config, method, dataset, y, queryset, fit,
                         parallel) {
  if (c_config$name %in% c("dt", "svm")) {
    data <- as.data.frame(queryset)
    pred <- unname(predict(fit, data, type = "class"))
  } else if (c_config$name == "gbm") {
    data <- as.matrix(queryset)
    pred <- round(predict(fit, data))
    # pred <- as.factor(sort(names(table(y)))[])
    # pred <- matrix(pred, ncol=num_class, byrow=TRUE)
    # pred <- as.factor(max.col(pred))
  } else if (c_config$name == "knn") {
    pred <- my_knn(method, dataset, y, queryset, c_config$k, parallel)
  } else {
    stop("N/A")
  }
  
  return(pred)
}

my_knn <- function(method, dataset, y, queryset, k, parallel) {
  I <- nrow(dataset)
  Q <- nrow(queryset)
  
  stopifnot(k == 1)
  
  fn <- function(q, I, method, dataset, y, queryset, k) {
    print(q)
    query <- queryset[q, ]
    distances <- rep(NA, I)
    names(distances) <- as.character(seq(I))
    mindist <- Inf
    mindist_i <- 0
    for (i in seq(I)) {
      if (class(method) == "rld") {
        tempdist <- classrepr::mgr_distance(method, dataset[i, ], query) 
      } else {
        tempdist <- classrepr::mgr_distance(method, dataset[i, ], query, bsf = mindist)  
      }
      if (tempdist < mindist) {
        mindist <- tempdist
        mindist_i <- i
      }
    }
    pred <- y[mindist_i]
    
    return(pred)
    # if (k == 1) {
    #   pred <- votes
    # } else {
    #   freq <- table(votes)
    #   freq <- sort(freq, decreasing = T)
    #   if (freq[1] > freq[2]) {
    #     pred <- as.integer(names(freq[1]))
    #   } else {
    #     stop("todo: Break ties")
    #   }
    # }
  }
  
  if (parallel) {
    # Prepare
    num_cores <- min(32, parallel::detectCores() - 1)
    cl <- parallel::makeCluster(num_cores)
    parallel::clusterEvalQ(cl, library(classrepr))
    parallel::clusterExport(cl,c("I", "method", "dataset", "y", "queryset",
                                 "k"), environment())
    pred <- parallel::parSapply(cl, 1:Q, fn, I = I, method = method,
                                dataset = dataset, y = y, queryset = queryset,
                                k = k)
    parallel::stopCluster(cl)
  } else {
    pred <- sapply(1:Q, fn, I = I, method = method, dataset = dataset, y = y,
                   queryset = queryset, k = k)
  }
  
  return(pred)
}