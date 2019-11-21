#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Util -------------------------------------------------------------------------
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
config_read_csv <- function(config_name, config_parse) {
  suppressPackageStartupMessages(require(openxlsx))
  fp <- config_get_path(config_name, "xlsx")
  stopifnot(file.exists(fp))
  
  # tbl <- read.table(fp, T, ";", check.names = F, stringsAsFactors = F)
  wb <- openxlsx::loadWorkbook(fp)
  res <- list()
  for (wb_name in names(wb)) {
    tbl <- read.xlsx(fp, sheet = wb_name, skipEmptyRows = FALSE)  
    for (irow in seq(nrow(tbl))) {
      res <- c(res, list(as.list(tbl[irow, ])))
    }
  }
  names(res) <- as.character(unlist(lapply(res, function(x) x[[1]])))
  
  return(res)
}

config_get_path <- function(config_name, ext = "csv") {
  path <- file.path("Implementation", "configs", paste0(config_name, ".", ext))
  
  return(path)
}

a_parse <- function(row) {
  as.list(row)
}

d <- config_read_csv("d", a_parse)

m <- config_read_csv("m", a_parse)

s <- config_read_csv("s", a_parse)

f <- config_read_csv("f", a_parse)

c <- config_read_csv("c", a_parse)
# rt <- config_read_csv("rt", a_parse)
# 
# d <- config_read_csv("d", a_parse)
# 
# ct <- config_read_csv("ct", a_parse)
# 
# v <- config_read_csv("v", a_parse)
# 
# g <- config_read_csv("g", a_parse)
# 
# f <- config_read_csv("ft", a_parse)
