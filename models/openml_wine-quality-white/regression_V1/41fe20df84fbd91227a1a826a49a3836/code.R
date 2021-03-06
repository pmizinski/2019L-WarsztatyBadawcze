#:# libraries
library(digest)
library(OpenML)
library(mlr)

#:# config
set.seed(1)

#:# data
white_wine <- getOMLDataSet(data.id = 40498L)
wine <- white_wine$data
head(wine)

#:# preprocessing
head(wine)

#:# model
regr_task = makeRegrTask(id = "wwine", data = wine, target = "V1")
regr_lrn = makeLearner("regr.gbm", par.vals = list(n.trees = 500, interaction.depth = 3))

#:# hash 
#:# 41fe20df84fbd91227a1a826a49a3836
hash <- digest(list(regr_task,regr_lrn))
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- mlr::resample(regr_lrn, regr_task, cv,measures = list(mse, rmse, mae, rsq))
r$aggr


#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
