SelectorSimulationFunc = function(dat,
                                  TestProportion = 0.2,
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
  
  ### Train Test Split ###
  TestSize = floor(TestProportion * nrow(dat))
  TrainingIndices = sample(seq_len(nrow(dat)), size = nrow(dat) - TestSize)
  dat = dat[TrainingIndices,]
  TestSet = dat[-TrainingIndices,]
  
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
    
    ## Train Model ##
    ModelTypeSwitchResults = ModelTypeSwitchFunc(TrainingSet, ModelType)
    Model = ModelTypeSwitchResults$Model
    # PredictedLabels = ModelTypeSwitchResults$TrainingPredictedLabels
    # LabelProbabilities = ModelTypeSwitchResults$TrainingLabelProbabilities
    
    ### Error and Stopping Criteria ### 
    TestErroResults = TestErrorFunction(Model, ModelType, TestSet)
    LabelProbabilities = TestErroResults$TestPredictedProbabilities
    Error[iter] = TestErroResults$Error
    if(iter > TailN){if(is.null(StopIter)){StopIter = StoppingCriteriaFunc(ErrorVector = Error[1:iter], 
                                                                           ErrorThreshold = ErrorThreshold, 
                                                                           VarThreshold = VarThreshold, 
                                                                           TailN = TailN)}}
    
    ### Selector ###
    SelectorDataSets = SelectorTypeSwitchFunc(SelectorType = SelectorType, 
                                              SelectorN = SelectorN,
                                              TestSet = TestSet,
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

  return(list(Error = Error,
              StopIter = StopIter,
              SelectorType = SelectorType,
              run_time = run_time))
}
