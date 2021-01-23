prepare_data <-
  function(data_frame,
           timeseires_length,
           t_num,
           p_num = 5) {
    list <-
      divide_data(data_frame,
                  tnum = t_num,
                  ts_length = timeseires_length,
                  pnum = p_num)
    train <- list$Train
    predict <- list$Predict
    actual <- list$Actual
    test <- list$Test
    
    train_list <-
      form_timeseriese(open = train,
                       close = actual,
                       steps = timeseires_length)
    
    X_train <- train_list$X
    Y_train <- train_list$Y
    
    test_list <-
      form_timeseriese(open = test, steps = timeseires_length)
    
    X_test <- test_list$X
    
    return(
      list(
        X_train = X_train,
        Y_train = Y_train,
        X_test = X_test,
        Train = train,
        Test = test,
        Predict = predict
      )
    )
  }

real_prediction <- function(model, last_ts, pnum = 5) {
  temp_ts <- last_ts
  predictions <- NULL
  for (i in 1:pnum) {
    dim(temp_ts) <-
      c(1, dim(temp_ts))# change ts dimensionality to fit the model
    last_predicted <- model_prediction(model, temp_ts)
    dim(temp_ts) <-
      c(dim(temp_ts)[2], 4)# change it's dimensionality back to normal
    last_predicted <-
      add_meta_data(temp_ts[dim(temp_ts)[1],], last_predicted)
    temp_ts <- append_timeseries(temp_ts, last_predicted)
    predictions <-
      rbind(predictions, last_predicted) # append to already predicted values
  }
  
  
  dim(predictions) <- c(pnum, dim(last_ts)[2])
  return(predictions)
}

add_meta_data <- function(ts, value) {
  if (ts[2] < value) {
    max <- value
  } else{
    max <- ts[2]
  }
  
  if (ts[3] > value) {
    min <- value
  } else
  {
    min <- ts[3]
  }
  
  if (ts[4] < 5) {
    #add next day
    day <- ts[4] + 1
  } else {
    day <- 1
  }
  
  result <- NULL
  result <- cbind(result, value) %>%
    cbind(max) %>%
    cbind(min) %>%
    cbind(day)
  
  return(result)
}

comp_accuracy <- function(actual, predicted) {
  every <- sqrt(((actual - predicted) / actual) ^ 2) * 100
  total <- sum(every) / length(every)
  print("By point accuracy:")
  print(every)
  print("Total accuracy:")
  print(total)
}
