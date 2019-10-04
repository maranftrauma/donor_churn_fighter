#libraries
library(RPostgreSQL)
library(VIM)

# import funcions and config

#to run from rstudio :
#source(here::here("Wingu","donaronline","trabajo_final_boosteado","churn_donations","data", "etl","3_preprocess_data_for_training","preprocess_functions.R"))
#source(here::here("Wingu","donaronline","trabajo_final_boosteado","churn_donations","data", "etl","3_preprocess_data_for_training","config.R"))

#run from visual code
source(here::here("data", "etl","3_preprocess_data_for_training","preprocess_functions.R"))
source(here::here("data", "etl","3_preprocess_data_for_training","config.R"))

#####################################################################################################################################
# import data
# disconnect all current connections to db
#lapply(dbListConnections(dbDriver("PostgreSQL")), dbDisconnect)

# db connection
mydb <- dbConnect(dbDriver("PostgreSQL"), 
                  user=USERPOSTGRES, 
                  password=PASSWORDPOSTGRES,
                  dbname=DATABASE_NAME, 
                  host='localhost', 
                  port = HOST)

#import commands from bash
args <- commandArgs()
train_fold = args[6]
test_fold = args[7]
hyperparameter_1 = args[8]
hyperparameter_2 = args[9]
hyperparameter_3 = args[10]
hyperparameter_4 = args[11]
cohort = 'large'

# Small Cohort
#query <- paste('select * from folds.train_fold_',train_fold,' where collected_amount_approved > 0', sep='')
# Large Cohort
query <- paste('select * from folds.train_fold_',train_fold, sep='')

train <- dbSendQuery(mydb, query)
train <- fetch(train, n=-1)

# payment methods
rd <- dbSendQuery(mydb, "select card from cleaned.cards")
df_cards <- fetch(rd, n=-1)

#test
#query <- paste('select * from folds.train_fold_',test_fold,' where collected_amount_approved > 0', sep='')
query <- paste('select * from folds.train_fold_',test_fold, sep='')

rs <- dbSendQuery(mydb, query)
test <- fetch(rs, n=-1)

#####################################################################################################################################
# data preprocess 

# donation_id as index
rownames(train) <- train$donation_id
rownames(test) <- test$donation_id

#drop variables
train[col_drop] <- lapply(train[col_drop],drop_variables)
test[col_drop] <- lapply(test[col_drop],drop_variables)
# transform datatype - numeric
train[cols_numeric] <- lapply(train[cols_numeric],data_type_transformation, datatype= 'numeric')
test[cols_numeric] <- lapply(test[cols_numeric],data_type_transformation, datatype= 'numeric')
# input missing values - 9999
train[cols_input_9999] <- lapply(train[cols_input_9999],input_missings, inputation= 9999)
test[cols_input_9999] <- lapply(test[cols_input_9999],input_missings, inputation= 9999)
# input missing values - 0
train[cols_input_0] <- lapply(train[cols_input_0],input_missings, inputation= 0)
test[cols_input_0] <- lapply(test[cols_input_0],input_missings, inputation= 0)
# if column is full of NA , drop
cond <- sapply(train, function(x)all(is.na(x)))
mask <- !(cond)
train <- train[,mask,drop=F]
test <- test[,mask,drop=F]

# Missing data check
#mice_plot <- aggr(train, col=c('navyblue','yellow'),
#                  numbers=TRUE, sortVars=TRUE,
#                  labels=names(train), cex.axis=.7,
#                  gap=3, ylab=c("Missing data","Pattern"))

#####################################################################################################################################
# train set
# dataset name asignation
table(train$churn)
# class data type transformation 
train$churn <- as.numeric(train$churn)

#levels(train$donor_oficio_normalizado) <- df_occupations$occupation
#levels(train$donation_last_payment_method_used) <- df_cards$card
#levels(test$donation_last_payment_method_used) <- df_cards$card

y <- test$churn
table(test$churn)
#####################################################################################################################################
# disconect from db
dbDisconnect(mydb)
