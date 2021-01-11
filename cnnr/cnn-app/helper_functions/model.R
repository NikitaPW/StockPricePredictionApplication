# ================================================
# Model related functions
# ================================================


model_initialization <- function(timeseires_length, features) {
  for (i in 1:6) {
    input <- layer_input(shape = c(timeseires_length, features))
    
    layer <- input %>%
      layer_conv_1d(
        filters = 4,
        kernel_size = i,
        activation = "relu",
        padding = "same",
        input_shape = c(timeseires_length, features)
      ) %>%
      layer_max_pooling_1d(pool_size = 2) %>%
      layer_conv_1d(
        filters = 4,
        kernel_size = i,
        activation = "relu",
        padding = "same",
        input_shape = c(timeseires_length / 2, features)
      ) %>%
      layer_max_pooling_1d(pool_size = 2)
    
    assign(glue::glue("input_{i}"), input)
    assign(glue::glue("output_{i}"), input)
  }
  
  
  
  output <-
    layer_concatenate(c(output_1, output_2, output_3, output_4, output_5, output_6)) %>%
    layer_flatten() %>%
    #layer_dense(units = 50) %>%
    layer_dense(units = 1)
  
  
  model <-
    keras_model(
      inputs = c(input_1, input_2, input_3, input_4, input_5, input_6),
      outputs = c(output)
    )
  
  model %>% compile(optimizer = "adam",
                    loss = "mse")
  
  return(model)
}

model_training <- function(model, X, Y, cb = NULL, ep = NULL) {
  if (is.null(ep)) {
    epochs = 150
  } else{
    epochs = ep
  }
  
  if (is.null(cb)) {
    callbacks = NULL
  } else{
    callbacks = list(cb)
  }
  
  history <- model %>% fit(
    x = list(X, X, X, X, X, X),
    y = list(Y),
    epochs = epochs,
    use_multiprocessing = TRUE,
    validation_split = 0.2,
    verbose = 0,
    callbacks = callbacks,
  )
}

model_prediction <- function(model, X) {
  prediction <- model %>% predict(list(X, X, X, X, X, X),
                                  verbose = 0)
  return(prediction)
}

model_save <- function(model, name) {
  model %>% save_model_tf(paste("models/", name, sep = ""))
}

model_load <- function(name) {
  model <- load_model_tf(paste("models/", name, sep = ""))
  return(model)
}