plot_raw_data <- function(data_frame) {
  size <- length(data_frame$Open)
  dd <- data.frame(1:size, data_frame$Open, data_frame$Close)
  colnames(dd) <- c("number", "open", "close")
  ggplot(dd) +
    geom_line(aes(x = number, y = open, color = "pse")) +
    geom_line(aes(x = number, y = close, color = "unemploy")) +
    scale_color_discrete(name = "Legend", labels = c("open", "close")) +
    ggtitle("DATA: close and open prices") +
    xlab("Number") +
    ylab("Stock Prices") +
    theme(plot.title = element_text(size = 20))
}

plot_test <- function(actual, test, ts_length) {
  dd <- data.frame(1:(length(actual) - ts_length + 1), actual[ts_length:length(actual)], test)
  colnames(dd) <- c("number", "actual", "predicted")
  ggplot(dd) +
    geom_line(aes(x = number, y = actual, color = "pse")) +
    geom_line(aes(x = number, y = predicted, color = "unemploy")) +
    scale_color_discrete(name = "Legend", labels = c("real", "predicted")) +
    ggtitle("MODEL: test result") +
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
    ggtitle("MODEL: prediction result") +
    xlab("Number") +
    ylab("Stock Prices") +
    theme(plot.title = element_text(size = 20))
}
