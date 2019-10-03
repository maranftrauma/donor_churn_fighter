<img align="left" width="140" height="140" src="https://github.com/nakanotokyo/churn_donations/blob/master/references/logo.png" alt="Donor churn predictionicon">
<h1 id="title1">Donor churn prediction</h1>
<br/><br/>

## The project 

### Intro

The attrition of donors in a non-profit organization in Latin America is predicted using a machine learning model. 

### Problem

A non-profit collects and process donations for other non-profits. During 2018 4% of donation were cancelled, the non-profit looks forward to anticipate donors attrition in order to communicate with donors to avoid the cancellation. 

### Data

All the transactions are recoreded in a relational data base and contains data of the donors, donations, approved and rejected donations, payment methods, non-profits that receive the donation and data from google analytics. 

Data is not public.

### Temporal Cross Validation
Prediction problems require taking time into consideration. To generate the data set to train the model, temporary windows were taken in a way that simulated the generation of data from the model in production.

Temporary windows take as a reference point a certain date. From it, the explanatory variables are calculated until the day before the reference date. The result of the variable to predict (cancel or not the donation) is computed from the reference date.

This procedure is repeated by running the reference date every sixty days. In this way 32 temporary windows are formed.
The models are trained using a temporary window and evaluated in the following. This procedure is repeated 32 times and the last window that will be used as a data set for validation is set aside.


### Model

Several models are built using different algorithms and hyperpararameters combination. A model that uses Extremely Randomized Trees is selected as the best one. The AUC is 0.77 in the test dataset held back from training and model selection. 

### The repo

The repository is organized as follows:

*data*: 

- 1. Prepare_database:Bash script to build database in Postgres from SQLdump file. 
- 2. Create_temporal_folds: Python scripts to set the temporal folds and create folds in database.
- 3. Preprocess_data_for_training: R scripts to prepare train and test dataset

*models:*
- Contains R scripts for each algorithm and instructions to train
- Run_models: Python scripts that contains hyperparamters and folds to consider to train models using each algorithm.R script
- Pickles: Serializes and saves models into a rds file

*result*:
- Contains Jupyter notebooks for models selections and feature importance
- Images: Contains images generated in the jupyter notebooks
