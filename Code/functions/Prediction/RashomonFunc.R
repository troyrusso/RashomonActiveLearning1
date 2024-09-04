### Summary: 
### Inputs:
### Output:

RashomonProfileFunc = function(dat, CovariateList, LabelName, RashomonParameters){
  
  ### Parameters ###
  N = nrow(dat)
  M = length(CovariateList)
  K = RashomonParameters$K
  NBins = RashomonParameters$NBins
  
  ### Rashomon Profiles ###
  NewDat = assign_universal_label(dat, arm_cols = CovariateList)
  StartTime = Sys.time()
  aggregate_rashomon_profiles(NewDat,                                  # TrainingSetTrainingData
                              value = LabelName,                       # Response names
                              arm_cols = CovariateList,                # Covariate names
                              M = length(CovariateList),               # Number of covariates
                              H = RashomonParameters$H,                # Maximum number of pools/splits
                              R = RashomonParameters$R,                # Bins of each arm (assume 0 exists)
                              reg = RashomonParameters$reg,            # Penalty on the splits
                              theta = RashomonParameters$theta,        # Threshold; determine relative to best model
                              inactive = RashomonParameters$inactive
                              ) -> RashomonProfiles  # Losses will always be the last one - (active arms)
  RashomonSetTime = Sys.time() - StartTime
  RashomonSetNum = length(RashomonProfiles[[1]])
  RashomonMakeObjects = make_rashomon_objects(RashomonProfiles)
  
  ### Rashomon Loss ###
  RashomonLosses = RashomonProfiles[[2]][[length(RashomonProfiles[[2]])]]$losses
  
  ### Rashomon Prediction ###
  # Will give the predictions f or the j'th observation of the i'th Rashomon Set model
  TrainingPredictedLabels = sapply(1:RashomonSetNum,  function(x) predict(RashomonMakeObjects[[x]], NewDat$universal_label))
  WholeSetTime = Sys.time() - StartTime
  

  # for(i in 1:ncol(TrainingPredictedLabels)){
  # table(TrainingPredictedLabels[,i]) %>% length %>% print
  # }
  # cbind(test, RashomonLosses)
  # 
  


  ### Return ###
  return(list(RashomonSetNum = RashomonSetNum,
              RashomonLosses = RashomonLosses,
              RashomonMakeObjects = RashomonMakeObjects,
              TrainingPredictedLabels = TrainingPredictedLabels,
              RashomonSetTime = RashomonSetTime,
              WholeSetTime = WholeSetTime))
}
