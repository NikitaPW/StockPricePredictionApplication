##############################################################
# Server
##############################################################
server <- function(input, output, session) {
  # Usage of helper functions
  
  source("helper_functions/functions.R")
  source("helper_functions/model.R")
  source("helper_functions/execute.R")
  source("helper_functions/plots.R")
  source("constants.R")
  
  ############################################################
  # Local variables initialization
  ############################################################
  
  data_name <- reactiveVal()
  data_frame <- reactiveVal()
  name <- NULL
  model <- NULL
  X_train <- reactiveVal()
  Y_train <- reactiveVal()
  train <- reactiveVal()
  train_result <- reactiveVal()
  X_test <- reactiveVal()
  test <- reactiveVal()
  test_length <- NULL
  test_result <- reactiveVal()
  prediction <- reactiveVal()
  prediction_result <- reactiveVal()
  p_num <- NULL
  ts_length <- reactiveVal(timeseries_length)
  
  prerared_flag <- reactiveVal(FALSE)
  models_names <- reactiveVal()
  data_names <- get_data_names()
  history_change <- reactiveVal()
  epochs <- reactiveVal(const_epochs)
  reps <- reactiveVal(const_reps)
  
  
  ############################################################
  # Event Handlers
  ############################################################
  
  # Radio buttons choice changed handler
  observeEvent(input$model_radio, {
    #ts_length(timeseries_length)
    output$dynamicModels <- renderUI({
      if (input$model_radio == FALSE) {
        div(
          selectInput(
            "model",
            width = "100%",
            label = "Models",
            choices = models_names()
          ),
          actionButton("summary", width = button_width, label = "Summary"),
        )
      } else {
        div(
          textInput("modelName", label = "New Model", width = "100%"),
          fluidRow(column(
            6,
            numericInput("tl", "Testing length", value = 10)
          ),
          column(
            6,
            numericInput("pn", "Prediction length", value = 5)
          )),
          div(actionButton("add", label = "Add model"),),
          disable("prepare")
        )
      }
    })
    prerared_flag(FALSE)
  })
  
  # Model changed handler
  observeEvent(input$model, {
    if (!is.null(input$model) & input$model != "") {
      from_name <- strsplit(input$model, " ")[[1]]
      
      # set variables
      name <<- from_name[[2]]
      ts_length(as.integer(from_name[[3]]))
      test_length <<- as.integer(from_name[[4]])
      p_num <<- as.integer(from_name[[5]])
      
      model <<- model_load(input$model)
      enable("prepare")
      prerared_flag(FALSE)
    } else {
      disable("prepare")
    }
  })
  
  # Name input handler
  observe({
    name <<- input$modelName
  })
  
  # Prepared_flag change handler
  observe({
    if (prerared_flag()) {
      enable("train")
      enable("trainTest")
      enable("test")
      enable("prediction")
      output$prep_state <- renderUI({
        div(h4(style = "color: green", "OK"))
        
      })
    } else {
      disable("train")
      disable("trainTest")
      disable("test")
      disable("prediction")
      output$prep_state <- renderUI({
        h4(style = "color: red", "NOT READY")
      })
    }
  })
  
  # Display of data
  observe({
    updateSelectInput(session, "data", choices = data_names)
  })
  
  # Data change handler
  observeEvent(input$data, {
    data_name(input$data)
    
    # update models
    
    models_names(get_models_names(data_name()))
    
    # set corresponding tab section
    updateTabsetPanel(session, "plotTabs", selected = "dataPlot")
    prerared_flag(FALSE)
  })
  
  # Timeseries length input handler
  #observe({
  #  ts_length <<- input$ts
  #})
  
  # Test length input handler
  observe({
    test_length <<- input$tl
  })
  
  # Prediction number input handler
  observe({
    p_num <<- input$pn
  })
  
  # Epochs number input handler
  observe({
    epochs(input$epochs)
  })
  
  # Reps number input handler
  observe({
    reps(input$reps)
  })
  
  # Add model click handler
  onclick("add", {
    if (!is.null(name)) {
      if (name != "" &
          !is.null(ts_length()) &
          !is.null(p_num) & !is.null(test_length)) {
        if (length(data_frame()$Open) < timeseries_length * 2) {
          ts_length(timeseries_small)
        } else {
          ts_length(timeseries_length)
        }
        
        model <- model_initialization(ts_length(), 4)
        model_name <-
          glue::glue("{data_name()} {name} {ts_length()} {test_length} {p_num}")
        model_save(model, model_name)
        
        # update models
        models_names(get_models_names(data_name()))
        
        # update gui components
        updateRadioButtons(session, "model_radio", selected = FALSE)
      }
    }
  })
  
  
  
  
  
  # Prepare data click handler
  onclick("prepare", {
    data <-
      prepare_data(
        data_frame(),
        t_num = test_length,
        timeseires_length = ts_length(),
        p_num = p_num
      )
    X_train(data$X_train)
    Y_train(data$Y_train)
    X_test(data$X_test)
    train(data$Train)
    test(data$Test)
    prediction(data$Predict)
    
    # reset results
    history_change(NULL)
    train_result(NULL)
    test_result(NULL)
    prediction_result(NULL)
    prerared_flag(TRUE)
    # reset console output
    output$console <- renderPrint({
      print("CONSOLE")
    })
  })
  
  # Summary click handler
  onclick("summary", {
    output$console <- renderPrint({
      summary(model)
    })
  })
  
  # Train click handler
  onclick("train", {
    temp_train <- NULL
    temp_test <- NULL
    temp_prediction <- NULL
    total_train <- NULL
    total_test <- NULL
    total_prediciton <- NULL
    i <- 1
    
    # custom callback
    cb <- callback_lambda(
      on_epoch_end = function(epoch, logs) {
        html("console", {
          glue::glue("Rep: {i} \n Epoch: {epoch+1}/{epochs()}, loss: {logs$loss}, val_loss: {logs$val_loss}")
        })
      }
    )
    
    for (i in 1:reps()) {
      # Model reset
      model <- model_initialization(ts_length(), 4)
      
      #Model training
      history <-
        model_training(model, X_train(), Y_train(), cb, epochs())
      
      history_change(history)
      
      #Model TrainTest computation
      
      temp <-
        format(round(model_prediction(model, X_train()), 2), nsmall = 2)
      
      temp_train <- as.numeric(temp)
      
      #Model Test computation
      
      temp <-
        format(round(model_prediction(model, X_test()), 2), nsmall = 2)
      temp_test <- as.numeric(temp)
      
      #Model prediction computation
      
      last_ts <- data$X_test[dim(data$X_test)[1], , ]
      known_open <- data$Predict[1, ]
      
      last_ts <- append_timeseries(last_ts, known_open)
      
      temp <-
        format(round(real_prediction(model, last_ts, pnum = p_num)[, 1], 2), nsmall = 2)
      
      temp_prediction <- as.numeric(temp)
      
      
      # save results in total containers
      if (i == 1) {
        total_train <- temp_train
        total_test <- temp_test
        total_prediciton <- temp_prediction
      } else {
        total_train <- total_train  + temp_train
        total_test <- total_test + temp_test
        total_prediciton <- total_prediciton + temp_prediction
      }
      
      updateTabsetPanel(session, "plotTabs", selected = "trainPlot")
    }
    
    Train_result <- total_train / reps()
    Test_result <- total_test / reps()
    Prediction_result <- total_prediciton / reps()
    
    
    
    # Save result to output csv
    
    write.table(
      Train_result,
      glue::glue("outputs/{data_name()}_{name}_TRAIN.csv"),
      row.names = F,
      col.names = F,
      dec = ','
    )
    
    write.table(
      Test_result,
      glue::glue("outputs/{data_name()}_{name}_TEST.csv"),
      row.names = F,
      col.names = F,
      dec = ','
    )
    
    write.table(
      Prediction_result,
      glue::glue("outputs/{data_name()}_{name}_PREDICTION.csv"),
      row.names = F,
      col.names = F,
      dec = ','
    )
    
    # Save resulted model
    
    model_save(model,
               glue::glue("{data_name()} {name} {ts_length()} {test_length} {p_num}"))
    
  })
  
  onclick("trainTest", {
    tryCatch(
      train_result(read.csv(
        glue("outputs/{data_name()}_{name}_TRAIN.csv"),
        header = F,
        sep = ";",
        dec = ",",
      )),
      warning = function(w) {
        
      }
      ,
      error = function(e) {
        
      },
      finally = {
        if (!is.null(train_result())) {
          updateTabsetPanel(session, "plotTabs", selected = "trainTestPlot")
          # print accuracy to console
          output$console <- renderPrint({
            comp_accuracy(Y_train()[, 1], train_result()[, 1])
          })
        }
      }
    )
  })
  
  # Test click handler
  onclick("test", {
    tryCatch(
      test_result(read.csv(
        glue("outputs/{data_name()}_{name}_TEST.csv"),
        header = F,
        sep = ";",
        dec = ",",
      )),
      warning = function(w) {
        
      }
      ,
      error = function(e) {
        
      },
      finally = {
        if (!is.null(test_result())) {
          updateTabsetPanel(session, "plotTabs", selected = "testPlot")
          output$console <- renderPrint({
            comp_accuracy(test()[, 1][(length(test()[, 1]) - length(test_result()[, 1]) + 1):length(test()[, 1])], test_result()[, 1])
          })
        }
      }
    )
  })
  
  # Prediction click handler
  onclick("prediction", {
    tryCatch(
      prediction_result(read.csv(
        glue("outputs/{data_name()}_{name}_PREDICTION.csv"),
        header = F,
        sep = ";",
        dec = ",",
      )),
      warning = function(w) {
        
      }
      ,
      error = function(e) {
        
      },
      finally = {
        if (!is.null(prediction_result())) {
          updateTabsetPanel(session, "plotTabs", selected = "predictionPlot")
          output$console <- renderPrint({
            comp_accuracy(prediction()[, 1], prediction_result()[, 1])
          })
        }
      }
    )
  })
  
  
  ############################################################
  # Plots
  ############################################################
  
  # Dynamic prediction plot
  output$dynamicPrediction <- renderPlot({
    if (!is.null(prediction_result())) {
      write.table(
        prediction_result(),
        glue::glue("outputs/{data_name()}_{name}_PREDICTION.csv"),
        row.names = F,
        col.names = F,
        dec = ','
      )
      plot_prediction(prediction()[, 1], prediction_result()[, 1])
    }
  })
  
  # Dynamic raw data plot
  output$dynamicPlot <- renderPlot({
    if (!is.null(data_name()) & data_name() != "") {
      data_frame(choose_data(data_name()))
      plot_raw_data(data_frame(), data_name())
    }
  })
  
  # Dynamic test data plot
  output$dynamicTest <- renderPlot({
    if (!is.null(test_result())) {
      plot_test(test()[, 1], test_result()[, 1])
    }
  })
  
  # Console text change
  output$console <- renderPrint({
    print("CONSOLE")
  })
  
  
  # Dynamic train result plot
  output$dynamicTrain <- renderPlot({
    plot(history_change())
  })
  
  # Dynamic train result plot
  output$comparisonTrain <- renderPlot({
    if (!is.null(train_result())) {
      plot_prediction(Y_train()[, 1], train_result()[, 1])
    }
  })
  
  # Handle session exit
  session$onSessionEnded(function() {
    js$closeWindow()
    stopApp()
  })
  
}
