# Train with the best model: best algorithm and hyperparameters set up

# Best model = Extra Tree with hyperparameters as follow
# mtry: 15 ntree: 1500 nodesize: 2 numRandomCuts: 1	
# Cohort = Large

import subprocess
import itertools as it
from iteration_utilities import deepflatten

folds = range(1,32)

# Build subprocess command
command = 'Rscript'
path2script = '../Best_Model.R'

hyperparameters={'mtry': ['15'],
                 'ntree': ['1500'], 
                 'nodesize':['2'],
                 'numRandomCuts':['1']}

def generate_hyperparameters_combination(hyperparameters_dictionary):
    all_hyper = list(hyperparameters.keys())
    combinations = it.product(*(hyperparameters[hyper] for hyper in all_hyper))
    return [list(comb) for comb in list(combinations)]

all_hyperparameters = generate_hyperparameters_combination(hyperparameters)

# Loop the folds
for fold in folds:
    for hyper in all_hyperparameters:
        train_fold = str(fold)
        test_fold = str(fold+1)
        args = [train_fold,test_fold,hyper]
        flattened_list = list(deepflatten(args, types=list))
        cmd = [command, path2script] + flattened_list
        print (cmd)
        x = subprocess.check_output(cmd, universal_newlines=True)