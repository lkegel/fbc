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
run_represent(d, m[c("10", "11", "12", "20", "30")], force = F)
# rld and dwt are not scaled or imputed
run_scale(d, m[c("10", "11", "12", "80")], s[c("1", "2", "3", "5")], force = F)
run_scale(d, m[c("20", "30")], s["4"])

run_feature_selection(d, m[c("10", "11", "12", "80")], s[c("1", "2", "3", "5")],
                      f[c("1", "1010", "1020", "1030", "1037", "1040", "1050", "1060", "1070", "1073", "1080", "1090", "8000")], force = F)
run_feature_selection(d, m["20"], s["4"], f["1"])
run_feature_selection(d, m["30"], s["4"], f[c("3005", "3010", "3020", "3030", "3037", "3073")])

eval_feature_selection(d["1"], m["11"], s[c("2", "3", "5")],
                       f["1010"])


#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# +++++++++++ ------------------------------------------------------------------
# Calibration Subset -----------------------------------------------------------
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
run_method(d, m)
# 80 - is done separately
run_represent(d, m[c("10", "11", "12", "20", "30")], force = F)
# rld and dwt are not scaled or imputed
run_scale(d, m[c("10", "11", "12", "80")], s[c("1", "2", "3", "5")], force = F)
run_scale(d, m[c("20", "30")], s["4"])

run_feature_selection(d, m["11"], s["1"], f["1"], force = F)
run_feature_selection(d, m[c("12", "80")], s[c("1", "2")], f[c("1", "1010", "8000")], force = F)
run_feature_selection(d, m["20"], s["4"], f["1"])
run_feature_selection(d, m["30"], s["4"], f["3010"])

run_feature_selection(d["2"], m["10"], s[c("2", "3")],
                      f[c("1010", "1020")], force = F, parallel = T)

run_validate(d["3"], m[c("11", "12")], s["1"], f["1"], c["10"], force = F)
run_validate(d["3"], m["12"], s["1"], f["1"], c["20"])
run_validate(d["3"], m["12"], s["1"], f["1"], c["30"])

run_best(d["3"], m[c("11", "12")], c["10"], s["1"], f["1"])

eval_validate(d["3"], m["12"], s["1"], f["1"], c["10"])



# + Eager ----------------------------------------------------------------------
# ++ FBR -----------------------------------------------------------------------
# +++ Scaling ------------------------------------------------------------------

run_represent(d[c("1", "3")], m["12"], parallel = T, force = T)
run_scale(d[c("1", "3")], m[c("12")], s[c("1", "2", "3")])
run_feature_selection(d[c("1", "3")], m[c("12")], s[c("1", "2", "3")], f["1"])
run_classify(d[c("1", "3")], m[c("12")], s[c("1", "2", "3")], f["1"], c["20"])
eval_group_subgroup(d[c("1", "3")], m[c("12")], s[c("1", "2", "3")], f["1"],
                    c["20"],
                    group_name = "d_config", subgroup_name = "s_config",
                    group_label = "Dataset", subgroup_label = "Scaling",
                    value_fn = accuracy, value_label = "Accuracy",
                    ylim = c(0, 1), ybreaks = seq(0, 1, 0.1),
                    scale_fill = scale_fill_manual(values = eval_color[1:3]),
                    plot.margin = unit(c(4, 2, 1, 1.7), "mm"),
                    legend.position = c(0.1, 0.9),
                    legend.margin = margin(0, 0, 0, 0, "mm"),
                    legend.box.margin = margin(1, 1, 1, 1, "mm"),
                    legend.box.spacing = unit(0, "mm"),
                    legend.key.height = unit(2, "mm"))

# +++ Feature Selection --------------------------------------------------------
run_method(d[c("1", "3")], m["12"])
run_represent(d[c("1", "3")], m["12"])
run_scale(d[c("1", "3")], m[c("12")], s[c("1")])
run_feature_selection(d[c("1", "3")], m[c("12")], s[c("1")], f[c("1", "1010", "1050", "1090", "8000")])
run_classify(d[c("1", "3")], m[c("12")], s["1"], f[c("1", "1010", "1050", "1090", "8000")], c["20"])
eval_group_subgroup(d[c("1", "3")], m[c("12")], s["1"],
                    f[c("1", "1010", "1050", "1090", "8000")], c["20"],
                    group_name = "d_config", subgroup_name = "f_config",
                    group_label = "Dataset", subgroup_label = "Feature Selection",
                    value_fn = accuracy, value_label = "Accuracy",
                    ylim = c(0, 1), ybreaks = seq(0, 1, 0.1),
                    scale_fill = scale_fill_manual(values = eval_color[1:4]),
                    plot.margin = unit(c(4, 2, 1, 1.7), "mm"),
                    legend.position = c(0.1, 0.9),
                    legend.margin = margin(0, 0, 0, 0, "mm"),
                    legend.box.margin = margin(1, 1, 1, 1, "mm"),
                    legend.box.spacing = unit(0, "mm"),
                    legend.key.height = unit(2, "mm"))

# +++ Method -------------------------------------------------------------------
run_method(d[c("1", "3")], m[c("10", "11", "12")])
run_represent(d[c("1", "3")], m[c("10", "11", "12")], force = F, parallel = T)
run_scale(d[c("1", "3")], m[c("10", "11", "12")], s[c("1")], force = F)
run_feature_selection(d[c("1", "3")], m[c("10", "11", "12")], s[c("1")], f["1"], force = F)
run_classify(d[c("1", "3")], m[c("10", "11", "12")], s["1"], f["1"], c["20"], force = F)

eval_group_subgroup(d[c("1", "3")], m[c("10", "11", "12")], s["1"], f["1"], c["20"],
                    group_name = "d_config", subgroup_name = "m_config",
                    group_label = "Dataset", subgroup_label = "Feature Selection",
                    value_fn = accuracy, value_label = "Accuracy",
                    ylim = c(0, 1), ybreaks = seq(0, 1, 0.1),
                    scale_fill = scale_fill_manual(values = eval_color[1:4]),
                    plot.margin = unit(c(4, 2, 1, 1.7), "mm"),
                    legend.position = c(0.1, 0.9),
                    legend.margin = margin(0, 0, 0, 0, "mm"),
                    legend.box.margin = margin(1, 1, 1, 1, "mm"),
                    legend.box.spacing = unit(0, "mm"),
                    legend.key.height = unit(2, "mm"))

# +++ Classifier ---------------------------------------------------------------
run_method(d[c("1", "3")], m["11"])
run_represent(d[c("1", "3")], m["11"], force = F, parallel = T)
run_scale(d[c("1", "3")], m["11"], s[c("1")], force = F)
run_feature_selection(d[c("1", "3")], m["11"], s[c("1")], f["1"], force = F)
c_grid <- paste0("30", str_pad(as.character(seq(30)), 2, pad = "0"))
run_classify(d[c("1", "3")], m["11"], s["1"], f["1"], c[c("10", "20", "21", "22", "23", "30", c_grid)], force = F)

eval_group_subgroup(d[c("1", "3")], m["11"], s["1"], f["1"], c[c("10", "20", "30", c_grid)],
                    group_name = "d_config", subgroup_name = "c_config",
                    group_label = "Dataset", subgroup_label = "Feature Selection",
                    value_fn = accuracy, value_label = "Accuracy",
                    ylim = c(0, 1), ybreaks = seq(0, 1, 0.1),
                    scale_fill = scale_fill_manual(values = eval_color[1:4]),
                    plot.margin = unit(c(4, 2, 1, 1.7), "mm"),
                    legend.position = c(0.1, 0.9),
                    legend.margin = margin(0, 0, 0, 0, "mm"),
                    legend.box.margin = margin(1, 1, 1, 1, "mm"),
                    legend.box.spacing = unit(0, "mm"),
                    legend.key.height = unit(2, "mm"))

# ++ DWT -----------------------------------------------------------------------
# +++ Feature Selection --------------------------------------------------------
run_method(d[c("1", "3")], m["30"])
run_represent(d[c("1", "3")], m["30"], force = F, parallel = T)
run_scale(d[c("1", "3")], m[c("30")], s[c("4")], force = F)
fs <- f[c("3005", "3010", "3020", "3030", "3037", "3073")] 
run_feature_selection(d[c("1", "3")], m["30"], s["4"], fs, force = F)
run_classify(d[c("1", "3")], m[c("30")], s["4"], fs, c["20"])
eval_group_subgroup(d[c("1", "3")], m[c("30")], s["4"],
                    fs, c["20"],
                    group_name = "d_config", subgroup_name = "f_config",
                    group_label = "Dataset", subgroup_label = "Feature Selection",
                    value_fn = accuracy, value_label = "Accuracy",
                    ylim = c(0, 1), ybreaks = seq(0, 1, 0.1),
                    scale_fill = scale_fill_manual(values = eval_color[1:4]),
                    plot.margin = unit(c(4, 2, 1, 1.7), "mm"),
                    legend.position = c(0.1, 0.9),
                    legend.margin = margin(0, 0, 0, 0, "mm"),
                    legend.box.margin = margin(1, 1, 1, 1, "mm"),
                    legend.box.spacing = unit(0, "mm"),
                    legend.key.height = unit(2, "mm"))
# +++ Classifier ---------------------------------------------------------------
run_method(d[c("1", "3")], m["30"])
run_represent(d[c("1", "3")], m["30"], force = F, parallel = T)
run_scale(d[c("1", "3")], m["30"], s[c("4")], force = F)
run_feature_selection(d[c("1", "3")], m["30"], s["4"], fs, force = F)
c_grid <- paste0("30", str_pad(as.character(seq(30)), 2, pad = "0"))
run_classify(d["1"], m["30"], s["4"], f["3010"], c[c("10", "20", "21", "22", "23", "30", c_grid)], force = F)
run_classify(d["3"], m["30"], s["4"], f["3073"], c[c("10", "20", "21", "22", "23", "30", c_grid)], force = F)
eval_group_subgroup(d[c("1", "3")], m["30"], s["4"], f[c("3010", "3073")], c[c("10", "20", "21", "22", "23", "30", c_grid)],
                    group_name = "d_config", subgroup_name = "c_config",
                    group_label = "Dataset", subgroup_label = "Feature Selection",
                    value_fn = accuracy, value_label = "Accuracy",
                    ylim = c(0, 1), ybreaks = seq(0, 1, 0.1),
                    scale_fill = scale_fill_manual(values = eval_color[1:4]),
                    plot.margin = unit(c(4, 2, 1, 1.7), "mm"),
                    legend.position = c(0.1, 0.9),
                    legend.margin = margin(0, 0, 0, 0, "mm"),
                    legend.box.margin = margin(1, 1, 1, 1, "mm"),
                    legend.box.spacing = unit(0, "mm"),
                    legend.key.height = unit(2, "mm"))

# + Lazy -----------------------------------------------------------------------
# ++ FBR -----------------------------------------------------------------------
# +++ Scaling ------------------------------------------------------------------
run_method(d[c("1", "3")], m["12"], force = F)
run_represent(d[c("1", "3")], m["12"], parallel = T, force = F)
run_scale(d[c("1", "3")], m[c("12")], s[c("1", "2", "3")], force = F)
run_feature_selection(d[c("1", "3")], m[c("12")], s[c("1", "2", "3")], f["1"], force = F)
run_classify(d[c("1", "3")], m[c("12")], s[c("1", "2", "3")], f["1"], c["41"], force = F)
eval_group_subgroup(d[c("1", "3")], m[c("12")], s[c("1", "2", "3")], f["1"],
                    c["41"],
                    group_name = "d_config", subgroup_name = "s_config",
                    group_label = "Dataset", subgroup_label = "Scaling",
                    value_fn = accuracy, value_label = "Accuracy",
                    ylim = c(0, 1), ybreaks = seq(0, 1, 0.1),
                    scale_fill = scale_fill_manual(values = eval_color[1:3]),
                    plot.margin = unit(c(4, 2, 1, 1.7), "mm"),
                    legend.position = c(0.1, 0.9),
                    legend.margin = margin(0, 0, 0, 0, "mm"),
                    legend.box.margin = margin(1, 1, 1, 1, "mm"),
                    legend.box.spacing = unit(0, "mm"),
                    legend.key.height = unit(2, "mm"))

# +++ Feature Selection --------------------------------------------------------
run_method(d[c("1", "3")], m["12"])
run_represent(d[c("1", "3")], m["12"])
run_scale(d[c("1", "3")], m[c("12")], s["2"])
run_feature_selection(d[c("1", "3")], m[c("12")], s["2"], f[c("1", "1010", "1050", "1090", "8000")], force = F)
run_classify(d[c("1", "3")], m[c("12")], s["2"], f[c("1", "1010", "1050", "1090", "8000")], c["41"])
eval_group_subgroup(d[c("1", "3")], m[c("12")], s["2"],
                    f[c("1", "1010", "1050", "1090", "8000")], c["41"],
                    group_name = "d_config", subgroup_name = "f_config",
                    group_label = "Dataset", subgroup_label = "Feature Selection",
                    value_fn = accuracy, value_label = "Accuracy",
                    ylim = c(0, 1), ybreaks = seq(0, 1, 0.1),
                    scale_fill = scale_fill_manual(values = eval_color[1:4]),
                    plot.margin = unit(c(4, 2, 1, 1.7), "mm"),
                    legend.position = c(0.1, 0.9),
                    legend.margin = margin(0, 0, 0, 0, "mm"),
                    legend.box.margin = margin(1, 1, 1, 1, "mm"),
                    legend.box.spacing = unit(0, "mm"),
                    legend.key.height = unit(2, "mm"))

# +++ Method -------------------------------------------------------------------
run_method(d[c("1", "3")], m[c("10", "11", "12")])
run_represent(d[c("1", "3")], m[c("10", "11", "12")], force = F, parallel = T)
run_scale(d[c("1", "3")], m[c("10", "11", "12")], s[c("2")], force = F)
run_feature_selection(d["1"], m[c("10", "11", "12")], s[c("2")], f["1050"], force = F)
run_feature_selection(d["3"], m[c("10", "11", "12")], s[c("2")], f["1"], force = F)
run_classify(d["1"], m[c("10", "11", "12")], s["2"], f["1050"], c["41"], force = F)
run_classify(d["3"], m[c("10", "11", "12")], s["2"], f["1"], c["41"], force = F)

eval_group_subgroup(d[c("1", "3")], m[c("10", "11", "12")], s["2"], f[c("1", "1050")], c["41"],
                    group_name = "d_config", subgroup_name = "m_config",
                    group_label = "Dataset", subgroup_label = "Feature Selection",
                    value_fn = accuracy, value_label = "Accuracy",
                    ylim = c(0, 1), ybreaks = seq(0, 1, 0.1),
                    scale_fill = scale_fill_manual(values = eval_color[1:4]),
                    plot.margin = unit(c(4, 2, 1, 1.7), "mm"),
                    legend.position = c(0.1, 0.9),
                    legend.margin = margin(0, 0, 0, 0, "mm"),
                    legend.box.margin = margin(1, 1, 1, 1, "mm"),
                    legend.box.spacing = unit(0, "mm"),
                    legend.key.height = unit(2, "mm"),
                    subgroup_col = "mid")



#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Methods ----------------------------------------------------------------------
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# fbg = 10, rld = 20, dwt = 30, tsfresh = 80
run_method(d, m)

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Represent --------------------------------------------------------------------
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
run_represent(d["3"], m[c("10", "12", "20", "30")], parallel = T, force = F)
# (slow) run_represent(d[c("3")], m[c("80")], parallel = T)
tsfresh_convert(d[1:3], m["80"], c("dataset", "queryset"))
# run_represent(d["11"], m["12"], parallel = T, force = T)

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Scale ------------------------------------------------------------------------
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
run_scale(d[c("3")], m[c("10")], s)
run_scale(d[c("3")], m[c("12")], s[1:3])
run_scale(d[c("3")], m[c("20")], s["4"])
run_scale(d[c("3")], m[c("30")], s["4"])
run_scale(d[c("3")], m[c("80")], s)

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Feature Selection ------------------------------------------------------------
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++



run_feature_selection(d["3"],    m["12"],    s[1:3], f["1"])
run_feature_selection(d[c("3")], m[c("10")], s, f[c("1010")])
run_feature_selection(d[c("3")], m[c("10")], s[c("1")], f[c("1", "1010", "8000")])
run_feature_selection(d[c("3")], m[c("10")], s, f[c("1", "1010", "8000")])

run_feature_selection(d[c("3")], m[c("20")], s["4"], f["1"])

run_feature_selection(d[c("3")], m[c("30")], s["4"],
                      f[c("1", "3005", "3010", "3020", "3030")], force = F)

run_feature_selection(d[c("3")], m[c("30")], s[c("1")], f[c("3010")])
run_feature_selection(d[c("3")], m[c("80")], s[1:3], f[c("1", "1010", "8000")])

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Classify ---------------------------------------------------------------------
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# DT
run_classify(d[c("3")], m[c("10")], s, f[c("1010")], c[c("10")])
run_classify(d[c("3")], m[c("10", "80")], s, f[c("1", "1010", "8000")],
             c[c("10")], force = F)
# SVM
run_classify(d[c("3")], m["10"], s, f[c("1", "1010", "8000")],
             c[c("20")], force = F)
run_classify(d[c("3")], m["10"], s, f[c("1", "1010", "8000")],
             c[c("20")], force = F)
run_classify(d[c("3")], m["80"], s[c("1", "2")], f[c("1", "1010", "8000")],
             c[c("20")], force = F)

# GBM
run_classify(d[c("3")], m[c("10")], s[1:3], f[c("1", "1010", "8000")], c["30"])
run_classify(d[c("3")], m["80"], s[1:3], f[c("1", "1010", "8000")], c["30"])

run_classify(d[c("3")], m["80"], s[1:3], f["1010"], c["30"])

# kNN
run_classify(d[c("3")], m[c("10", "80")], s, f[c("1", "1010", "8000")],
             c[c("41")], force = F)
run_classify(d[c("3")], m["20"], s["4"], f["1"], c[c("41")], force = T, parallel = T)
run_classify(d[c("3")], m["30"], s["4"], f[c("3005", "3010", "3020", "3030")],
             c[c("10", "20", "41")], force = F)



#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Eval -------------------------------------------------------------------------
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
eval_accuracy(d[c("3")], m[c("10")], s, f[c("1010")], c[c("10")])
eval_accuracy(d[c("3")], m[c("10")], s, f[c("1", "1010", "8000")], c[c("20")])
eval_accuracy(d[c("3")], m[c("10")], s["1"], f[c("1", "1010", "8000")], c[c("10")])
eval_accuracy(d[c("3")], m[c("10")], s, f[c("1", "1010", "8000")], c[c("41")])
eval_accuracy(d[c("3")], m[c("10")], s[1:3], f[c("1", "1010", "8000")], c["30"])


eval_accuracy(d[c("3")], m[c("20")], s["4"], f["1"], c[c("41")])
eval_accuracy(d[c("3")], m[c("30")], s["4"],
              f[c("3005", "3010", "3020", "3030")], c[c("10", "20", "41")])

eval_accuracy(d[c("3")], m[c("80")], s["2"], f[c("1", "1010", "8000")], c[c("20")])
eval_accuracy(d[c("3")], m[c("80")], s[1:3], f[c("1", "1010", "8000")], c[c("30")])
eval_accuracy(d[c("3")], m[c("80")], s, f[c("1", "1010", "8000")], c[c("41")])


eval_group_subgroup(d[c("3")], m[c("10")], s[1:3], f[c("1010")], c[c("10")],
                    group_name = "d_config", subgroup_name = "s_config",
                    group_label = "Dataset", subgroup_label = "Scaling",
                    value_fn = accuracy, value_label = "Accuracy",
                    ylim = c(0, 1), ybreaks = seq(0, 1, 0.1),
                    scale_fill = scale_fill_manual(values = eval_color[1:3]),
                    plot.margin = unit(c(4, 2, 1, 1.7), "mm"),
                    legend.position = c(0.1, 1.07),
                    legend.margin = margin(0, 0, 0, 0, "mm"),
                    legend.box.margin = margin(-1, 0, 0, 0, "mm"),
                    legend.box.spacing = unit(0, "mm"),
                    legend.key.height = unit(1, "mm"))
