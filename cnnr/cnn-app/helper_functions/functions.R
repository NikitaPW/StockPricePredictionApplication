form_timeseriese <- function(open, close = NULL, steps) {
  X_open <- NULL
  X_max <- NULL
  X_min <- NULL
  X_day <- NULL
  X <- NULL
  Y <- NULL
  
  len <- dim(open)[1]
  count <- 0
  
  for (i in 1:len) {
    index <- i + steps - 1
    if (index > len) {
      break
    }
    seq_open <- open[i:index, 1]
    seq_max <- open[i:index, 2]
    seq_min <- open[i:index, 3]
    seq_day <- open[i:index, 4]
    seq_y <- close[index]
    
    X_open <- rbind(X_open, seq_open)
    X_max <- rbind(X_max, seq_max)
    X_min <- rbind(X_min, seq_min)
    X_day <- rbind(X_day, seq_day)
    
    Y <- rbind(Y, seq_y)
    
    count <- count + 1
  }
  
  dim(X_open) <- c(dim(X_open)[1], dim(X_open)[2], 1)
  dim(X_max) <- c(dim(X_max)[1], dim(X_max)[2], 1)
  dim(X_min) <- c(dim(X_min)[1], dim(X_min)[2], 1)
  dim(X_day) <- c(dim(X_day)[1], dim(X_day)[2], 1)
  
  X <- cbind(X, X_open) %>%
    cbind(X_max) %>%
    cbind(X_min) %>%
    cbind(X_day)
  
  
  
  ##X <- list(input1 = X_open, input2 = X_max, input3 = X_min, input4 = X_day)
  ##Y <- list(output = Y)
  
  dim(X) <- c(count, steps, 4)
  
  return(list(X = X, Y = Y))
}

combine_data <- function(open, max, min, day) {
  result <- NULL
  result <- cbind(result, open) %>%
    cbind(max) %>%
    cbind(min) %>%
    cbind(day)
  return(result)
}

append_timeseries <- function(ts, value) {
  ts <- rbind(ts, value) # append the previously predicted value
  ts <- ts[-1, ] # shift the 1st value
}

divide_data <- function(data, tnum, ts_length, pnum = 5) {
  open <- data$Open
  max <- data$OpenMax
  min <- data$OpenMin
  day <- data$Day
  
  close <- data$Close
  size <- length(open)
  train_size <- length(open) - tnum - pnum
  test_size <- length(open) - pnum
  
  train <-
    combine_data(open[1:train_size], max[1:train_size], min[1:train_size], day[1:train_size])
  
  test <- combine_data(open[(train_size - ts_length + 2):test_size],
                       max[(train_size - ts_length + 2):test_size],
                       min[(train_size - ts_length + 2):test_size],
                       day[(train_size - ts_length + 2):test_size])
  
  predict <- combine_data(open[(test_size + 1):size],
                          max[(test_size + 1):size],
                          min[(test_size + 1):size],
                          day[(test_size + 1):size])
  
  actual <- close[1:train_size]
  return(list(
    Train = train,
    Test = test,
    Predict = predict,
    Actual = actual
  ))
}

choose_data <- function(name, path = NULL) {
  if (is.null(path)) {
    data_name <- paste("../../data", name, sep = "/")
    data_frame <- read.csv(data_name, sep = ",")
  } else{
    data_name <- paste(path, name, sep = "")
    data_frame <- read.csv(data_name, sep = ",")
  }
  
  return(data_frame)
}

get_bounds <- function(data1, data2) {
  if (min(data1) < min(data2)) {
    v_min <- min(data1)
  } else {
    v_min <- min(data2)
  }
  
  if (max(data1) > max(data2)) {
    v_max <- max(data1)
  } else {
    v_max <- max(data2)
  }
  
  return(list(Min = v_min, Max = v_max))
}

get_models_names <- function(name) {
  files <- list.files(glue::glue("models/"))
  for (file in files) {
    if (!grepl(name, file)) {
      files <- files[files != file]
    }
  }
  return(files)
}

get_data_names <- function() {
  return(list.files("../../data"))
}
