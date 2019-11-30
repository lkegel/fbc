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
run_feature_selection(d, m["30"], s["4"], f[c("3005", "3010", "3020", "3030", "3037", "3073")], force = F, parallel = T)

eval_feature_selection(d["1"], m["11"], s[c("2", "3", "5")],
                       f["1010"])

run_validate(d, m[c("13", "14", "15", "80")], s[c("1", "2", "3", "5")], f[c("1", "1399", "8000")], c[c("10", "20", "30")], force = F, parallel = F)
run_validate(d, m[c("13", "14", "15", "80")], s[c("1", "2", "3", "5")], f[c("1", "1399", "8000")], c[as.character(seq(3001, 3030))], force = F, parallel = F)
run_validate(d, m[c("13", "14", "15", "80")], s[c("1", "2", "3", "5")], f[c("1", "1399", "8000")], c["41"], force = F, parallel = F)
run_validate(d, m["20"], s["4"], f["1"], c["41"], force = F, parallel = T)
eval_validate(d["1"], m[c("13", "14", "15", "80")], s[c("1", "2", "3", "5")], f[c("1", "1399", "8000")], c[c("10", "20", "30")])


# Run best (per Dataset, Method, Classifer)
run_best(d["1"], m[c("13", "14", "15")], s[c("1", "2", "3", "5")], f[c("1", "1399", "8000")], c["10"])
run_best(d["1"], m[c("13", "14", "15")], s[c("1", "2", "3", "5")], f[c("1", "1399", "8000")], c["20"])
run_best(d["1"], m[c("13", "14", "15")], s[c("1", "2", "3", "5")], f[c("1", "1399", "8000")], c["30"])
run_best(d["1"], m["80"], s[c("1", "2", "3", "5")], f[c("1", "1399", "8000")], c["10"])
run_best(d["1"], m["80"], s[c("1", "2", "3", "5")], f[c("1", "1399", "8000")], c["20"])
run_best(d["1"], m["80"], s[c("1", "2", "3", "5")], f[c("1", "1399", "8000")], c["30"])

# Run classify
run_classify(d["1"], m[c("13", "14", "15")], s[c("1", "2", "3", "5")], f[c("1", "1399", "8000")], c["10"])
run_classify(d["1"], m[c("13", "14", "15")], s[c("1", "2", "3", "5")], f[c("1", "1399", "8000")], c["20"])
run_classify(d["1"], m[c("13", "14", "15")], s[c("1", "2", "3", "5")], f[c("1", "1399", "8000")], c["30"])
run_classify(d,      m["20"],                s["4"],                   f["1"],                    c["41"], force = F, parallel = T)
run_classify(d["1"], m["80"], s[c("1", "2", "3", "5")], f[c("1", "1399", "8000")], c["10"])
run_classify(d["1"], m["80"], s[c("1", "2", "3", "5")], f[c("1", "1399", "8000")], c["20"])
run_classify(d["1"], m["80"], s[c("1", "2", "3", "5")], f[c("1", "1399", "8000")], c["30"])

# Eval eager/fbr
mnames <- list(list(mname = "fbr"))
cnames <- list(list(cname = "dt"), list(cname = "svm"), list(cname = "gbm"))
eval_group_subgroup_agg(d["1"], mnames, cnames,
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
                    subgroup_col = "cname")

# Eval lazy/rld
mnames <- list(list(mname = "rld"))
cnames <- list(list(cname = "knn"))
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
                        subgroup_col = "cname")



# Test ----
library(tictoc)
st <- tic()

toc(st)
