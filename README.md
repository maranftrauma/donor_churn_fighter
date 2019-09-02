# Churn donations

## To train models
Position in /models folder and run
``` bash
Rscript model.R train_fold test_fold
```
train_fold: number of fold to use as train
test_fold: number of fold to use as test

### Issues
Pincha cuando quiero correr todos los folds porq en el preprocess tenes amount > 0 y solo a partir del fold 29
tenes datos para hacer eso.
Ahora voy a correr solo ultimos folds. 
Despues como improvement, deberia cambiar el script de R y tomar el cohort desde un yaml asi probar con y sin amount

Para correr los scripts de R desde consola y q anden, hay q cambiar la ruta en here:here (tanto en los modelos como en process.R)
Es distinto de como funciona ejecutando desde RStudio
