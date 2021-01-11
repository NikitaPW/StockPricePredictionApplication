source("constants.R")

ui <- dashboardPage(
  dashboardHeader(title = "Stock prediction CNN", titleWidth = width),
  dashboardSidebar(
    width = width,
    
    h3("Data section", style = "margin-left: 12px"),
    
    selectInput(
      "data",
      width = "100%",
      label = "Choose data",
      choices = NULL
    ),
    
    hr(),
    
    h3("Model section", style = "margin-left: 12px"),
    
    radioButtons(
      "model_radio",
      label = "Choose model",
      choices = list("New" = TRUE, "Pretrained" = FALSE),
      selected = FALSE
    ),
    
    uiOutput(outputId = "dynamicModels"),
    
    hr(),
    
    uiOutput(outputId = "dynamicSection"),
    
    fluidRow(column(
      6,
      actionButton("prepare",
                   width = button_width,
                   label = "Prepare data")
    ),
    column(6,
           uiOutput("prep_state"))),
    
    
    
    hr(),
    
    h3("Actions section", style = "margin-left: 12px"),
    fluidRow(column(
      6,
      numericInput("epochs", "Number of epochs", value = const_epochs)
    )),
    
    
    fluidRow(column(
      6,
      actionButton("train",
                   width = button_width,
                   label = "Train")
    ),
    column(
      6,
      actionButton("trainTest",
                   width = button_width,
                   label = "Train Test")
    )),
    
    fluidRow(column(
      6,
      actionButton("test",
                   width = button_width,
                   label = "Test")
    ),
    column(
      6,
      actionButton("prediction",
                   width = button_width,
                   label = "Prediction")
    ))
    
  ),
  
  dashboardBody(
    useShinyjs(),
    extendShinyjs(text = jscode, functions = c("closeWindow")),
    tabsetPanel(
      id = "plotTabs",
      type = "tabs",
      tabPanel("Raw Data", value = "dataPlot", plotOutput(outputId = "dynamicPlot")),
      tabPanel("Train", value = "trainPlot", plotOutput(outputId = "dynamicTrain")),
      tabPanel("Train Test", value = "trainTestPlot", plotOutput(outputId = "comparisonTrain")),
      tabPanel("Test", value = "testPlot", plotOutput(outputId = "dynamicTest")),
      tabPanel(
        "Prediction",
        value = "predictionPlot",
        plotOutput(outputId = "dynamicPrediction")
      )
    ),
    
    verbatimTextOutput("console")
  )
)
