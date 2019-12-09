#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Directory --------------------------------------------------------------------
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
root <- file.path(Sys.getenv("FBC"))
setwd(root)
source("Implementation/init.R")

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# +++++++++++ ------------------------------------------------------------------
# Calibration ------------------------------------------------------------------
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
run_method(d, m)
# 80 - is done separately
run_represent(d, m[c("10", "11", "12", "13", "14", "15", "20", "30")], force = F)
run_represent(d[3], m["14"], force = T, parallel = F)
# rld and dwt are not scaled or imputed
run_scale(d, m[c("10", "11", "12", "13", "14", "15", "80")], s[c("1", "2", "3", "5")], force = F)
run_scale(d, m[c("20", "30")], s["4"])

# run_feature_selection(d, m[c("10", "11", "12", "80")], s[c("1", "2", "3", "5")],
#                       f[c("1", "1010", "1020", "1030", "1037", "1040", "1050", "1060", "1070", "1073", "1080", "1090", "8000")], force = F, parallel = T)
run_feature_selection(d, m[c("13", "14", "15", "80")], s[c("1", "2", "3", "5")],
                      f[c("1", "1399", "8000")], force = F, parallel = F)
run_feature_selection(d, m["20"], s["4"], f["1"], force = F, parallel = F)
run_feature_selection(d, m["30"], s["4"], f[c("3002", "3004", "3008", "3016")], force = F, parallel = T)
run_feature_selection(d[1:2], m["30"], s["4"], f[c("3006", "3073")], force = F, parallel = T)
run_feature_selection(d["3"], m["30"], s["4"], f["3037"], force = F, parallel = T)
run_feature_selection(d, m["30"], s["4"], f["1"], force = F, parallel = F)

eval_feature_selection(d[2:3], m["14"], s["2"], f[c("1", "1399", "8000")])

run_validate(d, m[c("13", "14", "15", "80")], s[c("1", "2", "3", "5")], f[c("1", "1399", "8000")], c[c("10", "20", "30")], force = F, parallel = F)
run_validate(d, m[c("13", "14", "15", "80")], s[c("1", "2", "3", "5")], f[c("1", "1399", "8000")], c[as.character(seq(3001, 3030))], force = F, parallel = F)
run_validate(d, m[c("13", "14", "15", "80")], s[c("1", "2", "3", "5")], f[c("1", "1399", "8000")], c[c("21", "22", "23")], force = F, parallel = F, loop_parallel = T)
run_validate(d, m[c("13", "14", "15", "80")], s[c("1", "2", "3", "5")], f[c("1", "1399", "8000")], c["41"], force = F, parallel = T)
run_validate(d, m["20"], s["4"], f["1"], c["41"], force = F, parallel = T)
run_validate(d[1:2], m["30"], s["4"], f[c("3002", "3004", "3008", "3016", "3073")], c[c("10", "20", "21", "30", as.character(seq(3001, 3030)))], force = F, parallel = T)
run_validate(d[3], m["30"], s["4"], f[c("3002", "3004", "3008", "3016", "3037")], c[c("10", "20", "21", "30", as.character(seq(3001, 3030)))], force = F, parallel = T)
run_validate(d, m["30"], s["4"], f[c("3002", "3004", "3008", "3016")], c["41"], force = F, parallel = T)
run_validate(d[1:2], m["30"], s["4"], f["3006"], c["41"], force = F, parallel = T)
run_validate(d[3], m["30"], s["4"], f["3037"], c["41"], force = F, parallel = T)
run_validate(d[2:3], m["30"], s["4"], f["1"], c[c("10", "30", as.character(seq(3001, 3030)))], force = F, parallel = F)
eval_validate(d["1"], m[c("13", "14", "15", "80")], s[c("1", "2", "3", "5")], f[c("1", "1399", "8000")], c[c("10", "20", "30")])


# Run best (per Dataset, Method, Classifer)
run_best(d, m[c("13", "14", "15")], s[c("1", "2", "3", "5")], f[c("1", "1399", "8000")], c["10"])
run_best(d, m[c("13", "14", "15")], s[c("1", "2", "3", "5")], f[c("1", "1399", "8000")], c[c("20", "21")])
run_best(d, m[c("13", "14", "15")], s[c("1", "2", "3", "5")], f[c("1", "1399", "8000")], c[c("30", as.character(seq(3001, 3030)))])
run_best(d, m[c("13", "14", "15")], s[c("1", "2", "3", "5")], f[c("1", "1399", "8000")], c["41"])
run_best(d, m["80"], s[c("1", "2", "3", "5")], f[c("1", "1399", "8000")], c["10"])
run_best(d, m["80"], s[c("1", "2", "3", "5")], f[c("1", "1399", "8000")], c[c("20", "21")])
run_best(d, m["80"], s[c("1", "2", "3", "5")], f[c("1", "1399", "8000")], c[c("30", as.character(seq(3001, 3030)))])
run_best(d, m["80"], s[c("1", "2", "3", "5")], f[c("1", "1399", "8000")], c["41"])
run_best(d, m["30"], s["4"], f[c("3002", "3004", "3008", "3016")], c["41"])
run_best(d, m["30"], s["4"], f[c("3002", "3004", "3008", "3016")], c[c("10", "20", "21", "30", as.character(seq(3001, 3030)))])

# Run best on subset (per Dataset, Method, Classifer)
run_best(d[1:2], m["14"], s["1"], f["1399"], c["10"])
run_best(d[1:2], m["14"], s["5"], f["1399"], c[c("20", "21")])
run_best(d[1:2], m["14"], s["1"], f["1399"], c[c("30", as.character(seq(3001, 3030)))])
run_best(d[3], m["14"], s["1"], f["1"], c["10"])
run_best(d[3], m["14"], s["5"], f["1"], c[c("20", "21")])
run_best(d[3], m["14"], s["1"], f["1"], c[c("30", as.character(seq(3001, 3030)))])
# run_best(d[1:2], m["14"], s["2"], f["1399"], c["41"])
run_best(d[1:2], m["14"], s["2"], f["1"], c["41"])
run_best(d[3], m["14"], s["2"], f["1"], c["41"])
run_best(d[2:3], m["30"], s["4"], f["3016"], c["10"])
run_best(d[2:3], m["30"], s["4"], f["3016"], c[c("20", "21")])
run_best(d[2:3], m["30"], s["4"], f["3016"], c[c("30", as.character(seq(3001, 3030)))])
run_best(d[2:3], m["30"], s["4"], f["3016"], c["41"])
run_best(d[2:3], m["80"], s["1"], f["1"], c["10"])
run_best(d[2:3], m["80"], s["5"], f["8000"], c[c("20", "21")])
run_best(d[2:3], m["80"], s["1"], f["1"], c[c("30", as.character(seq(3001, 3030)))])
run_best(d[1:2], m["80"], s["5"], f["1399"], c["41"])
run_best(d[3], m["80"], s["5"], f["8000"], c["41"])


# Run classify
run_classify(d, m[c("13", "14", "15")], s[c("1", "2", "3", "5")], f[c("1", "1399", "8000")], c["10"])
run_classify(d, m[c("13", "14", "15")], s[c("1", "2", "3", "5")], f[c("1", "1399", "8000")], c[c("20", "21")])
run_classify(d, m[c("13", "14", "15")], s[c("1", "2", "3", "5")], f[c("1", "1399", "8000")], c[c("30", as.character(seq(3001, 3030)))], force = T)
run_classify(d, m[c("13", "14", "15")], s[c("1", "2", "3", "5")], f[c("1", "1399", "8000")], c["41"])
run_classify(d, m["20"],                s["4"],                   f["1"],                    c["41"], force = F, parallel = T)
run_classify(d, m["30"], s["4"], f[c("3002", "3004", "3008", "3016")], c["41"], force = F)
run_classify(d, m["30"], s["4"], f[c("3002", "3004", "3008", "3016")], c[c("10", "20", "21", "30", as.character(seq(3001, 3030)))])
run_classify(d, m["80"], s[c("1", "2", "3", "5")], f[c("1", "1399", "8000")], c["10"], parallel = T)
run_classify(d, m["80"], s[c("1", "2", "3", "5")], f[c("1", "1399", "8000")], c[c("20", "21")], force = F)
run_classify(d, m["80"], s[c("1", "2", "3", "5")], f[c("1", "1399", "8000")], c[c("30", as.character(seq(3001, 3030)))], force = F)
run_classify(d, m["80"], s[c("1", "2", "3", "5")], f[c("1", "1399", "8000")], c["41"], force = F)
raw_convert(d)


# Run classify on subset
run_classify(d[2], m["14"], s["1"], f["1399"], c["10"], force = T)
run_classify(d[2], m["14"], s["5"], f["1399"], c[c("20", "21")], force = T)
run_classify(d[2], m["14"], s["1"], f["1399"], c[c("30", as.character(seq(3001, 3030)))], force = T)
run_classify(d[3], m["14"], s["1"], f["1"], c["10"], force = T)
run_classify(d[3], m["14"], s["5"], f["1"], c[c("20", "21")], force = T)
run_classify(d[3], m["14"], s["1"], f["1"], c[c("30", as.character(seq(3001, 3030)))], force = T)
run_classify(d[2], m["14"], s["2"], f["1"], c["41"], force = T, parallel = T)
run_classify(d[3], m["14"], s["2"], f["1"], c["41"])
run_classify(d, m["20"],                s["4"],                   f["1"],                    c["41"], force = F, parallel = T)
run_classify(d[2:3], m["30"], s["4"], f["3016"], c["10"])
run_classify(d[2:3], m["30"], s["4"], f["3016"], c[c("20", "21")], force = F)
run_classify(d[2:3], m["30"], s["4"], f["3016"], c[c("30", as.character(seq(3001, 3030)))])
run_classify(d[2:3], m["30"], s["4"], f["3016"], c["41"], force = T, parallel = T)
run_classify(d[2:3], m["80"], s["1"], f["1"], c["10"], force = T)
run_classify(d[2:3], m["80"], s["5"], f["8000"], c[c("20", "21")], force = T)
run_classify(d[2:3], m["80"], s["1"], f["1"], c[c("30", as.character(seq(3001, 3030)))], force = T)
run_classify(d[2], m["80"], s["5"], f["8000"], c["41"], force = T)
run_classify(d[3], m["80"], s["5"], f["8000"], c["41"], force = T)
raw_convert(d)

# Eval fbr per d and c
mnames <- list(list(mname = "fbr"))
cnames <- list(list(cname = "dt"), list(cname = "svm"), list(cname = "gbm"))
eval_group_subgroup_agg(d[2:3], mnames, cnames,
                    group_name = "d_config", subgroup_name = "cname",
                    group_label = "Dataset", subgroup_label = "Classifier",
                    value_fn = accuracy_agg, value_label = "Accuracy",
                    ylim = c(0, 1), ybreaks = seq(0, 1, 0.1),
                    scale_fill = scale_fill_manual(values = eval_color[1:3]),
                    plot.margin = unit(c(4, 2, 1, 1.7), "mm"),
                    legend.position = c(0.1, 0.9),
                    legend.margin = margin(0, 0, 0, 0, "mm"),
                    legend.box.margin = margin(1, 1, 1, 1, "mm"),
                    legend.box.spacing = unit(0, "mm"),
                    legend.key.height = unit(2, "mm"),
                    subgroup_col = "cname",
                    group_col = "did")

# Eval eager per d and r
mnames <- list(list(mname = "fbr"), list(mname = "tsfresh"), list(mname = "dwt"))
cnames <- list(list(cname = "gbm"), list(cname = "svm"), list(cname = "gbm"))
eval_group_subgroup(list(list(d[2:3], mnames, cnames)),
                    group_name = "d_config", subgroup_name = "mname",
                    group_label = "Dataset", subgroup_label = "Method",
                    value_fn = accuracy_agg, value_label = "Accuracy (%)",
                    ylim = c(0, 110), ybreaks = seq(0, 100, 20),
                    scale_fill = scale_fill_manual(values = eval_color[1:3]),
                    plot.margin = unit(c(5, 2, 1, 1.7), "mm"),
                    legend.position = c(0, 1.01),
                    legend.margin = margin(0, 0, 0, 0, "mm"),
                    legend.box.margin = margin(1, 1, 1, 1, "mm"),
                    legend.box.spacing = unit(0, "mm"),
                    legend.key.height = unit(2, "mm"),
                    subgroup_col = "mname",
                    group_col = "name",
                    intermediate = "classify",
                    dataset = "queryset",
                    group_levels = c("Metering", "Payment"),
                    subgroup_levels = c("dwt", "tsfresh", "fbr"),
                    group_labels = NULL,
                    subgroup_labels = c("DWT", "tsfresh", "FBR"),
                    fn = NULL, #"acc_eager.pdf",
                    width = widths_in[2],
                    height = heights_in[2],
                    w_feature = T,
                    agg = T)

# Eval lazy
mnames <- list(list(mname = "raw"),
               list(mname = "rld"),
               list(mname = "dwt"),
               list(mname = "fbr"),
               list(mname = "tsfresh"))
cnames <- list(list(cname = "knn"))
eval_group_subgroup(list(list(d[2:3], mnames, cnames)),
                    group_name = "d_config", subgroup_name = "mname",
                    group_label = "Dataset", subgroup_label = "Method",
                    value_fn = accuracy_agg, value_label = "Accuracy (%)",
                    ylim = c(0, 110), ybreaks = seq(0, 100, 20),
                    scale_fill = scale_fill_manual(values = eval_color[1:5]),
                    plot.margin = unit(c(5, 2, 1, 1.7), "mm"),
                    legend.position = c(0, 1.01),
                    legend.margin = margin(0, 0, 0, 0, "mm"),
                    legend.box.margin = margin(1, 1, 1, 1, "mm"),
                    legend.box.spacing = unit(0, "mm"),
                    legend.key.height = unit(2, "mm"),
                    subgroup_col = "mname",
                    group_col = "name",
                    intermediate = "classify",
                    dataset = "queryset",
                    group_levels = c("Metering", "Payment"),
                    subgroup_levels = c("raw", "rld", "dwt", "tsfresh", "fbr"),
                    group_labels = NULL,
                    subgroup_labels = c("Raw", "RLD", "DWT", "tsfresh", "FBR"),
                    fn = "acc_lazy.pdf",
                    width = widths_in[2],
                    height = heights_in[2],
                    w_feature = T,
                    agg = T)

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# +++++++++++ ------------------------------------------------------------------
# FBR --------------------------------------------------------------------------
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# - Feature Set -> Dataset (dt, no scale, no select) ---------------------------
eval_group_subgroup(list(list(d[2:3], m[c("13", "14", "15")],  s["1"], f["1"], c["20"])),
                    group_name = "d_config", subgroup_name = "m_config",
                    group_label = NULL, subgroup_label = "Method",
                    value_fn = accuracy, value_label = "Accuracy (%)",
                    ylim = c(0, 110), ybreaks = seq(0, 120, 20),
                    scale_fill = scale_fill_manual(values = eval_color[1:5]),
                    plot.margin = unit(c(5, 2, 1, 1.7), "mm"),
                    legend.position = c(0, 1.01),
                    legend.margin = margin(0, 0, 0, 0, "mm"),
                    legend.box.margin = margin(1, 1, 1, 1, "mm"),
                    legend.box.spacing = unit(0, "mm"),
                    legend.key.height = unit(2, "mm"),
                    subgroup_col = "mid",
                    group_col = "name",
                    intermediate = "validate",
                    dataset = "dataset",
                    group_levels = c("Metering", "Payment"),
                    subgroup_levels = c("13", "14", "15"),
                    group_labels = NULL,
                    subgroup_labels = c("Strength", "Reconstructible", "Both"),
                    fn = "fbr_method.pdf",
                    width = widths_in[2],
                    height = heights_in[2],
                    w_feature = T)

# - Scale -> Dataset (svm, no select) ------------------------------------------
eval_group_subgroup(list(list(d[2:3], m["14"], s[c("1", "2", "3", "5")], f["1"], c["20"])),
                    group_name = "d_config", subgroup_name = "s_config",
                    group_label = NULL, subgroup_label = "Scale",
                    value_fn = accuracy, value_label = NULL,
                    ylim = c(0, 110), ybreaks = seq(0, 120, 20),
                    scale_fill = scale_fill_manual(values = eval_color[1:5]),
                    plot.margin = unit(c(5, 2, 1, 1.7), "mm"),
                    legend.position = c(0, 1.01),
                    legend.margin = margin(0, 0, 0, 0, "mm"),
                    legend.box.margin = margin(1, 1, 1, 1, "mm"),
                    legend.box.spacing = unit(0, "mm"),
                    legend.key.height = unit(2, "mm"),
                    subgroup_col = "name",
                    group_col = "name",
                    intermediate = "validate",
                    dataset = "dataset",
                    group_levels = c("Metering", "Payment"),
                    subgroup_levels = c("No Scaling", "01 Scaling with Outlier", "01 Scaling", "Z Scaling"),
                    group_labels = NULL,
                    subgroup_labels = c("No", "01 with Outlier", "01", "Z"),
                    fn = "fbr_norm_svm.pdf",
                    width = widths_in[2],
                    height = heights_in[2],
                    w_feature = F)

eval_group_subgroup(list(list(d[2:3], m["14"], s[c("1", "2", "3", "5")], f["1"], c["41"])),
                    group_name = "d_config", subgroup_name = "s_config",
                    group_label = NULL, subgroup_label = "Scale",
                    value_fn = accuracy, value_label = "Accuracy (%)",
                    ylim = c(0, 110), ybreaks = seq(0, 120, 20),
                    scale_fill = scale_fill_manual(values = eval_color[1:5]),
                    plot.margin = unit(c(5, 2, 1, 1.7), "mm"),
                    legend.position = c(0, 1.01),
                    legend.margin = margin(0, 0, 0, 0, "mm"),
                    legend.box.margin = margin(1, 1, 1, 1, "mm"),
                    legend.box.spacing = unit(0, "mm"),
                    legend.key.height = unit(2, "mm"),
                    subgroup_col = "name",
                    group_col = "name",
                    intermediate = "validate",
                    dataset = "dataset",
                    group_levels = c("Metering", "Payment"),
                    subgroup_levels = c("No Scaling", "01 Scaling with Outlier", "01 Scaling", "Z Scaling"),
                    group_labels = NULL,
                    subgroup_labels = c("No", "01 with Outlier", "01", "Z"),
                    fn = "fbr_norm_knn.pdf",
                    width = widths_in[2],
                    height = heights_in[2])

# - Selection -> Dataset (dt, no scaling) --------------------------------------
eval_group_subgroup(list(list(d[2:3], m["14"], s["5"], f[c("1", "1399", "8000")], c["20"])),
                    group_name = "d_config", subgroup_name = "f_config",
                    group_label = NULL, subgroup_label = "Selection",
                    value_fn = accuracy, value_label = NULL,
                    ylim = c(0, 110), ybreaks = seq(0, 120, 20),
                    scale_fill = scale_fill_manual(values = eval_color[1:5]),
                    plot.margin = unit(c(5, 2, 1, 1.7), "mm"),
                    legend.position = c(0, 1.01),
                    legend.margin = margin(0, 0, 0, 0, "mm"),
                    legend.box.margin = margin(1, 1, 1, 1, "mm"),
                    legend.box.spacing = unit(0, "mm"),
                    legend.key.height = unit(2, "mm"),
                    subgroup_col = "name",
                    group_col = "name",
                    intermediate = "validate",
                    dataset = "dataset",
                    group_levels = c("Metering", "Payment"),
                    subgroup_levels = c("no", "fbr", "tsfresh"),
                    group_labels = NULL,
                    subgroup_labels = c("No", "CFS", "tsfresh"),
                    fn = "fbr_fs_knn.pdf",
                    width = widths_in[2],
                    height = heights_in[2],
                    w_feature = T)

# - Classifier -> Dataset (dt, no scaling) -------------------------------------
eval_group_subgroup(list(list(d, m["14"], s["1"], f["1"], c["10"]),
                         list(d, m["14"], s["5"], f["1"], c[c("20", "21")]),
                         list(d, m["14"], s["1"], f["1"], c[c("30", as.character(seq(3001, 3030)))]),
                         list(d[1:2], m["14"], s["2"], f["1399"], c["41"]),
                         list(d["3"], m["14"], s["2"], f["1"], c["41"])),
                    group_name = "d_config", subgroup_name = "c_config",
                    group_label = "Dataset", subgroup_label = "Classifier",
                    value_fn = accuracy, value_label = "Accuracy",
                    ylim = c(0, 1), ybreaks = seq(0, 1, 0.1),
                    scale_fill = scale_fill_manual(values = eval_color[1:5]),
                    plot.margin = unit(c(4, 2, 1, 1.7), "mm"),
                    legend.position = c(0.1, 0.9),
                    legend.margin = margin(0, 0, 0, 0, "mm"),
                    legend.box.margin = margin(1, 1, 1, 1, "mm"),
                    legend.box.spacing = unit(0, "mm"),
                    legend.key.height = unit(2, "mm"),
                    subgroup_col = "name",
                    group_col = "did",
                    intermediate = "validate",
                    dataset = "dataset")

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# +++++++++++ ------------------------------------------------------------------
# tsfresh ----------------------------------------------------------------------
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# - Scale -> Dataset (svm, no select) ------------------------------------------
eval_group_subgroup(list(list(d[2:3], m["80"], s[c("1", "2", "3", "5")], f["1"], c["21"])),
                    group_name = "d_config", subgroup_name = "s_config",
                    group_label = NULL, subgroup_label = "Scale",
                    value_fn = accuracy, value_label = "Accuracy (%)",
                    ylim = c(0, 100), ybreaks = seq(0, 100, 20),
                    scale_fill = scale_fill_manual(values = eval_color[1:5]),
                    plot.margin = unit(c(5, 2, 1, 1.7), "mm"),
                    legend.position = c(0, 1.01),
                    legend.margin = margin(0, 0, 0, 0, "mm"),
                    legend.box.margin = margin(1, 1, 1, 1, "mm"),
                    legend.box.spacing = unit(0, "mm"),
                    legend.key.height = unit(2, "mm"),
                    subgroup_col = "name",
                    group_col = "name",
                    intermediate = "validate",
                    dataset = "dataset",
                    group_levels = c("Metering", "Payment"),
                    subgroup_levels = c("No Scaling", "01 Scaling with Outlier", "01 Scaling", "Z Scaling"),
                    group_labels = NULL,
                    subgroup_labels = c("No", "01 with Outlier", "01", "Z"),
                    fn = "tsfresh_norm_svm.pdf",
                    width = widths_in[2],
                    height = heights_in[2],
                    w_feature = F)

# - Scale -> Dataset (knn, no select) ------------------------------------------
eval_group_subgroup(list(list(d[2:3], m["80"], s[c("1", "2", "3", "5")], f["1"], c["41"])),
                    group_name = "d_config", subgroup_name = "s_config",
                    group_label = NULL, subgroup_label = "Scale",
                    value_fn = accuracy, value_label = "Accuracy (%)",
                    ylim = c(0, 100), ybreaks = seq(0, 100, 20),
                    scale_fill = scale_fill_manual(values = eval_color[1:5]),
                    plot.margin = unit(c(5, 2, 1, 1.7), "mm"),
                    legend.position = c(0, 1.01),
                    legend.margin = margin(0, 0, 0, 0, "mm"),
                    legend.box.margin = margin(1, 1, 1, 1, "mm"),
                    legend.box.spacing = unit(0, "mm"),
                    legend.key.height = unit(2, "mm"),
                    subgroup_col = "name",
                    group_col = "name",
                    intermediate = "validate",
                    dataset = "dataset",
                    group_levels = c("Metering", "Payment"),
                    subgroup_levels = c("No Scaling", "01 Scaling with Outlier", "01 Scaling", "Z Scaling"),
                    group_labels = NULL,
                    subgroup_labels = c("No", "01 with Outlier", "01", "Z"),
                    fn = "tsfresh_norm_knn.pdf",
                    width = widths_in[2],
                    height = heights_in[2],
                    w_feature = F)

# - Selection -> Dataset (dt/gbm, no scaling) ----------------------------------
c("30", as.character(seq(3001, 3030)))])
eval_group_subgroup(list(list(d[2:3], m["80"], s["1"], f[c("1", "1399", "8000")],
                              c["10"])),
                    group_name = "d_config", subgroup_name = "f_config",
                    group_label = NULL, subgroup_label = "Selection",
                    value_fn = accuracy, value_label = "Accuracy",
                    ylim = c(0, 110), ybreaks = seq(0, 120, 20),
                    scale_fill = scale_fill_manual(values = eval_color[1:5]),
                    plot.margin = unit(c(5, 2, 1, 1.7), "mm"),
                    legend.position = c(0, 1.01),
                    legend.margin = margin(0, 0, 0, 0, "mm"),
                    legend.box.margin = margin(1, 1, 1, 1, "mm"),
                    legend.box.spacing = unit(0, "mm"),
                    legend.key.height = unit(2, "mm"),
                    subgroup_col = "name",
                    group_col = "name",
                    intermediate = "validate",
                    dataset = "dataset",
                    group_levels = c("Metering", "Payment"),
                    subgroup_levels = c("no", "fbr", "tsfresh"),
                    group_labels = NULL,
                    subgroup_labels = c("No", "CFS", "tsfresh"),
                    fn = NULL, #"tsfresh_fs_svm.pdf",
                    width = widths_in[2],
                    height = heights_in[2],
                    w_feature = T)

# - Selection -> Dataset (svm, no scaling) --------------------------------------
eval_group_subgroup(list(list(d, m["80"], s["5"], f[c("1", "1399", "8000")], c["21"])),
                    group_name = "d_config", subgroup_name = "f_config",
                    group_label = NULL, subgroup_label = "Selection",
                    value_fn = accuracy, value_label = "Accuracy",
                    ylim = c(0, 110), ybreaks = seq(0, 120, 20),
                    scale_fill = scale_fill_manual(values = eval_color[1:5]),
                    plot.margin = unit(c(5, 2, 1, 1.7), "mm"),
                    legend.position = c(0, 1.01),
                    legend.margin = margin(0, 0, 0, 0, "mm"),
                    legend.box.margin = margin(1, 1, 1, 1, "mm"),
                    legend.box.spacing = unit(0, "mm"),
                    legend.key.height = unit(2, "mm"),
                    subgroup_col = "name",
                    group_col = "name",
                    intermediate = "validate",
                    dataset = "dataset",
                    group_levels = c("Metering", "Payment"),
                    subgroup_levels = c("no", "fbr", "tsfresh"),
                    group_labels = NULL,
                    subgroup_labels = c("No", "CFS", "tsfresh"),
                    fn = "tsfresh_fs_svm.pdf",
                    width = widths_in[2],
                    height = heights_in[2],
                    w_feature = T)

# - Selection -> Dataset (knn, no scaling) --------------------------------------
eval_group_subgroup(list(list(d, m["80"], s["5"], f[c("1", "1399", "8000")], c["41"])),
                    group_name = "d_config", subgroup_name = "f_config",
                    group_label = NULL, subgroup_label = "Selection",
                    value_fn = accuracy, value_label = "Accuracy",
                    ylim = c(0, 110), ybreaks = seq(0, 120, 20),
                    scale_fill = scale_fill_manual(values = eval_color[1:5]),
                    plot.margin = unit(c(5, 2, 1, 1.7), "mm"),
                    legend.position = c(0, 1.01),
                    legend.margin = margin(0, 0, 0, 0, "mm"),
                    legend.box.margin = margin(1, 1, 1, 1, "mm"),
                    legend.box.spacing = unit(0, "mm"),
                    legend.key.height = unit(2, "mm"),
                    subgroup_col = "name",
                    group_col = "name",
                    intermediate = "validate",
                    dataset = "dataset",
                    group_levels = c("Metering", "Payment"),
                    subgroup_levels = c("no", "fbr", "tsfresh"),
                    group_labels = NULL,
                    subgroup_labels = c("No", "CFS", "tsfresh"),
                    fn = "tsfresh_fs_knn.pdf",
                    width = widths_in[2],
                    height = heights_in[2],
                    w_feature = T)

# - Classifier -> Dataset (dt, no scaling) -------------------------------------
eval_group_subgroup(list(list(d, m["80"], s["1"], f["1"], c["10"]),
                         list(d, m["80"], s["5"], f["1"], c[c("20", "21")]),
                         list(d, m["80"], s["1"], f["1"], c[c("30", as.character(seq(3001, 3030)))]),
                         list(d[1:2], m["80"], s["5"], f["1"], c["41"]),
                         list(d["3"], m["14"], s["5"], f["8000"], c["41"])),
                    group_name = "d_config", subgroup_name = "c_config",
                    group_label = "Dataset", subgroup_label = "Classifier",
                    value_fn = accuracy, value_label = "Accuracy",
                    ylim = c(0, 1), ybreaks = seq(0, 1, 0.1),
                    scale_fill = scale_fill_manual(values = eval_color[1:5]),
                    plot.margin = unit(c(4, 2, 1, 1.7), "mm"),
                    legend.position = c(0.1, 0.9),
                    legend.margin = margin(0, 0, 0, 0, "mm"),
                    legend.box.margin = margin(1, 1, 1, 1, "mm"),
                    legend.box.spacing = unit(0, "mm"),
                    legend.key.height = unit(2, "mm"),
                    subgroup_col = "name",
                    group_col = "did",
                    intermediate = "validate",
                    dataset = "dataset")

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# +++++++++++ ------------------------------------------------------------------
# DWT --------------------------------------------------------------------------
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
run_validate(d[2:3], m["30"], s["4"], f["1"], c[c("10", "30", as.character(seq(3001, 3030)))], force = F, parallel = T)

# - Selection -> Dataset (knn, no scaling) --------------------------------------
eval_group_subgroup(list(list(d[2:3], m["30"], s["4"], f[c("1", "3016")], c["20"])),
                    group_name = "d_config", subgroup_name = "f_config",
                    group_label = NULL, subgroup_label = "Selection",
                    value_fn = accuracy, value_label = "Accuracy (%)",
                    ylim = c(0, 110), ybreaks = seq(0, 120, 20),
                    scale_fill = scale_fill_manual(values = eval_color[1:6]),
                    plot.margin = unit(c(5, 2, 1, 1.7), "mm"),
                    legend.position = c(0, 1.01),
                    legend.margin = margin(0, 0, 0, 0, "mm"),
                    legend.box.margin = margin(1, 1, 1, 1, "mm"),
                    legend.box.spacing = unit(0, "mm"),
                    legend.key.height = unit(2, "mm"),
                    subgroup_col = "fid",
                    group_col = "name",
                    intermediate = "validate",
                    dataset = "dataset",
                    group_levels = c("Metering", "Payment"),
                    subgroup_levels = c(3002, 3004, 3008, 3016),
                    group_labels = NULL,
                    subgroup_labels = c("Best 2", "Best 4", "Best 8", "Best 16"),
                    fn = NULL, #"dwt_fs_svm.pdf",
                    width = widths_in[2],
                    height = heights_in[2],
                    w_feature = T
)

# - Selection -> Dataset (svm, no scaling) --------------------------------------
eval_group_subgroup(list(list(d[2:3], m["30"], s["4"], f[c("3002", "3004", "3008", "3016")], c["20"])),
                    group_name = "d_config", subgroup_name = "f_config",
                    group_label = NULL, subgroup_label = "Selection",
                    value_fn = accuracy, value_label = "Accuracy (%)",
                    ylim = c(0, 110), ybreaks = seq(0, 120, 20),
                    scale_fill = scale_fill_manual(values = eval_color[1:6]),
                    plot.margin = unit(c(5, 2, 1, 1.7), "mm"),
                    legend.position = c(0, 1.01),
                    legend.margin = margin(0, 0, 0, 0, "mm"),
                    legend.box.margin = margin(1, 1, 1, 1, "mm"),
                    legend.box.spacing = unit(0, "mm"),
                    legend.key.height = unit(2, "mm"),
                    subgroup_col = "fid",
                    group_col = "name",
                    intermediate = "validate",
                    dataset = "dataset",
                    group_levels = c("Metering", "Payment"),
                    subgroup_levels = c(3002, 3004, 3008, 3016),
                    group_labels = NULL,
                    subgroup_labels = c("Best 2", "Best 4", "Best 8", "Best 16"),
                    fn = "dwt_fs_svm.pdf",
                    width = widths_in[2],
                    height = heights_in[2],
                    w_feature = T
)

# - Selection -> Dataset (knn, no scaling) --------------------------------------
eval_group_subgroup(list(list(d[2:3], m["30"], s["4"], f[c("3002", "3004", "3008", "3016")], c["41"])),
                    group_name = "d_config", subgroup_name = "f_config",
                    group_label = NULL, subgroup_label = "Selection",
                    value_fn = accuracy, value_label = "Accuracy (%)",
                    ylim = c(0, 110), ybreaks = seq(0, 120, 20),
                    scale_fill = scale_fill_manual(values = eval_color[1:6]),
                    plot.margin = unit(c(5, 2, 1, 1.7), "mm"),
                    legend.position = c(0, 1.01),
                    legend.margin = margin(0, 0, 0, 0, "mm"),
                    legend.box.margin = margin(1, 1, 1, 1, "mm"),
                    legend.box.spacing = unit(0, "mm"),
                    legend.key.height = unit(2, "mm"),
                    subgroup_col = "fid",
                    group_col = "name",
                    intermediate = "validate",
                    dataset = "dataset",
                    group_levels = c("Metering", "Payment"),
                    subgroup_levels = c(3002, 3004, 3008, 3016),
                    group_labels = NULL,
                    subgroup_labels = c("Best 2", "Best 4", "Best 8", "Best 16"),
                    fn = "dwt_fs_knn.pdf",
                    width = widths_in[2],
                    height = heights_in[2],
                    w_feature = T
                    )


# - Classifier -> Dataset (dt, no scaling) -------------------------------------
eval_group_subgroup(list(list(d, m["80"], s["1"], f["1"], c["10"]),
                         list(d, m["80"], s["5"], f["1"], c[c("20", "21")]),
                         list(d, m["80"], s["1"], f["1"], c[c("30", as.character(seq(3001, 3030)))]),
                         list(d[1:2], m["80"], s["5"], f["1"], c["41"]),
                         list(d["3"], m["14"], s["5"], f["8000"], c["41"])),
                    group_name = "d_config", subgroup_name = "c_config",
                    group_label = "Dataset", subgroup_label = "Classifier",
                    value_fn = accuracy, value_label = "Accuracy",
                    ylim = c(0, 1), ybreaks = seq(0, 1, 0.1),
                    scale_fill = scale_fill_manual(values = eval_color[1:5]),
                    plot.margin = unit(c(4, 2, 1, 1.7), "mm"),
                    legend.position = c(0.1, 0.9),
                    legend.margin = margin(0, 0, 0, 0, "mm"),
                    legend.box.margin = margin(1, 1, 1, 1, "mm"),
                    legend.box.spacing = unit(0, "mm"),
                    legend.key.height = unit(2, "mm"),
                    subgroup_col = "name",
                    group_col = "did",
                    intermediate = "validate",
                    dataset = "dataset")
