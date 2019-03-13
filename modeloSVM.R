# Script que carga el dataframe de validación cruzada
# Genera un data frame para la evaluación del parametro C
# del SVM y evalua el rendimiento en testing

# Carquemos las librerias necesarias
library(tidyverse)
library(rsample)
library(Metrics)
library(parallel)
library(multidplyr)

# Carguemos los datos
load(file = "data/mnist_data.RData")

# Preprocesemos los datos
train <- train_raw %>% 
  mutate_at(vars(X2:X785),funs(. / 255)) %>% 
  rename(label = X1) %>% 
  mutate(label = factor(label))
test <- test_raw %>% 
  mutate_at(vars(X2:X785),funs(. / 255)) %>% 
  rename(label = X1) %>% 
  mutate(label = factor(label))

# Generemos dataframe de validacion cruzada en
# entrenamiento
v <- 10 # Número de Pliegues
r <- 5 # Número de Repeteciones
frac <- 0.1
set.seed(71265)
cv_data <- vfold_cv(train,
                    v = v,
                    repeats = r) %>% 
  mutate(analysis = map(splits,~analysis(.x)),
         assessment = map(splits,~assessment(.x)),
         y.assessment = map(assessment,~factor(.x$label)))

# Valores de C a probar
modeloSVM <- cv_data %>% 
  crossing(C = c(1,5,10,50,100,500))

# Creemos cluster de cpu´s
cl <- detectCores()
cluster <- create_cluster(cores = cl)

# Organcemos datos para procesamiento en paralelo
group <- rep(1:cl, length.out = nrow(modeloSVM))
modeloSVM <- bind_cols(tibble(group), modeloSVM)

# Agrupemos datos a procesadores
by_group <- modeloSVM %>%
  partition(group, cluster = cluster)

# Carguemos las librerias en los procesadores
by_group %>%
  # Assign libraries
  cluster_library("tidyverse") %>%
  cluster_library("kernlab") %>%
  cluster_library("Metrics")

# Hagamos el procesamiento
# Son 50 modelos que se entrenan
start <- proc.time()
modeloSVM_parallel <- by_group %>%
  mutate(modeloSVM = map2(analysis,C,~kernlab::ksvm(label ~ . , 
                                                    data = .x, 
                                                    C = .y)),
         y.pred = map2(modeloSVM,assessment, ~kernlab::predict(.x,.y)),
         validate_ce = map2_dbl(y.assessment,y.pred,~ce(.x,.y))) %>%
  collect() %>%
  as_tibble()
time_elapsed_parallel <- proc.time() - start
time_elapsed_parallel

# Guardemos los datos
save(modeloSVM_parallel,file = "SVMTrain.RData")

# Como les fue?
if (r==1){
  results <- modeloSVM_parallel %>% 
    group_by(C) %>% 
    summarise(meanCE = mean(validate_ce))
} else {
  results <- modeloSVM_parallel %>% 
    group_by(C,id) %>% 
    summarise(meanCE = mean(validate_ce)) %>% 
    group_by(C) %>% 
    summarise(meanCE = mean(meanCE),
              var = var(meanCE))
}
results

# Escojamos el mejor C
bestC <- results %>% 
  filter( meanCE == min(meanCE) ) %>% 
  .$C
bestC

start_time <- proc.time()
modSVM <- kernlab::ksvm(label ~ . , data = train, C = bestC)
pred <- kernlab::predict(modSVM,(test %>% select(-label)))
errorSVMTesting <- ce(test$label,pred)
end_time <- proc.time()
test_time <- end_time - start_time
test_time

errorSVMTesting

save(modSVM,errorSVMTesting,file = "SVMTest.RData")