FLAG <- flags(
  flag_integer('epochs', 2),
  flag_integer('filters', 2),
  flag_integer('ts_length', 2),
  flag_integer('test', 2)
)

L <- prepare_data(data_frame, FLAG$ts_length, FLAG$test)

X <- L$X_train
Y <- L$Y_train

print(X)
print(Y)

model <- keras_model_sequential() %>%
  layer_conv_1d(
    filters = FLAG$filters,
    kernel_size = 2,
    activation = "relu",
    input_shape = c(FLAG$ts_length, 1)
  ) %>%
  layer_max_pooling_1d(pool_size = 2)# %>%

model %>%
  layer_flatten() %>%
  layer_dense(units = 50, activation = "relu") %>%
  layer_dense(units = 1)

model %>% compile(optimizer = "adam",
                  loss = "mse",)

history <- model %>% fit(
  x = X,
  y = Y,
  epochs = FLAG$epochs,
  use_multiprocessing = TRUE,
  validation_split = 0.2,
  verbose = 1,
)
