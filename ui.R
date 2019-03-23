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
                                p("Esta aplicación muestra ",
                                  "el funcionamiento de algunos métodos de ",
                                  "Aprendizaje Estadístico (Machine Learning) ",
                                  "para el reconocimiento de números en imágenes."),
                                button = FALSE),
                      h1("Más información"),
                      p("Los modelos fueron entrenados usando los datos ",
                        a("MNIST", href= "https://en.wikipedia.org/wiki/MNIST_database"),
                        ". Todo el código lo puedes encontrar ",
                        a("aquí",href = "https://github.com/sotomsa/TAE_Trabajo4"),"."),
                      p("Al final de esta página encontraras un pequeño Demo que permite ",
                        "dibujar un número del 0 al 9 y luego obtener una clasificación de ",
                        " varios modelos. ",
                        "El canvas HTML5 donde se dibujan los números esta ",
                        "basado en el trabajo de ",
                        a("William Malone",href = "http://www.williammalone.com/articles/create-html5-canvas-javascript-drawing-app/")),
                      p("Toda la información Técnica se pueden encontrar en el éste ",
                        a("Reporte", href=enlaceReporte)
                        ),
                      h1("Probando los Modelos"),
                      p("Escribe un número del 0 al 9 en la siguiente caja usando tu cursor y luego ",
                        "pulsar el botón enviar."),
                      tags$div(class = "image",tags$div(id = "canvasSimpleDiv")),
                      actionButton("clearCanvasSimple", "Borrar"),
                      actionButton("sendCanvasSimple", "Enviar"),
                      p("Según el modelo SVM, el número ingresado parece un:",textOutput("prediccionSVM")),
                      #p("Según el modelo NN, el número ingresado parece un:",textOutput("prediccionNN")),
                      p("Según el modelo RF, el número ingresado parece un:",textOutput("prediccionRF")),
                      p("Según el modelo CART, el número ingresado parece un:",textOutput("prediccionCART")),
                      p("Según el modelo GLM, el número ingresado parece un:",textOutput("prediccionGLM")),
                      p("NO fue posible cargar la libreria mxnet en ShinyApps.io para predecir con la Red Neuronal."),
                      plotOutput("dibujo",width = 200, height = 200)
                      ),
             tabPanel("Exploración y Modelación",value=2,
                      htmlOutput("reporte"))
  )))
