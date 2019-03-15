library(shiny)
library(stringr)
library(kernlab)
library(OpenImageR)
library(RCurl)

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
  
  output$prediccionSVM <-  renderText({
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
        img <- matrix(img, nrow = nr, ncol = nc)
        
        # Resize image
        img <- resizeImage(img,28,28)
        
        # Convert to dataframe format
        imgIn <- img
        dim(imgIn) <- NULL
        names(imgIn) <- namesTrain
        imgAsDf <-as_tibble(as.data.frame(t(imgIn)))
        pred <- kernlab::predict(modSVM,imgAsDf)
        return(levels(pred)[pred])
      }
    }
  })

})
