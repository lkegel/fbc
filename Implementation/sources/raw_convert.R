raw_convert <- function(d_configs) {
  mname <- list(mname = "raw")
  cname <- list(cname = "knn")
  for (d_config in d_configs) {
    fn <- intermediate_file_name(mname, cname)
    fp <- util_get_filepath(d_config, fn, "classify", "csv")
    dt <- fread(fp)
    
    fp <- util_get_filepath(d_config, "dataset", ext = "csv")
    y <- read.table(fp, header = T, sep = ";")[, "Code"]
    pred <- as.factor(y[dt$name + 1])
    intermediate_save(d_config, pred, "classify", mname, cname)
  }
}