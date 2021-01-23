plot_raw_data <- function(data_frame, data_name) {
  size <- length(data_frame$Open)
  dd <- data.frame(1:size, data_frame$Open, data_frame$Close)
  name <- str_sub(data_name, end = -5)
  colnames(dd) <- c("number", "open", "close")
  ggplot(dd) +
    geom_line(aes(x = number, y = open, color = "pse")) +
    geom_line(aes(x = number, y = close, color = "unemploy")) +
    scale_color_discrete(name = "Legend", labels = c("open", "close")) +
    ggtitle(glue::glue("{name}: close and open prices")) +
    xlab("Number") +
    ylab("Stock Prices") +
    theme(plot.title = element_text(size = 20))
}


plot_train <- function(actual, test, ts_length) {
  dd <-
    data.frame(1:(length(actual) - ts_length + 1), actual[ts_length:length(actual)], test)
  colnames(dd) <- c("number", "actual", "predicted")
  ggplot(dd) +
    geom_line(aes(x = number, y = actual, color = "pse")) +
    geom_line(aes(x = number, y = predicted, color = "unemploy")) +
    scale_color_discrete(name = "Legend", labels = c("real", "predicted")) +
    ggtitle("Train test result") +
    xlab("Number") +
    ylab("Stock Prices") +
    theme(plot.title = element_text(size = 20))
}


plot_test <- function(actual, test) {
  ts_length <- length(actual) - length(test) + 1
  dd <-
    data.frame(1:(length(actual) - ts_length + 1), actual[ts_length:length(actual)], test)
  colnames(dd) <- c("number", "actual", "predicted")
  ggplot(dd) +
    geom_line(aes(x = number, y = actual, color = "pse")) +
    geom_line(aes(x = number, y = predicted, color = "unemploy")) +
    scale_color_discrete(name = "Legend", labels = c("real", "predicted")) +
    ggtitle("Test result") +
    xlab("Number") +
    ylab("Stock Prices") +
    theme(plot.title = element_text(size = 20))
}

plot_prediction <- function(actual, test) {
  dd <- data.frame(1:length(actual), actual, test)
  colnames(dd) <- c("number", "actual", "predicted")
  ggplot(dd) +
    geom_line(aes(x = number, y = actual, color = "pse")) +
    geom_line(aes(x = number, y = predicted, color = "unemploy")) +
    scale_color_discrete(name = "Legend", labels = c("real", "predicted")) +
    ggtitle("Prediction result") +
    xlab("Number") +
    ylab("Stock Prices") +
    theme(plot.title = element_text(size = 20))
}
