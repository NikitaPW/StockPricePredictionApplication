source("execute.R")
source("model.R")

data_name <-
  paste("../train_data/", "WIG20_3_MONTH_NEW.csv", sep = "")
data_frame <- read.csv(data_name, sep = ";")


runs <- tuning_run(
  "tuning.R",
  flags = list(
    epochs = c(300, 1500, 6000),
    filters = c(6, 24, 64, 128, 256, 512),
    ts_length = c(5, 10, 20),
    test = 10
  ),
  confirm = FALSE
)

data_name1 <-
  paste("../train_data/", "WIG20_3_MONTH_NEW.csv", sep = "")
data_frame <- read.csv(data_name1, sep = ";")

runs1 <- tuning_run(
  "tuning.R",
  flags = list(
    epochs = c(300, 1500, 6000),
    filters = c(6, 24, 64, 128, 256, 512),
    ts_length = c(5, 10, 20),
    test = 10
  ),
  confirm = FALSE
)

data_name2 <-
  paste("../train_data/", "WIG20_YEAR_NEW.csv", sep = "")
data_frame <- read.csv(data_name2, sep = ";")

runs2 <- tuning_run(
  "tuning.R",
  flags = list(
    epochs = c(300, 1500, 6000),
    filters = c(6, 64, 128, 256, 512),
    ts_length = c(5),
    test = 10
  ),
  confirm = FALSE
)
