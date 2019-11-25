
tsfresh_convert <- function(d_configs, m_configs, names) {
  for (d_config in d_configs) {
    for (m_config in m_configs) {
      for (name in names) {
        fn <- paste0(name, "-tsfresh")
        fp <- util_get_filepath(d_config, file_name = fn, ext = "csv")
        dt <- fread(fp)
        repr <- as.matrix(dt[, -1, with = F])
        intermediate_save(d_config, repr, paste0("represent-", name), m_config)     
      }
    }
  }
}
