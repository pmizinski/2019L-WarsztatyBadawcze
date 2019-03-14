#paczki i seed
set.seed(1)
library(jsonlite)
library(OpenML)
library(farff)
library(digest) 
  
  #wczytujemy dataset
  dataset<-read_json("dataset.json",simplifyVector = TRUE)
  preprocessing<-dataset$variables
  dataset$source=="openml"
  pattern<-regexec("\\d+$",dataset$url)
  ID<-regmatches(dataset$url,pattern)
  ID<-as.numeric(ID)
  dane<-getOMLDataSet(ID)
  train<-dane$data
  
  #sprawdzamy paczki
  listLearners(check.packages = TRUE)
  
  #robimy taska i learnera
  classif_task = makeClassifTask(id = "task", data = train, target =dane$target.features)
  classif_learner<-makeLearner("classif.logreg")
  
  #testy
  cv <- makeResampleDesc("CV", iters = 5)
  r <- resample(classif_learner, classif_task, cv,measures = list(acc))
  ACC <- r$aggr
  
  #bierzemy parametry
  parametry<-getParamSet(classif_learner)
  parametry<-parametry$pars
  parametry<-lapply(parametry, FUN=function(x){x$default})
  getHyperPars(classif_learner)
  
  #haszujemy
  hash <- digest(list(classif_task,classif_learner))
  hash    
  
  #robimy jsony
  modeldozapisu<-list(
  id= hash,
  added_by= "wernerolaf",
  date= format.Date(Sys.Date(),"%d-%m-%Y") ,
  library= "mlr",
  model_name= "classif.logreg",
  task_id=paste("classification_",dane$target.features,sep = ""),
  dataset_id= dataset$id,
  parameters=parametry,
  preprocessing=dataset$variables
  )
  
  modeldozapisu<-toJSON(list(modeldozapisu),pretty = TRUE,auto_unbox = TRUE)
 
  taskdozapisu<-list(id=paste("classification_",dane$target.features,sep = ""),added_by= "wernerolaf",
                        date= format.Date(Sys.Date(),"%d-%m-%Y") ,dataset_id= dataset$id,type="classification",target=dane$target.features)
  
  auditdozapisu<-list(id=paste("audit_",hash,sep = ""),
                      date= format.Date(Sys.Date(),"%d-%m-%Y"),added_by= "wernerolaf",
                      model_id=hash,task_id=paste("classification_",
                      dane$target.features,sep = ""),
                      dataset_id=dataset$id,performance=list(acc=ACC))
  
  taskdozapisu<-toJSON(list(taskdozapisu),pretty = TRUE,auto_unbox = TRUE)
  
  auditdozapisu<-toJSON(list(auditdozapisu),pretty = TRUE,auto_unbox = TRUE)
  
  #zapisujemy
  #write(taskdozapisu,"task.json")
  write(modeldozapisu,"model.json")
  write(auditdozapisu,"audit.json")
  
  # info o sesji
  sink("sessionInfo.txt")
  sessionInfo()
  sink()
  
  
  