suppressPackageStartupMessages(library(ggplot2))
suppressPackageStartupMessages(library(ggrepel))
suppressPackageStartupMessages(library(directlabels))
suppressPackageStartupMessages(library(latticeExtra))
suppressPackageStartupMessages(library(grDevices))
suppressPackageStartupMessages(library(extrafont))
suppressPackageStartupMessages(library(Rttf2pt1))

eval_feature_selection <- function(d_configs, m_configs, s_configs, f_configs) {
  for (d_config in d_configs) {
    for (m_config in m_configs) {
      for (s_config in s_configs) {
        for (f_config in f_configs) {
          run_info("eval_feature_selection", d_config, m_config, s_config,
                   f_config)
          features <- intermediate_read(d_config, "feature-selection", m_config,
                                    s_config, f_config)
          print(head(features, 20))
          print(paste("Length:", length(features)))
        }
      }
    }
  }
}

eval_validate <- function(d_configs, m_configs, s_configs, f_configs, c_configs) {
  for (d_config in d_configs) {
    for (m_config in m_configs) {
      for (s_config in s_configs) {
        for (f_config in f_configs) {
          for (c_config in c_configs) {
            run_info("eval_validate", d_config, m_config, s_config, f_config,
                     c_config)
            fp <- util_get_filepath(d_config, "dataset", ext = "csv")
            y <- as.factor(read.table(fp, header = T, sep = ";")[, "Code"])
            pred <- intermediate_read(d_config, "validate", m_config, s_config,
                                      f_config, c_config)
            print(acc(y, pred))
          }
        }
      }
    }
  }
}

eval_accuracy <- function(d_configs, m_configs, s_configs, f_configs, c_configs) {
  for (d_config in d_configs) {
    for (m_config in m_configs) {
      for (s_config in s_configs) {
        for (f_config in f_configs) {
          for (c_config in c_configs) {
            run_info("eval_classify", d_config, m_config, s_config, f_config,
                     c_config)
            print(accuracy(d_config, m_config, s_config, f_config, c_config))
          }
        }
      }
    }
  }
}

eval_scale_heatmap <- function(d_config, m_config, s_config) {
  d_config <- d[[1]]
  m_config <- m$`14`
  s_config <- s$`2`
  ygroup_map <- c(sd = "stochastic",
                  skew = "stochastic",
                  kurt = "stochastic",
                  acf1 = "stochastic",
                  theta = "trend",
                  season_1 = "season 1",
                  season_2 = "season 2",
                  season_3 = "season 3")
  
  ygroup_fn <- function(feature) {
    unname(ygroup_map[which(sapply(names(ygroup_map), function(x, y) { return(length(grep(x, y)) > 0) }, y = feature, USE.NAMES = F))])
  }
  ygroup_fn_v <- Vectorize(ygroup_fn, USE.NAMES = F)

  fp <- util_get_filepath(d_config, "dataset", ext = "csv")
  y <- read.table(fp, header = T, sep = ";")[, "Code"]  

  idx <- c(seq(50), min(which(y == 2)) + seq(0, 49), min(which(y == 3)) + seq(0, 49))
  
  d_config <- d[["1"]]
  m_config <- m[["14"]]
  s_config <- s[["2"]]
  f_config <- f[["1399"]]
  scaled_data <- intermediate_read(d_config, "scaled-dataset", m_config, s_config)
  
  # With selection
  selection <- intermediate_read(d_config, "feature-selection", m_config, s_config, f_config)
  I <- nrow(scaled_data)
  # scaled_data <- scaled_data[idx, ]
  scaled_data <- scaled_data[idx, selection]
  y <- y[idx]
  I <- nrow(scaled_data)
  K <- ncol(scaled_data)
  df <- data.frame(Feature = rep(colnames(scaled_data), each = I))
  df$TimeSeries <- rep(seq(I), K)
  df$Value <- as.vector(scaled_data)
  df$Ygroup <- ygroup_fn_v(df$Feature)
  df$Xgroup <- as.character(y)
  
  dim_x <- "TimeSeries"
  dim_y <- "Feature"
  lab_x <- "Time Series"
  lab_y <- "Feature"
  name_val <- "Value"
  limits <- c(0, 1)
  midpoint <- 0
  axis.text.y <- F
  # fn <- "heatmap_metering3.pdf"
  fn <- "heatmap_metering3_select.pdf"
  width <- widths_in[2]
  height <- heights_in[2]
  
}

eval_heatmap <- function(df, dim_x, dim_y, lab_x, lab_y, name_val, limits, midpoint, axis.text.y = T, fn) {
  x_breaks <- seq(min(df[[dim_x]]), max(df[[dim_x]]), length.out = 10)
  p <- ggplot(data = df, aes(x = get(dim_x), y = get(dim_y), fill = get(name_val)))
  p <- p + geom_tile()
  #p <- p + scale_fill_gradient2(space ="Lab", low = (colour = "#d7191c"), high = (colour = "#2b83ba"), limits = limits, midpoint = midpoint)
  p <- p + scale_fill_gradientn(colours = eval_color)
  p <- p + xlab(lab_x) + ylab(lab_y)
  
  #p <- p + scale_x_continuous(breaks = x_breaks)
  p <- p + scale_y_discrete(breaks = x_breaks)
  p <- p + eval_theme + theme(legend.position="none")
  p <- p + theme(axis.text.x = element_blank())
  # p <- p + facet_grid(Xgroup ~ Ygroup, scales = "free") #scales = "free_y", dir = "v") #, space = "free_y"
  # p <- p + facet_wrap( . ~Xgroup, scales = "free_x") #, space = "free_y"
  if (!axis.text.y) {
    p <- p + theme(axis.text.y = element_blank())
  }
  
  if (!is.null(fn)) {
    fp <- file.path("Plots", fn)
    cairo_pdf(fp, width = width, height = height)
  }
  
  plot(p)
  
  
  if (!is.null(fn)) {
    dev.off()
    embed_fonts(fp, options = "-dCompatibilityLevel=1.4")  
  }
  
}

acc <- function(y, pred) {
  cm <- NA
  suppressWarnings(cm <- confusionMatrix(pred, y))
  
  return(unname(cm$overall["Accuracy"]))
}

accuracy <- function(d_config, m_config, s_config, f_config, c_config, intermediate, dataset) {
  fp <- util_get_filepath(d_config, dataset, ext = "csv")
  y <- as.factor(read.table(fp, header = T, sep = ";")[, "Code"])
  
  pred <- intermediate_read(d_config, intermediate, m_config, s_config,
                            f_config, c_config)
  return(acc(y, pred) * 100)
}

accuracy_agg <- function(d_config, mname, cname, intermediate, dataset) {
  fp <- util_get_filepath(d_config, dataset, ext = "csv")
  y <- as.factor(read.table(fp, header = T, sep = ";")[, "Code"])
  pred <- intermediate_read(d_config, intermediate, mname, cname)
  return(acc(y, pred) * 100)
}

get_group_subgroup <- function(all_configs,
                               group_name,
                               subgroup_name,
                               value_fn,
                               intermediate,
                               dataset,
                               group_col = "name",
                               subgroup_col = "name",
                               group_levels,
                               subgroup_levels,
                               group_labels,
                               subgroup_labels,
                               agg) {
  dt <- data.table(Group = character(), Subgroup = character(),
                   Value = numeric(), Id = numeric(), Feature = character())
  for(all_config in all_configs) {
    if (agg) {
      for (d_config in all_config[[1]]) {
        for (mname in all_config[[2]]) {
          for (cname in all_config[[3]]) {
            if (!intermediate_exists(d_config, "classify", mname, cname)) {
              warning("Intermediate does not exist")
              next
            }
            
            if (intermediate_exists(d_config, "best", mname, cname)) {
              best <- intermediate_read(d_config, "best", mname, cname)
              m_config <- list(mid = best$mid[1])
              c_config <- list(cid = best$cid[1])
              s_config <- list(sid = best$sid[1])
              f_config <- list(fid = best$fid[1])
              n_features <- as.character(length(intermediate_read(d_config, "feature-selection",
                                                     m_config, s_config, f_config)))
              if (m_config$mid == 20) {
                n_features <- "*"
              }
            } else {
              if (mname == "raw")
                n_features <- "T"
              else
                n_features <- "?"
            }
            
            value <- unname(value_fn(d_config, mname, cname, intermediate, dataset))
            group <- get(group_name)[[group_col]]
            subgroup <- get(subgroup_name)[[subgroup_col]]
            id <- get(subgroup_name)[[1]]
            curr_value <- dt[Group == group & Subgroup == subgroup]$Value
            if (length(curr_value) == 0) {
              dt <- rbindlist(list(dt, list(group, subgroup, value, id, n_features)))  
            } else {
              if (curr_value < value) {
                dt[Group == group & Subgroup == subgroup, Value := value]
                dt[Group == group & Subgroup == subgroup, Id := id]
                dt[Group == group & Subgroup == subgroup, Feature := n_features]
              }
            }
          }
        }
      }
    } else {
      for (d_config in all_config[[1]]) {
        for (m_config in all_config[[2]]) {
          for (s_config in all_config[[3]]) {
            for (f_config in all_config[[4]]) {
              
              n_features <- length(intermediate_read(d_config, "feature-selection",
                                                     m_config, s_config, f_config))
              
              for (c_config in all_config[[5]]) {
                
                if (!intermediate_exists(d_config, intermediate, m_config, s_config,
                                         f_config, c_config)) {
                  warning("Intermediate does not exist")
                  next
                }
                
                value <- unname(value_fn(d_config, m_config, s_config, f_config, c_config, intermediate, dataset))
                group <- get(group_name)[[group_col]]
                subgroup <- get(subgroup_name)[[subgroup_col]]
                id <- get(subgroup_name)[[1]]
                curr_value <- dt[Group == group & Subgroup == subgroup]$Value
                if (length(curr_value) == 0) {
                  dt <- rbindlist(list(dt, list(group, subgroup, value, id, n_features)))  
                } else {
                  if (curr_value < value) {
                    dt[Group == group & Subgroup == subgroup, Value := value]
                    dt[Group == group & Subgroup == subgroup, Id := id]
                    dt[Group == group & Subgroup == subgroup, Feature := n_features]
                  }
                }
              }
            }
          }
        }
      }
    }
  }
  
  if (any(is.null(group_labels)))
    group_labels <- group_levels
  dt$Group <- factor(dt$Group, levels = group_levels, labels = group_labels)
  
  if (any(is.null(subgroup_labels)))
    subgroup_labels <- subgroup_levels
  dt$Subgroup <- factor(dt$Subgroup, levels = subgroup_levels, labels = subgroup_labels)
  
  print(dt)
  return(dt)
}

get_runtime <- function() {
  df <- openxlsx::read.xlsx("Evaluation/Eval.xlsx", "RuntimeDF")
  df$Subgroup2 <- paste(df$Subgroup, df$Classifier, sep = "-")
  df$Subgroup2 <- factor(df$Subgroup2,
                         levels = c("dwt-Eager",
                                    "dwt-Lazy",
                                    "fbr-Eager",
                                    "fbr-Lazy",
                                    "raw-Lazy",
                                    "rld-Lazy",
                                    "tsfresh-Eager",
                                    "tsfresh-Lazy"),
                         labels = c("DWT (eager)",
                                    "DWT (lazy)",
                                    "FBR (eager)",
                                    "FBR (lazy)",
                                    "Raw (lazy)",
                                    "RLD (lazy)",
                                    "tsfresh (eager)",
                                    "tsfresh (lazy)"))
  df$Time <- factor(df$Time, levels = c("Representation",
                                        "Scaling",
                                        "Selection",
                                        "Training",
                                        "Test"),
                    labels = c(" Representation   ",
                               " Normalization   ",
                               " Feature Selection   ",
                               " Classifier Estimation   ",
                               " Classifier Use"))
  df$Value <- df$Value / 1000
  return(df)
}

eval_group_subgroup <- function(all_configs,
                                group_name = "d_config", subgroup_name = "s_config",
                                group_label = "Dataset", subgroup_label = "Scaling", 
                                value_fn, value_label, ylim, ybreaks,
                                scale_fill, plot.margin,
                                legend.position,
                                legend.margin,
                                legend.box.margin,
                                legend.box.spacing,
                                legend.key.height,
                                subgroup_col = "name",
                                group_col = "name",
                                intermediate = "classify",
                                dataset = "queryset",
                                group_levels,
                                subgroup_levels,
                                group_labels = NULL,
                                subgroup_labels = NULL,
                                fn = NULL,
                                width = NULL,
                                height = NULL,
                                w_feature = F,
                                agg = F) {
  
  dt <- get_group_subgroup(all_configs,
                           group_name,
                           subgroup_name,
                           value_fn,
                           intermediate,
                           dataset,
                           group_col,
                           subgroup_col,
                           group_levels,
                           subgroup_levels,
                           group_labels,
                           subgroup_labels,
                           agg)
  
  if (!is.null(fn)) {
    fp <- file.path("Plots", fn)
    cairo_pdf(fp, width = width, height = height)
  }
  
  # names(dt) <- c(group_label, subgroup_label, value_label)          
  eval_barplot_group(as.data.frame(dt),
                     xlab = group_label,
                     ylab = value_label,
                     ylim,
                     ybreaks,
                     scale_fill,
                     plot.margin,
                     legend.position,
                     legend.margin,
                     legend.box.margin,
                     legend.box.spacing,
                     legend.key.height,
                     w_feature)
  
  if (!is.null(fn)) {
    dev.off()
    embed_fonts(fp, options = "-dCompatibilityLevel=1.4")  
  }
}

eval_barplot_group <- function(df,
                               xlab,
                               ylab,
                               ylim,
                               ybreaks,
                               scale_fill,
                               plot.margin,
                               legend.position,
                               legend.margin,
                               legend.box.margin,
                               legend.box.spacing,
                               legend.key.height,
                               w_feature = F) {
  p <- ggplot(df, aes(Group, fill = Subgroup, y = Value))
  p <- p + geom_col(position = position_dodge2(width = 1, preserve = "total"),
                    color = "black", size = 0.1)
  p <- p + eval_theme + theme(legend.position="none")
  p <- p + scale_fill
  p <- p + scale_y_continuous(breaks = ybreaks, lim = ylim)
  p <- p + theme(legend.position = legend.position,
                 plot.margin = plot.margin,
                 legend.margin = legend.margin,
                 legend.box.margin = legend.box.margin,
                 legend.box.spacing = legend.box.spacing,
                 legend.key.height = legend.key.height)
  
  if (w_feature) {
    p <- p + geom_text(aes(y = 100, label = Feature), vjust = -0.3, size = 3,
                       position = position_dodge2(width = 0.9), family = font_family) 
  }
  plot(p)
}

eval_runtime <- function(xlab,
                         ylab,
                         scale_fill,
                         scale_linetype,
                         plot.margin,
                         legend.position,
                         legend.margin,
                         legend.box.margin,
                         legend.box.spacing,
                         legend.key.height,
                         width = NULL,
                         height = NULL,
                         fn = NULL) {
  
  df <- get_runtime()
  
  
  # df <- df[df$Subgroup %in% c("dwt", "fbc"),]
  p <- ggplot(df, aes(x = Group, y = Value, fill = Time, linetype = Time)) +
    geom_bar(position = "stack", stat = "identity", color = "black", size = 0.1) +
    facet_wrap( ~ Subgroup2, scales = "free_y", ncol = 4)
  
  p <- p + eval_theme + theme(legend.position="none")
  p <- p + scale_fill
  p <- p + scale_linetype
  p <- p + xlab(xlab) + ylab(ylab)
  #p <- p + scale_y_continuous(breaks = ybreaks, lim = ylim)
  p <- p + scale_y_continuous(#breaks = sort(unique(df[[x_dim]])), lim = c(NA, xlim_max),
                     labels = function(x) format(x, big.mark = ",", scientific = FALSE))
  p <- p + theme(legend.position = legend.position,
                 plot.margin = plot.margin,
                 legend.margin = legend.margin,
                 legend.box.margin = legend.box.margin,
                 legend.box.spacing = legend.box.spacing,
                 legend.key.height = legend.key.height,
                 strip.background = element_rect(colour=NA, fill=NA)
                 )
  
  if (!is.null(fn)) {
    fp <- file.path("Plots", fn)
    cairo_pdf(fp, width = width, height = height)
  }
  
  plot(p)
  
  
  if (!is.null(fn)) {
    dev.off()
    embed_fonts(fp, options = "-dCompatibilityLevel=1.4")  
  }
  
}

eval_barplot_group <- function(df,
                               xlab,
                               ylab,
                               ylim,
                               ybreaks,
                               scale_fill,
                               plot.margin,
                               legend.position,
                               legend.margin,
                               legend.box.margin,
                               legend.box.spacing,
                               legend.key.height,
                               w_feature = F) {
  p <- ggplot(df, aes(Group, fill = Subgroup, y = Value))
  p <- p + geom_col(position = position_dodge2(width = 1, preserve = "total"),
                    color = "black", size = 0.1)
 
  p <- p + xlab(xlab) + ylab(ylab)
  p <- p + eval_theme + theme(legend.position="none")
  p <- p + scale_fill
  p <- p + scale_y_continuous(breaks = ybreaks, lim = ylim)
  p <- p + theme(legend.position = legend.position,
                 plot.margin = plot.margin,
                 legend.margin = legend.margin,
                 legend.box.margin = legend.box.margin,
                 legend.box.spacing = legend.box.spacing,
                 legend.key.height = legend.key.height)
  if (w_feature) {
    p <- p + geom_text(aes(y = 100, label = Feature), vjust = -0.3, size = 3,
                       position = position_dodge2(width = 0.9), family = font_family)
  }
  plot(p)
}

eval_acc_vs_run <- function(scale_color,
                            plot.margin,
                            legend.position,
                            legend.margin,
                            legend.box.margin,
                            legend.box.spacing,
                            legend.key.height,
                            width,
                            height,
                            fn,
                            group = "Metering",
                            xlim = NULL,
                            ylimits) {
  mnames <- list(list(mname = "dwt"), list(mname = "fbr"), list(mname = "tsfresh"))
  cnames <- list(list(cname = "dt"), list(cname = "svm"), list(cname = "gbm"))
  dt_eager <- get_group_subgroup(list(list(d[2:3], mnames, cnames)),
                                 group_name = "d_config", subgroup_name = "mname",
                                 value_fn = accuracy_agg,
                                 intermediate = "classify",
                                 dataset = "queryset",
                                 group_col = "name",
                                 subgroup_col = "mname",
                                 group_levels = c("Metering", "Payment"),
                                 subgroup_levels = c("dwt", "tsfresh", "fbr"),
                                 group_labels = NULL,
                                 subgroup_labels = NULL,
                                 agg = T)
  
  mnames <- list(list(mname = "raw"),
                 list(mname = "rld"),
                 list(mname = "dwt"),
                 list(mname = "fbr"),
                 list(mname = "tsfresh"))
  cnames <- list(list(cname = "knn"))
  dt_lazy <- get_group_subgroup(list(list(d[2:3], mnames, cnames)),
                                group_name = "d_config", subgroup_name = "mname",
                                value_fn = accuracy_agg,
                                intermediate = "classify",
                                dataset = "queryset",
                                group_col = "name", 
                                subgroup_col = "mname",
                                group_levels = c("Metering", "Payment"),
                                subgroup_levels = c("raw", "rld", "dwt", "tsfresh", "fbr"),
                                group_labels = NULL,
                                subgroup_labels = NULL,
                                agg = T)
  
  dt_eager$Classifier <- "Eager"
  dt_lazy$Classifier <- "Lazy"
  dt_acc <- rbind(dt_eager, dt_lazy)
  dt_acc$Group <- as.character(dt_acc$Group)
  dt_acc$Subgroup <- as.character(dt_acc$Subgroup)
  dt_runtime <- as.data.table(get_runtime())
  
  dt_runtime_sum <- dt_runtime[, sum(Value), by = c("Group", "Subgroup", "Classifier")]
  colnames(dt_runtime_sum)[4] <- "Runtime"
  dt <- merge(dt_acc, dt_runtime_sum, by = c("Group", "Subgroup", "Classifier"), all = T)
  dt$Subgroup2 <- paste(dt$Subgroup, dt$Classifier, sep = "-")
  dt$Subgroup2 <- factor(dt$Subgroup2,
                         levels = c("dwt-Eager",
                                    "dwt-Lazy",
                                    "fbr-Eager",
                                    "fbr-Lazy",
                                    "raw-Lazy",
                                    "rld-Lazy",
                                    "tsfresh-Eager",
                                    "tsfresh-Lazy"),
                         labels = c("DWT (eager)",
                                    "DWT (lazy)",
                                    "FBR (eager)",
                                    "FBR (lazy)",
                                    "Raw",
                                    "RLD",
                                    "tsfresh (eager)",
                                    "tsfresh (lazy)"))
  
  if (!is.null(fn)) {
    fp <- file.path("Plots", fn)
    cairo_pdf(fp, width = width, height = height)
  }
  
  p <- ggplot(dt[Group == group], aes(x = Value, y = Runtime, color = Subgroup, label = Subgroup2))
  p <- p + scale_y_log10(limits = ylimits,
                         labels = function(x) format(x, big.mark = ",", scientific = FALSE))
  p <- p + geom_point(shape=4) + scale_color
  p <- p + xlab("Accuracy (%)") + ylab("Runtime (s)")
  p <- p + eval_theme + theme(legend.position="none")
  p <- p + xlim(xlim)
  # p <- p + theme(legend.position = legend.position,
  #                plot.margin = plot.margin,
  #                legend.margin = legend.margin,
  #                legend.box.margin = legend.box.margin,
  #                legend.box.spacing = legend.box.spacing,
  #                legend.key.height = legend.key.height)
  p <- p + geom_label_repel(size = 2.5, show.legend = F, family = font_family)
  
  print(p)
  
  if (!is.null(fn)) {
    dev.off()
    embed_fonts(fp, options = "-dCompatibilityLevel=1.4")  
  }
  
}

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Format -----------------------------------------------------------------------
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
widths_in <- c(15, 7.5, 5) / 2.54
heights_in <- c(9.27, 4.63, 3.09) / 2.54
heights_in_2_alter <- 4 / 2.54
width_in_2 <- 1.48
height_in_2 <- 1.04
height_in_2_heat <- 1.31
width_in <- 3.48
height_in <- 2.15
text_size <- 7
theme_size <- 5/14 * text_size
if ("Linux Libertine" %in% fonts()) {
  font_family <- "Linux Libertine"
} else {
  font_family <- "sans"
}
font_family <- "Palatino Linotype"

# run once font_import()
# run once loadfonts() and make sure Linux Libertine is loaded
eval_color <- c("#2b83ba", "#d7191c", "#fdae61", "#ffffbf", "#606060", "#000000")
eval_color <- c("#2b83ba", "#891012", "#fdae61", "#ffffbf", "#262626", "#000000", "#FFFFFF")
eval_color_not_bw <- c("#2b83ba", "#d7191c", "#fc8003", "#429537", "#606060", "#000000")
eval_scale_color <- scale_color_manual(values = eval_color)

eval_theme <- theme(
  line = element_line(size = 0.3),
  text = element_text(family=font_family, size=text_size),
  title = element_text(family=font_family, size=text_size),
  legend.title  = element_blank(), #element_text(size=text_size, family=font_family),
  legend.text   = element_text(size=text_size, family=font_family),
  legend.position = "none", #c(1, 1),
  legend.justification = c(0, 0),
  legend.box.margin = margin(0, 0, 0, 0, "mm"),
  legend.box.spacing = unit(c(-1, -1, -1, -1), "mm"),
  legend.background = element_rect(color = "white", fill= "white"),
  legend.box.background = element_rect(color = "white", fill= NA),
  legend.key = element_rect(color = "white", fill= "white"),
  legend.key.height = unit(1, "mm"),
  legend.direction = "horizontal",
  axis.ticks = element_line(colour = "black", size = 0.2),
  axis.text.y   = element_text(size=text_size, color = "black", family=font_family),
  axis.text.x   = element_text(size=text_size, color = "black", family=font_family),
  axis.title.y  = element_text(size=text_size, family=font_family, margin = unit(c(0, 1, 0, 0), "mm")),
  axis.title.x  = element_text(size=text_size, family=font_family),
  panel.background = element_blank(),
  panel.grid.major = element_line(colour = "#AFAFAF", size = 0.1),
  #panel.grid.minor = element_blank(),
  axis.line = element_line(colour = "black", size = 0.0),
  panel.border = element_rect(color = "black", fill=NA, size=0.3),
  # top, right, bottom, left
  plot.margin = unit(c(1, 2, 1, 1.7), "mm"),
  plot.background = element_rect(color = "white", fill= "white"),
  strip.background = element_rect(color = "white", fill= "white")
)
