#libraries
library(RPostgreSQL)
library(here)

# import funcions
source(here::here("Wingu","donaronline","trabajo_final_boosteado","churn_donations","data", "etl","preprocess_functions.R"))

#####################################################################################################################################
# import data
# disconnect all current connections to db
#lapply(dbListConnections(dbDriver("PostgreSQL")), dbDisconnect)

# train
mydb <- dbConnect(dbDriver("PostgreSQL"), 
                  user='postgres', 
                  password='123456',
                  dbname='donaronline_boosted', 
                  host='localhost', 
                  port = '5432')
#import commands from bash
args <- commandArgs()
train_fold = args[6]
test_fold = args[7]

query <- paste('select * from folds.train_fold_',train_fold,' where collected_amount_approved > 0', sep='')

train <- dbSendQuery(mydb, query)
train <- fetch(train, n=-1)

# payment methods
rd <- dbSendQuery(mydb, "select card from cleaned.cards")
df_cards <- fetch(rd, n=-1)

#test
query <- paste('select * from folds.train_fold_',test_fold,' where collected_amount_approved > 0', sep='')
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

# Missing data check
#mice_plot <- aggr(df, col=c('navyblue','yellow'),
#                  numbers=TRUE, sortVars=TRUE,
#                  labels=names(df), cex.axis=.7,
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
