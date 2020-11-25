form_timeseriese <- function(open, close = NULL, steps) {
  X <- matrix(ncol = steps)
  Y <- matrix(ncol = 1)

  for (i in 1:length(open)) {
    index <- i + steps - 1
    if (index > length(open)) {
      break
    }
    seq_x <- open[i:index]
    seq_y <- close[index]

    X <- rbind(X, seq_x)
    Y <- rbind(Y, seq_y)
  }

  X <- X[-1, ]
  Y <- Y[-1, ]

  dim(X) <- c(dim(X)[1], dim(X)[2], 1) # features is set to 1 as we have 1D data

  return(list(X = X, Y = Y))
}

append_timeseries <- function(ts, value) {
  ts <- c(ts, value) # append the previously predicted value
  ts <- ts[-1] # shift the 1st value
}

divide_data <- function(data, tnum, ts_length, pnum = 5) {
  open <- data$Open
  close <- data$Close
  size <- length(open)
  train_size <- length(open) - tnum - pnum
  test_size <- length(open) - pnum

  print(size)
  print(train_size)
  print(test_size)
  train <- open[1:train_size]
  test <- open[(train_size - ts_length + 2):test_size]
  predict <- open[(test_size + 1):size]
  actual <- close[1:train_size]
  return(list(Train = train, Test = test, Predict = predict, Actual = actual))
}

choose_data <- function(name) {
  data_name <- paste("train_data/", name, sep = "")
  data_frame <- read.csv(data_name)
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
  return(list.files("train_data/"))
}
