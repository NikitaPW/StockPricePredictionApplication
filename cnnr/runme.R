# Check for packages
options(repos=structure(c(CRAN="http://cran.r-project.org")))

if (!require("shiny")) {
  install.packages("shiny")
  library("shiny")
}
if (!require("shinyjs")) {
  install.packages("shinyjs")
  library("shinyjs")
}
if (!require("shinydashboard")) {
  install.packages("shinydashboard")
  library("shinydashboard")
}
if (!require("tensorflow")) {
  install.packages("tensorflow")
  library("tensorflow")
}
if (!require("keras")) {
  install.packages("keras")
  library("keras")
}
if (!require("stringr")) {
  install.packages("stringr")
  library("stringr")
}
if (!require("ggplot2")) {
  install.packages("ggplot2")
  library("ggplot2")
}
if (!require("glue")) {
  install.packages("glue")
  library("glue")
}
if (!require("tfruns")) {
  install.packages("tfruns")
  library("tfruns")
}
if (!require("caret")) {
  install.packages("caret")
  library("caret")
}
if (!require("testthat")) {
  install.packages("testthat")
  library("testthat")
}

runApp("cnn-app", launch.browser = T)
