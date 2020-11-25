server <- function(input, output, session) {

  # Usage of helper functions

  source("helper_functions/functions.R")
  source("helper_functions/model.R")
  source("helper_functions/execute.R")
  source("helper_functions/plots.R")

  ############################################################
  # Loacl variable initialization
  ############################################################

  data_name <- reactiveVal()
  data_frame <- NULL
  name <- NULL
  model <- NULL
  X_train <- reactiveVal()
  Y_train <- reactiveVal()
  X_test <- reactiveVal()
  test <- reactiveVal()
  test_length <- NULL
  test_result <- reactiveVal()
  prediction <- reactiveVal()
  prediction_result <- reactiveVal()
  ts_length <- NULL
  p_num <- NULL

  prerared_flag <- reactiveVal(FALSE)
  models_names <- reactiveVal()
  data_names <- get_data_names()
  history_change <- reactiveVal()


  ############################################################
  # Event Handlers
  ############################################################

  # Radio buttons choice changed handler
  observeEvent(input$model_radio, {
    output$dynamicModels <- renderUI({
      if (input$model_radio == FALSE) {
        div(
          selectInput(
            "model",
            width = "100%",
            label = "Models",
            choices = models_names()
          ),
          actionButton("summary", label = "Summary"),
        )
      } else {
        div(
          textInput("modelName", label = "New Model", width = "100%"),
          fluidRow(
            column(
              4,
              numericInput("ts", "Trimeseries length", value = 10)
            ),
            column(
              4,
              numericInput("tl", "Testing length", value = 10)
            ),
            column(
              4,
              numericInput("pn", "Prediction length", value = 5)
            )
          ),
          div(
            actionButton("add", label = "Add model"),
          ),
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
      ts_length <<- as.integer(from_name[[3]])
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
      enable("test")
      enable("prediction")
      output$prep_state <- renderUI({
        div(
          h4(style = "color: green", "OK")
        )

      })
    } else {
      disable("train")
      disable("test")
      disable("prediction")
      output$prep_state <- renderUI({
          h4(style = "color: red","NOT READY")
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
  observe({
    ts_length <<- input$ts
  })

  # Test length input handler
  observe({
    test_length <<- input$tl
  })

  # Prediction number input handler
  observe({
    p_num <<- input$pn
  })

  # Add model click handler
  onclick("add", {
    if (!is.null(name)) {
      if (name != "" & !is.null(ts_length) & !is.null(p_num) & !is.null(test_length)) {
        model <- model_initialization(ts_length)
        model_name <- glue::glue("{data_name()} {name} {ts_length} {test_length} {p_num}")
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
    data <- prepare_data(data_frame, t_num = test_length, timeseires_length = ts_length, p_num = p_num)
    X_train(data$X_train)
    Y_train(data$Y_train)
    X_test(data$X_test)
    test(data$Test)
    prediction(data$Predict)

    prerared_flag(TRUE)
  })

  # Summary click handler
  onclick("summary", {
    output$console <- renderPrint({
      summary(model)
    })
  })

  # Train click handler
  onclick("train", {
    updateTabsetPanel(session, "plotTabs", selected = "trainPlot")

    # custom callback
    cb <- callback_lambda(on_epoch_end = function(epoch, logs) {
      html("console", {
        glue::glue("Epoch: {epoch+1}/100, loss: {logs$loss}, val_loss: {logs$val_loss}")
      })
    })
    history <- model_training(model, X_train(), Y_train(), cb)

    history_change(history)
    print(glue::glue("{data_name()} {name} {ts_length} {test_length} {p_num}"))
    model_save(model, glue::glue("{data_name()} {name} {ts_length} {test_length} {p_num}"))
  })

  # Test click handler
  onclick("test", {
    updateTabsetPanel(session, "plotTabs", selected = "testPlot")
    if (!is.null(model)) {
      test_result(model_prediction(model, X_test()))
    }
  })

  # Prediction click handler
  onclick("prediction", {
    updateTabsetPanel(session, "plotTabs", selected = "predictionPlot")
    if (!is.null(model)) {
      last_ts <- X_test()[dim(X_test())[1], , ]
      known_open <- prediction()[1]

      last_ts <- append_timeseries(last_ts, known_open)
      prediction_result(real_prediction(model, last_ts, pnum = p_num))
    }
  })


  ############################################################
  # Plots
  ############################################################

  # Dynamic prediction plot
  output$dynamicPrediction <- renderPlot({
    if (!is.null(prediction_result())) {
      plot_prediction(prediction(), prediction_result())
    }
  })

  # Dynamic raw data plot
  output$dynamicPlot <- renderPlot({
    if (!is.null(data_name()) & data_name() != "") {
      data_frame <<- choose_data(data_name())
      plot_raw_data(data_frame)
    }
  })

  # Dynamic test data plot
  output$dynamicTest <- renderPlot({
    if (!is.null(test_result())) {
      plot_test(test(), test_result(), ts_length = ts_length)
    }
  })

  # Console text change
  output$console <- renderPrint({
    print("TRAIN CONSOLE")
  })


  # Dynamic train result plot
  output$dynamicTrain <- renderPlot({
    if (!is.null(history_change())) {
      plot(history_change())
    }
  })
}
