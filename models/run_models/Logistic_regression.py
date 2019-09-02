import subprocess
import itertools as it
from iteration_utilities import deepflatten

folds = range(29,32)

# Build subprocess command
command = 'Rscript'
path2script = '../Logistic_regression.R'

#hyperparameters : {'penalty': ['l1','l2'], 'C': [0.00001,0.001,0.1,1,10]}

hyperparameters={'penalty': ['l1','l2'], 'C': ['1','10']}

def generate_hyperparameters_combination(hyperparameters_dictionary):
    all_hyper = sorted(hyperparameters)
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
