width <- 400
button_width <- "100px"

ui <- dashboardPage(
  dashboardHeader(title = "Stock prediction CNN", titleWidth = width),
  dashboardSidebar(
    width = width,

    useShinyjs(),
    
    h3("Data section", style = "margin-left: 12px"),

    selectInput("data",
      width = "100%",
      label = "Choose data",
      choices = NULL
    ),

    hr(),
    
    h3("Model section", style = "margin-left: 12px"),

    radioButtons("model_radio",
      label = "Choose model",
      choices = list("New" = TRUE, "Pretrained" = FALSE),
      selected = FALSE
    ),

    uiOutput(outputId = "dynamicModels"),

    hr(),

    uiOutput(outputId = "dynamicSection"),
    
    fluidRow(
      column(
        4,
        actionButton("prepare",
          label = "Prepare data"
        )
      ),
      column(
        6,
        uiOutput("prep_state")
      )
    ),



    hr(),
    
    h3("Actions section", style = "margin-left: 12px"),

    fluidRow(
      # column(4,
      #        actionButton("train",
      #                     label = "Train"),),
      # column(4,
      #        actionButton("test",
      #                     label = "Test"),),
      # column(4, actionButton("prediction",
      #                        label = "Prediction")),
      column(
        12,
        div(
          style = "display: flex",
          div(
            style = "display: flex, flex: 1",
            actionButton("train",
              width = "100%",
              label = "Train"
            )
          ),
          div(
            style = "display: inline-block, flex: 1",
            actionButton("test",
              width = "100%",
              label = "Test"
            )
          ),
          div(
            style = "display: inline-block, flex: 1",
            actionButton("prediction",
              width = "100%",
              label = "Prediction"
            )
          ),
        )
      )
    )
  ),

  dashboardBody(
    tabsetPanel(
      id = "plotTabs", type = "tabs",
      tabPanel("Raw Data", value = "dataPlot", plotOutput(outputId = "dynamicPlot")),
      tabPanel("Train", value = "trainPlot", plotOutput(outputId = "dynamicTrain")),
      tabPanel("Test", value = "testPlot", plotOutput(outputId = "dynamicTest")),
      tabPanel("Prediction", value = "predictionPlot", plotOutput(outputId = "dynamicPrediction"))
    ),

    verbatimTextOutput("console")
  )
)
