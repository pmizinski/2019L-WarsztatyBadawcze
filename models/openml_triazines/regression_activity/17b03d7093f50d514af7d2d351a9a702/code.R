#:# libraries
library(digest)
library(mlr)
library(OpenML)
library(farff)

#:# config
set.seed(1)

#:# data
dataset <- getOMLDataSet(data.name = "triazines")
head(dataset$data)

#:# preprocessing
head(dataset$data)

#:# model
task = makeRegrTask(id = "task", data = dataset$data, target = "activity")
lrn = makeLearner("regr.plsr", par.vals = list(method = "kernelpls"))

#:# hash
#:# 17b03d7093f50d514af7d2d351a9a702
hash <- digest(list(task, lrn))
hash

#:# audit
cv <- makeResampleDesc("CV", iters = 5)
r <- mlr::resample(lrn, task, cv, measures = list(mse, rmse, mae, rsq))
ACC <- r$aggr
ACC

#:# session info
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
