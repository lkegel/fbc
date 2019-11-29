suppressPackageStartupMessages(library(ggplot2))
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

acc <- function(y, pred) {
  cm <- NA
  suppressWarnings(cm <- confusionMatrix(pred, y))
  
  return(unname(cm$overall["Accuracy"]))
}

accuracy <- function(d_config, m_config, s_config, f_config, c_config) {
  fp <- util_get_filepath(d_config, "queryset", ext = "csv")
  y <- as.factor(read.table(fp, header = T, sep = ";")[, "Code"])
  
  pred <- intermediate_read(d_config, "classify", m_config, s_config,
                            f_config, c_config)
  return(acc(y, pred))
}

accuracy_agg <- function(d_config, mname, cname) {
  fp <- util_get_filepath(d_config, "queryset", ext = "csv")
  y <- as.factor(read.table(fp, header = T, sep = ";")[, "Code"])
  pred <- intermediate_read(d_config, "classify", mname, cname)
  return(acc(y, pred))
}


eval_group_subgroup <- function(d_configs, m_configs, s_configs, f_configs, c_configs,
                                group_name = "d_config", subgroup_name = "s_config",
                                group_label = "Dataset", subgroup_label = "Scaling", 
                                value_fn, value_label, ylim, ybreaks,
                                scale_fill, plot.margin,
                                legend.position,
                                legend.margin,
                                legend.box.margin,
                                legend.box.spacing,
                                legend.key.height,
                                subgroup_col = "name") {
  dt <- data.table(Group = character(), Subgroup = character(), Value = numeric(), Id = numeric())
  for (d_config in d_configs) {
    for (m_config in m_configs) {
      for (s_config in s_configs) {
        for (f_config in f_configs) {
          for (c_config in c_configs) {
            
            if (!intermediate_exists(d_config, "classify", m_config, s_config,
                              f_config, c_config)) {
              warning("Intermediate does not exist")
              next
            }
            
            value <- unname(value_fn(d_config, m_config, s_config, f_config, c_config))
            group <- get(group_name)$name
            subgroup <- get(subgroup_name)[[subgroup_col]]
            id <- get(subgroup_name)[[1]]
            curr_value <- dt[Group == group & Subgroup == subgroup]$Value
            if (length(curr_value) == 0) {
              dt <- rbindlist(list(dt, list(group, subgroup, value, id)))  
            } else {
              if (curr_value < value) {
                dt[Group == group & Subgroup == subgroup, Value := value]
                dt[Group == group & Subgroup == subgroup, Id := id]
              }
            }
            
          }
        }
      }
    }
  }
  
  print(dt)
  
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
                     legend.key.height)
  
  
}

eval_group_subgroup_agg <- function(d_configs, mnames, cnames,
                                group_name = "d_config", subgroup_name = "mname",
                                group_label = "Dataset", subgroup_label = "Method", 
                                value_fn, value_label, ylim, ybreaks,
                                scale_fill, plot.margin,
                                legend.position,
                                legend.margin,
                                legend.box.margin,
                                legend.box.spacing,
                                legend.key.height,
                                subgroup_col = "name") {
  dt <- data.table(Group = character(), Subgroup = character(), Value = numeric(), Id = numeric())
  for (d_config in d_configs) {
    for (mname in mnames) {
      for (cname in cnames) {
        if (!intermediate_exists(d_config, "classify", mname, cname)) {
          warning("Intermediate does not exist")
          next
        }
            
        value <- unname(value_fn(d_config, mname, cname))
        group <- get(group_name)$name
        subgroup <- get(subgroup_name)[[subgroup_col]]
        id <- get(subgroup_name)[[1]]
        curr_value <- dt[Group == group & Subgroup == subgroup]$Value
        if (length(curr_value) == 0) {
          dt <- rbindlist(list(dt, list(group, subgroup, value, id)))  
        } else {
          if (curr_value < value) {
            dt[Group == group & Subgroup == subgroup, Value := value]
            dt[Group == group & Subgroup == subgroup, Id := id]
          }
        }
      }
    }
  }
  
  print(dt)
  
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
                     legend.key.height)
  
  
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
                               legend.key.height) {
  p <- ggplot(df, aes(Group, fill = Subgroup, y = Value))
  p <- p + geom_col(position = "dodge2")
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
  plot(p)
}

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Format -----------------------------------------------------------------------
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
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

# run once font_import()
# run once loadfonts() and make sure Linux Libertine is loaded
eval_color <- c("#2b83ba", "#d7191c", "#fc8003", "#429537", "#606060")
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
  plot.margin = unit(c(1, 2, 1, 1.7), "mm")
)