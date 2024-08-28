### Summary: 
### Inputs:
### Output:

RashomonProfileFunc = function(DataSet, K, NBins){
  
  ### Do later ###
  # K = 
  # NBins =
  N = nrow(DataSet)
  
  ### Rashomon Profiles ###
  ColArms = paste0("X",1:K)
  # ColArms = c("Duration", "Amount", "InstallmentRatePercentage", "ResidenceDuration", "Age", "NumberExistingCredits",
  #             "NumberPeopleMaintenance", "Telephone","ForeignWorker")
  NewDat = assign_universal_label(DataSet, arm_cols = ColArms)
  StartTime = Sys.time()
  aggregate_rashomon_profiles(NewDat,                            # TrainingData
                              value = "Y",                       # Response names
                              arm_cols = ColArms,                # Covariate names
                              M = length(ColArms),               # Number of covariates
                              H = Inf,                           # Maximum number of pools/splits
                              # R = NBins+1,                       # Bins of each arm (assume 0 exists)
                              R = c(3,3,4,4,3,4,2,2,2),
                              reg = 1,                           # Penalty on the splits
                              theta = 5,                         # Threshold; determine relative to best model
                              inactive = 0) -> RashomonProfiles  # Losses will always be the last one - (active arms)
  RashomonSetTime = Sys.time() - StartTime
  RashomonMakeObjects = make_rashomon_objects(RashomonProfiles)
  RashomonSetNum = length(RashomonProfiles[[1]])
  
  ### Rashomon Loss ###
  RashomonLosses = RashomonProfiles[[2]][[length(RashomonProfiles[[2]])]]$losses
  
  ### Rashomon Prediction ###
  # Will give the predictions f or the j'th observation of the i'th Rashomon Set model
  PredictionObsModel = numeric(N * length(RashomonProfiles[[1]])) %>%
    matrix(nrow = N)
  
  for(ModelNum in 1:RashomonSetNum){
    PoolDictionary = RashomonMakeObjects[[ModelNum]]$pool_dictionaries[[16]] #16 = 2^numberof arms
    
    for(obs in 1:N){
      PredictionObsModel[obs,ModelNum] = PoolDictionary$get(as.integer(NewDat[obs]$universal_label))
    }
  }
  WholeSetTime = Sys.time() - StartTime


  ### Return ###
  return(list(RashomonSetNum = RashomonSetNum,
              RashomonLosses = RashomonLosses,
              PredictionObsModelRounded = round(PredictionObsModel),
              PredictionObsModel = PredictionObsModel,
              RashomonSetTime = RashomonSetTime,
              WholeSetTime = WholeSetTime))
}