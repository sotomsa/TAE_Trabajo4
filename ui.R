library(shiny)
library(shinythemes)
library(shinyLP)

shinyUI(fluidPage(
  # Javascript
  includeScript("www/html5-canvas-drawing-app.js"),
  
  # Set the theme
  theme = shinytheme("cerulean"),
  
  # Barra de titulo
  navbarPage("Modelo para la Prediccion de Números desde Imágenes (MNIST)",
             id = "tabs",
             tabPanel("Descripción General",value=1,
                      jumbotron("Bienvenidos",
                                p("Esta es una pequeña apicación para mostrar ",
                                  "el funcionamiento de algunos métodos de ",
                                  "Aprendizaje Estadístico (Machine Learning) ",
                                  "para el reconocimiento de número en imágenes."),
                                button = FALSE),
                      h1("Más información"),
                      p("Los modelos fueron entrenados usando los datos ",
                        a("MNIST", href= "https://en.wikipedia.org/wiki/MNIST_database")),
                      p("Al final de esta página encontraras un pequeño Demo que permite ",
                        "dibujar un número y luego ver número piensas estos modelos ",
                        "que escribiste."),
                      p("Información Técnica se pueden encontrar en el éste ",
                        a("Reporte", href=enlaceReporte)
                        ),
                      h1("Probando los Modelos en Tiempo Real"),
                      p("Escribe un número usando el cursor en la caja siguiente y luego ",
                        "pulsar el botón enviar."),
                      tags$div(class = "image",tags$div(id = "canvasSimpleDiv")),
                      actionButton("clearCanvasSimple", "Borrar"),
                      actionButton("sendCanvasSimple", "Enviar"),
                      p("Según el modelo SVM, el número ingresado parece un:",textOutput("prediccionSVM"))
                      )
             )
  ))
