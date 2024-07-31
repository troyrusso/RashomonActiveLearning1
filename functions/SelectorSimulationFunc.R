SelectorSimulationFunc = function(dat,
                                  TailN,
                                  ErrorThreshold,
                                  VarThreshold,
                                  TrainingSet,
                                  CandidateSet,
                                  SelectorType,
                                  SelectorN,
                                  ModelType){
  
  ### Validation ###
  ValidationFunc(SelectorType, ModelType)
  
  ### Progress Bar ###
  pb = txtProgressBar(min = 0, 
                      max = nrow(CandidateSet),
                      style = 3,  
                      width = 50,
                      char = "=")
  start_time = Sys.time()
  
  ### Simulation ###
  Error = numeric(nrow(CandidateSet))
  StopIter = NULL
  for(iter in 1:nrow(CandidateSet)){
    ## Progress Bar ##
    setTxtProgressBar(pb, iter)
    
    ## Model ##
    ModelTypeSwitchResults = ModelTypeSwitchFunc(TrainingSet, ModelType)
    PredictedLabels = ModelTypeSwitchResults$PredictedLabels
    LabelProbabilities = ModelTypeSwitchResults$LabelProbabilities
    
    ### Eror and Stopping Criteria ###    
    Error[iter] = mean(PredictedLabels != TrainingSet$Y)
    if(iter > TailN){if(is.null(StopIter)){StopIter = StoppingCriteriaFunc(ErrorVector = Error[1:iter], 
                                                                           ErrorThreshold = ErrorThreshold, 
                                                                           VarThreshold = VarThreshold, 
                                                                           TailN = TailN)}}
    
    ### Selector ###
    SelectorDataSets = SelectorTypeSwitchFunc(SelectorType = SelectorType, 
                                              SelectorN = SelectorN, 
                                              TrainingSet = TrainingSet, 
                                              CandidateSet = CandidateSet, 
                                              LabelProbabilities = LabelProbabilities)
    ### Set Mutation ###
    TrainingSet = SelectorDataSets$TrainingSet
    CandidateSet = SelectorDataSets$CandidateSet
  }
  
  ### System Time ###
  close(pb)
  end_time = Sys.time()
  run_time = end_time - start_time
  
  # ErrorScatterPlot = ggplot() +
  #   geom_line(mapping = aes(x = 1:length(Error), y = Error)) + 
  #   geom_vline(xintercept = StopIter, color = "red") + 
  #   geom_hline(yintercept = Error[StopIter], color = "black", linetype = "dotted", alpha = 0.4) + 
  #   annotate("text", x = StopIter, y = max(Error), label = StopIter) + 
  #   annotate("text", x = 0, y = Error[StopIter], label = round(Error[StopIter],3)) + 
  #   ggtitle(paste0("Selector type: ", SelectorType))
  
  
  return(list(Error = Error,
              StopIter = StopIter,
              SelectorType = SelectorType,
              run_time = run_time))
}
