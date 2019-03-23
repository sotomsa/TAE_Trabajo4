library(shiny)
library(stringr)
library(kernlab)
library(OpenImageR)
library(RCurl)
library(pixmap)
library(glmnet)
library(glmnetUtils)
library(ranger)
#library(mxnet)

# Funcion para convertir de imagen en Base64 a png
getImg <- function(txt) {
  raw <- base64Decode(txt, mode="raw")
  if (all(as.raw(c(0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a))==raw[1:8])) { # it's a png...
    img <- png::readPNG(raw)
    transparent <- img[,,4] == 0
    img <- as.raster(img[,,1:3])
    img[transparent] <- NA
  } else if (all(as.raw(c(0xff, 0xd8, 0xff, 0xd9))==raw[c(1:2, length(raw)-(1:0))])) { # it's a jpeg...
    img <- jpeg::readJPEG(raw)
  } else stop("No Image!")
  return(img)
}

shinyServer(function(input, output) {
  
  # Funcion para hacer el plot de la imágen
  # de nuevo a la pagina
  output$dibujo <- renderPlot({
    img <- imgFromPage()
    if(!is.null(img)){
      plot(pixmapGrey(t(img)))
    }
  })
  
  # Funcion para convertir imagen en formato PNG
  # y codificada en Base64 desde la página a matriz
  # con en (0-1)
  imgFromPage <- reactive({
    if(!is.null(input$countjs)){
      imgURL <- str_sub(input$countjs,start = 23)
      if(nchar(imgURL>0)){
        #save(imgURL,file = "imagen.RData")
        
        # Convert from URL image to PNG image
        img <- getImg(imgURL)
        nr <- nrow(img)
        nc <- ncol(img)
        
        # Get PNG data and Convert to (0-1) scale
        img[is.na(img)] <- 0
        img[img=="#000000"] <- 1
        img <- as.numeric(img)
        img <- (matrix(img, nrow = nr, ncol = nc))
        
        return(img)
      }
    }
    return(NULL)
  })
  
  # Función para convertir de imagen de pixeles
  # a resolucion y data.frame necesario para
  # Predecir
  imgToPred <- reactive({
    img <- imgFromPage()
    if(!is.null(img)){
      # Resize image
      img <- resizeImage(img,28,28)
      
      # Convert to dataframe format
      imgIn <- img
      dim(imgIn) <- NULL
      names(imgIn) <- namesTrain
      imgAsDf <- as.data.frame(t(imgIn))
      return(imgAsDf)
    }
    return(NULL)
  })
  
  # Predicción del SVM
  output$prediccionSVM <-  renderText({
    imgAsDf <- imgToPred()
    if(!is.null(imgAsDf)){
      pred <- kernlab::predict(modSVM,imgAsDf)
      return(levels(pred)[pred])
    }
  })
  
  # Predicción del GLM
  output$prediccionGLM <-  renderText({
    imgAsDf <- imgToPred()
    if(!is.null(imgAsDf)){
      pred <- predict(modGLM_All,imgAsDf, 
                      type = "class", 
                      s=modGLM_All$lambda[1])
      return(pred)
    }
  })
  
  # Predicción del RandomForest
  output$prediccionRF <-  renderText({
    imgAsDf <- imgToPred()
    if(!is.null(imgAsDf)){
      pred <- predict(modRF_All,imgAsDf, 
                      type = "response")
      return(levels(pred$predictions)[pred$predictions])
    }
  })
  
  # # Predicción del NN
  # output$prediccionNN <-  renderText({
  #   imgAsDf <- imgToPred()
  #   if(!is.null(imgAsDf)){
  #     imgAsDf <- as.matrix(imgAsDf)
  #     pred_all <- predict(modeloNNF,X=imgAsDf)
  #     pred <- which(pred_all==max(pred_all))-1
  #     return(pred)
  #   }
  # })
  
  # Predicción del CART
  output$prediccionCART <-  renderText({
    imgAsDf <- imgToPred()
    if(!is.null(imgAsDf)){
      pred <- predict(modCARTInf,imgAsDf, 
                      type = "class")
      return(levels(pred)[pred])
    }
  })
  
  # Enlace al reporte en HTML
  output$reporte <- renderUI({
    tags$iframe(width="95%",
                style="position: absolute; !important",
                src=enlaceReporteHTML,
                height="90%")
  })

})
