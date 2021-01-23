library("tensorflow")
library("keras")
library("stringr")
library("testthat")
source("../helper_functions/functions.R")
source("../helper_functions/model.R")
source("../helper_functions/execute.R")

model <- NULL
data_frame <- NULL
data <- NULL
ts_length <- 8
features <- 4

test_that("data upload is working", {
  # take known data from existing folder
  name <- "test_data.csv"
  data_frame <<- choose_data(name, path = "./test_train_data/")
  expect_false(is.null(dim(data_frame)))
})

test_that("data division is working", {
  division <- divide_data(data_frame, 5, 5)
  
  expect_false(is.null(division))
  expect_equal(length(division), 4)
  expect_equal(length(division$Test[, 1]), 5 + 5 - 1)
  expect_equal(length(division$Predict[, 1]), 5)
  
})

test_that("data preperation is working", {
  data <<- prepare_data(data_frame, ts_length, 5)
  expect_false(is.null(data))
  expect_equal(length(data), 6)
  expect_equal(length(data$Test[, 1]), ts_length + 5 - 1)
  expect_equal(length(data$Predict[, 1]), 5)
})

test_that("model initialization", {
  model <<- model_initialization(ts_length, features)
  expect_false(is.null(model))
})

test_that("check model traning", {
  X_train <- data$X_train
  Y_train <- data$Y_train
  
  result <- model_training(model, X_train, Y_train, ep = 10)
  expect_false(is.null(result))
})

test_that("check model testing", {
  X_test <- data$X_test
  result <- model_prediction(model, X_test)
  expect_false(is.null(result))
})

test_that("check timeseries append", {
  series <- c(1, 2, 3)
  new_series <- append_timeseries(series, 4)
  expect_false(isTRUE(all.equal(series, new_series)))
})

test_that("check model real prediction", {
  last_ts <- data$X_test[dim(data$X_test)[1], , ]
  known_open <- data$Predict[1, ]
  last_ts <- append_timeseries(last_ts, known_open)
  result <- real_prediction(model, last_ts)
  expect_false(is.null(result))
})
