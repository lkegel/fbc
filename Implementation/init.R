#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Library ----------------------------------------------------------------------
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# .libPaths("C:/Users/Lars/Documents/R/win-library/3.4")
# .libPaths()
suppressPackageStartupMessages(library(classrepr))
suppressPackageStartupMessages(library(stringr))
suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(idxrepr))
suppressPackageStartupMessages(library(R.utils))
suppressPackageStartupMessages(library(TST))
suppressPackageStartupMessages(library(caret))
suppressPackageStartupMessages(library(rpart))
suppressPackageStartupMessages(library(e1071))
suppressPackageStartupMessages(library(xgboost))

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Sources ----------------------------------------------------------------------
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
sourceDirectory(file.path("Implementation", "sources"), modifiedOnly = F)

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Configurations ---------------------------------------------------------------
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
sourceDirectory(file.path("Implementation", "configs"), modifiedOnly = F)