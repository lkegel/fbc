#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Util -------------------------------------------------------------------------
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
config_read_csv <- function(config_name, config_parse) {
  suppressPackageStartupMessages(require(openxlsx))
  fp <- config_get_path(config_name, "xlsx")
  stopifnot(file.exists(fp))
  
  # tbl <- read.table(fp, T, ";", check.names = F, stringsAsFactors = F)
  tbl <- read.xlsx(fp, sheet = 1, skipEmptyRows = FALSE)
  res <- list()
  for (irow in seq(nrow(tbl))) {
    res[[irow]] <- config_parse(tbl[irow, ])
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

m <- config_read_csv("fbg", a_parse)
m <- c(m, config_read_csv("tsfresh", a_parse))
m <- c(m, config_read_csv("dwt", a_parse))
m <- c(m, config_read_csv("rld", a_parse))

s <- config_read_csv("s", a_parse)

f <- config_read_csv("f", a_parse)

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
