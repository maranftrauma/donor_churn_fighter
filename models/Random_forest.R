# This is code to develop a random survival model forest to predict donors churn
# Code developed by Maria Ines Aran.

#####################################################################################################################################
                                                    # LIBRARIES AND CONFIGURATION 

# Libraries
library(survival, quietly = TRUE)
library(caret, quietly = TRUE)
library(glmnet, quietly = TRUE)
library(rms, quietly = TRUE)
library(risksetROC, quietly = TRUE)
library(doParallel, quietly = TRUE)
library(randomForestSRC)
library(randomForest)
library(ggRandomForests)
library(RPostgreSQL)
library(VIM)
library(dplyr)
library(purrr)
library(DMwR)
library(tidyr)
library(pec)
library(plyr)
library(ROSE)
library(survminer)
library(survAUC)
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
source(here::here("data", "etl","3_preprocess_data_for_training","preprocess.R"))

#####################################################################################################################################
# SET THE CONFIG
train_fold = train_fold # from preprocess
test_fold = test_fold
algorithm = 'random_forest'

#####################################################################################################################################
                                                      ## RANDOM FOREST 
# Only complete cases
train.complete <- na.omit(train)

# Random Search
train.complete$churn <- as.factor(train.complete$churn)

#mtry tunning
#control <- trainControl(method="repeatedcv", number=10, repeats=3, search="random")
#seed <- 14
#set.seed(seed)
#metric <- "Kappa"
#mtry <- sqrt(ncol(train.complete))
#rf_random <- train(CHURN~., 
#                   data=train.complete, method="rf", metric=metric, tuneLength=30, trControl=control)
#print(rf_random)
#plot(rf_random, col = "black", frame = FALSE, type='l', xaxt='n')


# Grid Search
#mtry tunning
#control <- trainControl(method="repeatedcv", number=10, repeats=3, search="grid")
#set.seed(14)
#tunegrid <- expand.grid(.mtry=c(180:200))
#metric <- "Kappa"
#rf_gridsearch <- train(CHURN~., 
#                       data=train.complete, method="rf", metric=metric, tuneGrid=tunegrid, trControl=control)
#print(rf_gridsearch)
#plot(rf_gridsearch, col = "black", frame = FALSE, type='l', xlab = 'Selected Predictors')

# Model
train.complete$churn <- as.numeric(train.complete$churn)
rf_model <- randomForest(churn ~ ., 
                       mtry = 186,
                       ntree = 500,
                       nodesize = 4, 
                       data = train.complete, 
                       importance = TRUE,
                       replaces = TRUE)

# Print model
rf_model
#plot(rf_model)

# Predicting on train set
predTrain <- predict(rf_model, train.complete, "Class")

# Optimal Cutoff
optCutOff <- optimalCutoff(train.complete$churn, predTrain, optimiseFor = "Ones")

# Confusion Matrix - Train
cm.train <- confusionMatrix(train.complete$churn, predTrain, threshold = optCutOff) 
paste ('Optimal CutOff = ',round(optCutOff,2))
cm.train

# Apply on Test Set
test.complete <- na.omit(test)

# Predicting on Validation set
predValid <- predict(rf_model, newdata = test.complete)
prediction <- data.frame(predValid, test.complete$churn)

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
#paste ('Sensitivity with optimal threshold = ', round(sensitivity.result,3), 'threshold = ', threshold)
#paste ('Precision with optimal threshold = ', round(precision.result,3), 'threshold = ', threshold)
#paste('F1-Score = ',F1)
#cm

metrics <- data.frame(cbind(threshold,sensitivity.result,precision.result,F1,auc(rf.roc)))
names(metrics) <- c("threshold","sencitivity", "precision","f1","auc")

#Feature importance
feature.importance <- data.frame(importance(rf_model))        
#varImpPlot(rf_model, n.var = 10, main = '')    


#boxplot(avg_pay_day ~ churn, data=train.complete, type = 'l')
#boxplot(analytics_camp_q_distinct_referral_dif_t_t1 ~ churn, data=train.complete, type = 'l')
#boxplot(donation_id ~ churn, data=train.complete, type = 'l')
#boxplot(donation_duration ~ churn, data=train.complete, type = 'l')
#boxplot(analytics_ratio_donation ~ churn, data=train.complete, type = 'l')
#boxplot(donation_declared_amount ~ churn, data=train.complete, type = 'l')
#boxplot(donation_day ~ churn, data=train.complete, type = 'l')
#boxplot(amount_rejected ~ churn, data=train.complete, type = 'l')

#cdplot(analytics_camp_q_distinct_referral_dif_t_t1 ~ as.factor(CHURN), data=train.complete)

#####################################################################################################################################
                                                                  ## OUTPUT
## OUTPUT
# Prediction
predictions_to_db <- cbind(algorithm = c(algorithm),fold = c(test_fold), prediction, created_on = Sys.time())
metric_to_db <- cbind(algorithm = c(algorithm), fold = c(test_fold), metrics, created_on = Sys.time())

# Write to database
mydb <- dbConnect(dbDriver("PostgreSQL"), 
                  user='postgres', 
                  password='123456', 
                  dbname='donaronline_boosted', 
                  host='localhost', 
                  port = '5432')
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
# save the model to disk
saveRDS(rf_model,
        here::here(paste("models/pickles/"
              ,algorithm
              ,".rds"
              , sep='')))

