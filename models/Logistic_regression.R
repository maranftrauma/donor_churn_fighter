# This is code to train models for prediction donor's churn.
# code developed by maria ines aran.


#####################################################################################################################################
# libraries and configuration 
warning_file = file("RScriptErrors_LogisticRegression.log", open = "wt")

sink(warning_file, type = "message", append = TRUE)

# libraries
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

# config
options(scipen=999)

# Parallel
registerDoParallel(detectCores() - 2 )  ## registerDoMC( detectCores()-1 ) in Linux
detectCores()
options(rf.cores = detectCores() - 2, 
        mc.cores = detectCores() - 2)  ## Cores for parallel processing

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
cohort = cohort
algorithm = 'logistic_regression'
hyperparameters = 'default'
#####################################################################################################################################
                                    ## Logistic Regression 
# only complete cases
train.complete <- na.omit(train)

train.complete$churn <- as.factor(train.complete$churn)

# Model
train$churn <- as.numeric(train$churn)
logit_model <- glm(churn ~ ., 
                   data = train.complete, 
                   family = "binomial")

# Print model
summary(logit_model)
#plot(logit_model)

# Predicting on train set
predTrain <- predict(logit_model, train.complete, "response")

# Optimal Cutoff
optCutOff <- optimalCutoff(train.complete$churn, predTrain, optimiseFor = "Ones")

# Confusion Matrix - Train
cm.train <- confusionMatrix(train.complete$churn, predTrain, threshold = optCutOff) 
#paste ('Optimal CutOff = ',optCutOff)
#cm.train

# Apply on Test Set
test.complete <- na.omit(test)

# Predicting on Validation set
predValid <- predict(logit_model, newdata = test.complete, type="response")
prediction <- data.frame(round(predValid,2), test.complete$churn)
colnames(prediction)[colnames(prediction)=="round.predValid..2."] <- "prediction"
colnames(prediction)[colnames(prediction)=="test.complete.churn"] <- "real"

# Performance metrics on test set
# Confusion Matrix
cm <- confusionMatrix(test.complete$churn,predValid,threshold = optCutOff)
#cm

# ROC
rf.roc<-roc(test.complete$churn,predValid)
#plot(rf.roc, xlim=c(1.0,0.0), asp = NA)
auc(rf.roc)
threshold <- optCutOff

#Sencitivity, precision and F1-Score
sensitivity.result <- sensitivity(test.complete$churn,predValid, threshold = threshold)
precision.result <- precision(test.complete$churn,predValid, threshold = threshold)
F1 <- (2 * precision.result * sensitivity.result) / (precision.result + sensitivity.result)
#paste ('Sensitivity with optimal threshold = ', round(sensitivity.result,3), 'threshold = ',threshold )
#paste ('Precision with optimal threshold = ', round(precision.result,3), 'threshold = ', threshold)
#paste('F1-Score = ',F1)
#cm

metrics <- data.frame(cbind(threshold,sensitivity.result,precision.result,F1,auc(rf.roc)))
names(metrics) <- c("threshold","sencitivity", "precision","f1","auc")

#varImp(logit_model, scale = FALSE)

#####################################################################################################################################
## OUTPUT
## OUTPUT
# Prediction
predictions_to_db <- cbind(algorithm = c(algorithm),hyperparameters = c(hyperparameters),cohort = c(cohort),test_fold = c(test_fold), prediction, created_on = Sys.time())
metric_to_db <- cbind(algorithm = c(algorithm),hyperparameters = c(hyperparameters),cohort = c(cohort),test_fold = c(test_fold), metrics, created_on = Sys.time())

# Write to database
mydb <- dbConnect(dbDriver("PostgreSQL"), 
                  user=USERPOSTGRES, 
                  password=PASSWORDPOSTGRES,
                  dbname=DATABASE_NAME, 
                  host='localhost', 
                  port = HOST)

# Predictions
dbWriteTable(mydb, 
             name = c("results", "predictions"),
             value = predictions_to_db,
             row.names=TRUE, 
             overwrite=FALSE,
             append= TRUE)

# Metrics
dbWriteTable(mydb, 
             name = c("results", "metrics"),
             value = metric_to_db,
             row.names=FALSE, 
             overwrite=FALSE,
             append= TRUE)

# Model
# save the model to disk - only final model
#saveRDS(logit_model,
#        here::here(paste("models/pickles/"
#              ,algorithm
#              ,".rds"
#              , sep='')))