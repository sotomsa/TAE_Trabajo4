install.packages("tidyverse")
install.packages("rsample")
install.packages("Metrics")
install.packages("parallel")
install.packages("kernlab")

install.packages("devtools")
devtools::install_github("hadley/multidplyr")

install.packages("OpenImageR")
install.packages("RCurl")
install.packages("pixmap")
install.packages("glmnet")
install.packages("glmnetUtils")
install.packages("ranger")

require(devtools)
install_version("DiagrammeR", version = "0.9.0", repos = "http://cran.us.r-project.org")
require(DiagrammeR)
##
cran <- getOption("repos")
cran["dmlc"] <- "https://apache-mxnet.s3-accelerate.dualstack.amazonaws.com/R/CRAN/"
options(repos = cran)
install.packages("mxnet")