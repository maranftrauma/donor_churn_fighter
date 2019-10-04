# This is a code to train using the selected model(best one) evaluating all the 
# models results. 
# Best model = Extra Tree with hyperparameters as follow
# mtry: 15 ntree: 1500 nodesize: 2 numRandomCuts: 1	
# Cohort = Large
# Code developed by Maria Ines Aran.

#####################################################################################################################################
                                                    # LIBRARIES AND CONFIGURATION 

# Save errors and warnings in log file
warning_file = file("RScriptErrors_Best_Model.log", open = "wt")
sink(warning_file, type = "message")

# Libraries
library(caret, quietly = TRUE)
library(glmnet, quietly = TRUE)
library(rms, quietly = TRUE)
library(risksetROC, quietly = TRUE)
library(doParallel, quietly = TRUE)
library(RPostgreSQL)
library(VIM)
library(dplyr)
library(purrr)
library(DMwR)
library(tidyr)
library(pec)
library(plyr)
library(ROSE)
library(InformationValue)
library(MLmetrics)
library(pROC)
library(here)


# To make rJava work on RStudio:
#dyn.load('/Library/Java/JavaVirtualMachines/jdk1.8.0_144.jdk/Contents/Home/jre/lib/server/libjvm.dylib')
library(extraTrees)

options(java.parameters = "-Xmx4g")

# config
options(scipen=999)

# Parallel
#registerDoParallel(detectCores() - 2 )  ## registerDoMC( detectCores()-1 ) in Linux
#detectCores()
#options(rf.cores = detectCores() - 2, 
#        mc.cores = detectCores() - 2)  ## Cores for parallel processing


#####################################################################################################################################
                                                      ## IMPORT PREPROCES
#run from Studio:
#source(here::here("Wingu","donaronline","trabajo_final_boosteado","churn_donations","data", "etl","3_preprocess_data_for_training","preprocess.R"))
#here::here("Wingu","donaronline","trabajo_final_boosteado","churn_donations","data", "etl","3_preprocess_data_for_training","config.R"))

#run from visual code:
source(here::here("data", "etl","3_preprocess_data_for_training","preprocess.R"))
source(here::here("data", "etl","3_preprocess_data_for_training","config.R"))

#####################################################################################################################################
# SET THE CONFIG
train_fold = train_fold # from preprocess
test_fold = test_fold
algorithm = 'extra_trees'
cohort = cohort
hyperparameter_1 = as.numeric(hyperparameter_1)
hyperparameter_2 = as.numeric(hyperparameter_2)
hyperparameter_3 = as.numeric(hyperparameter_3)
hyperparameter_4 = as.numeric(hyperparameter_4)
hyperparameters = paste('mtry:',hyperparameter_1,'ntree:', hyperparameter_2,'nodesize:' ,hyperparameter_3, 'numRandomCuts:' ,hyperparameter_4)

#####################################################################################################################################
                                                      ## EXTRA TREES 
# Only complete cases
train.complete <- na.omit(train)

# Model
train.complete$churn <- as.factor(train.complete$churn)
x = train.complete[ ,!(colnames(train.complete) == "churn")]
y = train.complete$churn

# Using Extratrees
et_model <- extraTrees(x = x,
                       y = y,
                       mtry = hyperparameter_1,
                       ntree = hyperparameter_2,
                       nodesize = hyperparameter_3, 
                       numRandomCuts = hyperparameter_4)

# Using caret - just for feature importance
#et_grid =  expand.grid(mtry = hyperparameter_1, numRandomCuts = hyperparameter_4)
#et_model <- train(x = x,
#                  y = y,
#                  method = "extraTrees", 
#                  ntree = hyperparameter_2,
#                  nodesize = hyperparameter_3,
#                  tuneGrid = et_grid)


# Print model
#

#plot(et_model)

# Predicting on train set
# caret
#predTrain <- predict(et_model, x, type = "prob")
# extratrees
predTrain <- predict(et_model, x , probability = TRUE)
predTrain <- predTrain[,2]

# Optimal Cutoff
optCutOff <- optimalCutoff(y, predTrain, optimiseFor = "Ones")

# Confusion Matrix - Train
cm.train <- confusionMatrix(train.complete$churn, predTrain, threshold = optCutOff) 
paste ('Optimal CutOff = ',round(optCutOff,2))
cm.train

# Apply on Test Set
test.complete <- na.omit(test)

# Predicting on Validation set
x_test = test.complete[ ,!(colnames(test.complete) == "churn")]
y_test =test.complete$churn

# Extratrees
predValid <- predict(et_model, newdata = x_test, probability = TRUE) 
# Caret
#predValid <- predict(et_model, x_test, type = "prob")
predValid <- predValid[,2]
prediction <- data.frame(predValid, test.complete$churn)
colnames(prediction)[colnames(prediction)=="predValid"] <- "prediction"
colnames(prediction)[colnames(prediction)=="test.complete.churn"] <- "real"

# Performance metrics on test set
# Confusion Matrix
y_test = as.numeric(y_test)
predValid = as.numeric(predValid)
cm <- confusionMatrix( predValid, y_test)

# ROC
rf.roc<-roc(y_test,predValid)
#plot(rf.roc, xlim=c(1.0,0.0), asp = NA)
auc(rf.roc)
threshold <- optCutOff

#Sencitivity, precision and F1-Score
sensitivity.result <- sensitivity(y_test,predValid,  threshold = optCutOff)
precision.result <- precision(y_test,predValid, threshold = optCutOff)
F1 <- (2 * precision.result * sensitivity.result) / (precision.result + sensitivity.result)

metrics <- data.frame(cbind(threshold,sensitivity.result,precision.result,F1,auc(rf.roc)))
names(metrics) <- c("threshold","sencitivity", "precision","f1","auc")

#####################################################################################################################################
                                                            ##  FEATURE IMPORTANCE
# Caret
#feature_importance <- varImp(et_model)$importance

#myvars <- c("X0")
#new_feature_importance <- feature_importance[myvars]
#names(new_feature_importance)[1] <- "importance"
#feature_importance <- new_feature_importance
#rm(new_feature_importance)

#####################################################################################################################################
                                                                  ## OUTPUT
## OUTPUT
# Prediction
predictions_to_db <- cbind(algorithm = c(algorithm),hyperparameters = c(hyperparameters),cohort = c(cohort),test_fold = c(test_fold), prediction, created_on = Sys.time())
metric_to_db <- cbind(algorithm = c(algorithm),hyperparameters = c(hyperparameters),cohort = c(cohort),test_fold = c(test_fold), metrics, created_on = Sys.time())

# Write to database
#mydb <- dbConnect(dbDriver("PostgreSQL"), 
#                  user=USERPOSTGRES, 
#                  password=PASSWORDPOSTGRES,
#                  dbname=DATABASE_NAME, 
#                  host='localhost', 
#                  port = HOST)
# Predictions
#dbWriteTable(mydb, 
#             name = c("results", "predictions"),
#             value = predictions_to_db,
#             row.names=TRUE, 
#             overwrite=FALSE,
#             append= TRUE)

# Metrics
#dbWriteTable(mydb, 
#             name = c("results", "metrics"),
#             value = metric_to_db,
#             row.names=FALSE, 
#             overwrite=FALSE,
#             append= TRUE)

# Feature importance - Caret
# Rstudio:
#path = here("Wingu","donaronline","trabajo_final_boosteado","churn_donations","result")
# Terminal:
#path = here("result")
#write.csv(feature_importance,file.path(path, 'best_model_feature_importance.csv'), row.names = TRUE)

# Model
# save the model to disk - only final model
et_model_to_save = prepareForSave(et_model)
saveRDS(et_model_to_save,
        here::here(paste("models/pickles/"
              ,"best_model"
              ,".rds"
              , sep='')))


