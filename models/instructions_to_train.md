# Training models
Models are trained from terminal ( I used terminal inside Visual Studio Code). 

For training the model you need to first have all the folds already built in the Postgress Database in the folds schema.

## Prepare folds shema
1. Run the bash scripts in 1_prepare_folds. This creates the database from scratch (a mysql dump file) and imports it in PostgresSql.
2. Create temporal folding running master_temporal_folds.py in which you need to decide the as_of_date and time windows for each fold. create_dates.py and create_folds.py are used for the master_mteporal.py to run. Running this will create all the folds in the fold schema in the database.

To run the models you need to go inside run_models folders and run the Python file that executes each algorithm. Inside these files all the hyperparameters are set for each specific algorithm.

algorithm.py will execute models/algorithm.R that will also execute data/etl/3_preprocess_data_for_training/preprocess_functions.R 

For debuging purposes inside each algorith.R and preprocess_functinos.R files there is an option to comment and uncomment the path. This is because the process is intended to be run from terminal but for debuging purposes there is also an option to uncomment a line for running from Rstudio. Rstudio and Terminal has different ways to intepret paths.

You choose small or large cohort in preprocess.R inside data/etl folder.





