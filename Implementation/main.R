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

# Eval fbr per d and c
mnames <- list(list(mname = "fbr"))
cnames <- list(list(cname = "dt"), list(cname = "svm"), list(cname = "gbm"))
eval_group_subgroup_agg(d, mnames, cnames,
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
mnames <- list(list(mname = "fbr"), list(mname = "tsfresh"))
cnames <- list(list(cname = "knn"))#, list(cname = "svm"), list(cname = "gbm"))
eval_group_subgroup_agg(d, mnames, cnames,
                        group_name = "d_config", subgroup_name = "mname",
                        group_label = "Dataset", subgroup_label = "Method",
                        value_fn = accuracy_agg, value_label = "Accuracy",
                        ylim = c(0, 1), ybreaks = seq(0, 1, 0.1),
                        scale_fill = scale_fill_manual(values = eval_color[1:3]),
                        plot.margin = unit(c(4, 2, 1, 1.7), "mm"),
                        legend.position = c(0.1, 0.9),
                        legend.margin = margin(0, 0, 0, 0, "mm"),
                        legend.box.margin = margin(1, 1, 1, 1, "mm"),
                        legend.box.spacing = unit(0, "mm"),
                        legend.key.height = unit(2, "mm"),
                        subgroup_col = "mname",
                        group_col = "did")

# Eval lazy
mnames <- list(list(mname = "raw"), list(mname = "rld"), list(mname = "dwt"), list(mname = "fbr"), list(mname = "tsfresh"))
cnames <- list(list(cname = "knn"))
eval_group_subgroup_agg(d, mnames, cnames,
                        group_name = "d_config", subgroup_name = "mname",
                        group_label = "Dataset", subgroup_label = "Method",
                        value_fn = accuracy_agg, value_label = "Accuracy",
                        ylim = c(0, 1), ybreaks = seq(0, 1, 0.1),
                        scale_fill = scale_fill_manual(values = eval_color[1:5]),
                        plot.margin = unit(c(4, 2, 1, 1.7), "mm"),
                        legend.position = c(0.1, 0.9),
                        legend.margin = margin(0, 0, 0, 0, "mm"),
                        legend.box.margin = margin(1, 1, 1, 1, "mm"),
                        legend.box.spacing = unit(0, "mm"),
                        legend.key.height = unit(2, "mm"),
                        subgroup_col = "mname",
                        group_col = "did")

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# +++++++++++ ------------------------------------------------------------------
# FBR --------------------------------------------------------------------------
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# - Feature Set -> Dataset (dt, no scale, no select) ---------------------------
eval_group_subgroup(d, m[c("13", "14", "15")],  s["1"], f["1"], c["20"],
                    group_name = "d_config", subgroup_name = "m_config",
                    group_label = "Dataset", subgroup_label = "Method",
                    value_fn = accuracy, value_label = "Accuracy",
                    ylim = c(0, 1), ybreaks = seq(0, 1, 0.1),
                    scale_fill = scale_fill_manual(values = eval_color[1:5]),
                    plot.margin = unit(c(4, 2, 1, 1.7), "mm"),
                    legend.position = c(0.1, 0.9),
                    legend.margin = margin(0, 0, 0, 0, "mm"),
                    legend.box.margin = margin(1, 1, 1, 1, "mm"),
                    legend.box.spacing = unit(0, "mm"),
                    legend.key.height = unit(2, "mm"),
                    subgroup_col = "id",
                    group_col = "did",
                    intermediate = "validate",
                    dataset = "dataset")

# - Scale -> Dataset (svm, no select) ------------------------------------------
eval_group_subgroup(d, m["14"], s[c("1", "2", "3", "5")], f["1"], c["41"],
                    group_name = "d_config", subgroup_name = "s_config",
                    group_label = "Dataset", subgroup_label = "Scale",
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

# - Selection -> Dataset (dt, no scaling) --------------------------------------
eval_group_subgroup(d, m["14"], s["1"], f[c("1", "1399", "8000")], c["41"],
                    group_name = "d_config", subgroup_name = "f_config",
                    group_label = "Dataset", subgroup_label = "Selection",
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
eval_group_subgroup(list(list(d, m["80"], s[c("1", "2", "3", "5")], f["1"], c["41"])),
                    group_name = "d_config", subgroup_name = "s_config",
                    group_label = "Dataset", subgroup_label = "Scale",
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

# - Selection -> Dataset (dt, no scaling) --------------------------------------
eval_group_subgroup(list(list(d, m["80"], s["5"], f[c("1", "1399", "8000")], c["41"])),
                    group_name = "d_config", subgroup_name = "f_config",
                    group_label = "Dataset", subgroup_label = "Selection",
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
# - Selection -> Dataset (dt, no scaling) --------------------------------------
eval_group_subgroup(list(list(d, m["30"], s["4"], f[c("3002", "3004", "3008", "3016")], c["41"])),
                    group_name = "d_config", subgroup_name = "f_config",
                    group_label = "Dataset", subgroup_label = "Selection",
                    value_fn = accuracy, value_label = "Accuracy",
                    ylim = c(0, 1), ybreaks = seq(0, 1, 0.1),
                    scale_fill = scale_fill_manual(values = eval_color[1:5]),
                    plot.margin = unit(c(4, 2, 1, 1.7), "mm"),
                    legend.position = c(0.1, 0.9),
                    legend.margin = margin(0, 0, 0, 0, "mm"),
                    legend.box.margin = margin(1, 1, 1, 1, "mm"),
                    legend.box.spacing = unit(0, "mm"),
                    legend.key.height = unit(2, "mm"),
                    subgroup_col = "fid",
                    group_col = "did",
                    intermediate = "validate",
                    dataset = "dataset")

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
