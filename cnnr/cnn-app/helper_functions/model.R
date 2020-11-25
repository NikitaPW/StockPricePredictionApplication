# ================================================
# Model related functions
# ================================================


model_initialization <- function(timeseires_length){
  
  model <- keras_model_sequential() %>%
    layer_conv_1d(filters = 128, kernel_size = 2, activation = "relu",input_shape = c(timeseires_length,1)) %>%
    layer_max_pooling_1d(pool_size = 2)
  
  model %>%
    layer_dropout(0.4) %>%
    layer_flatten() %>%
    layer_dense(units = 50, activation = "relu") %>%
    layer_dense(units = 1)
  
  model %>% compile(
    optimizer = "adam",
    loss = "mse",
    #metric = "mse"
  )
  
  summary(model)
  
  return(model)
}

model_training <- function(model, X, Y, cb){
  history <- model %>% fit(
    x = X, y = Y, 
    epochs = 1000,
    use_multiprocessing = TRUE,
    validation_split=0.2,
    verbose = 0,
    callbacks = list(cb),
  )
}

model_prediction <- function(model, X){
  prediction <- model %>% predict(
    X,
    verbose = 0
  )
  return(prediction)
}

model_save <- function(model, name){
  model %>% save_model_tf(paste("models/", name, sep = ""))
}

model_load <- function(name){
  model <- load_model_tf(paste("models/", name, sep = ""))
  return(model)
}