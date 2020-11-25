source("helper_functions/functions.R")

prepare_data <- function(data_frame, timeseires_length, t_num, p_num = 5){
  
  list <- divide_data(data_frame, tnum = t_num, ts_length = timeseires_length)
  train <- list$Train
  predict <- list$Predict
  actual <- list$Actual
  test <- list$Test
  
  train_list <- form_timeseriese(open = train, close = actual, steps = timeseires_length)
  
  X_train <- train_list$X
  Y_train <- train_list$Y
  
  test_list <- form_timeseriese(open = test, steps = timeseires_length)
  
  X_test <- test_list$X
  
  return(list(X_train = X_train, Y_train = Y_train, X_test = X_test, Test = test, Predict = predict))
}

real_prediction <- function(model,last_ts,pnum = 5){
  
  temp_ts <- last_ts
  predictions <- vector()
  for (i in 1:pnum){
      dim(temp_ts) <- c(1,length(temp_ts),1)# change ts dimensionality to fit the model
      last_predicted <- model_prediction(model,temp_ts)
      dim(temp_ts) <- c(dim(temp_ts)[2])# change it's dimensionality back to normal
      temp_ts <- append_timeseries(temp_ts, last_predicted)
      predictions <- c(predictions, last_predicted) # append to already predicted values
  }
  
  return(predictions)
}
