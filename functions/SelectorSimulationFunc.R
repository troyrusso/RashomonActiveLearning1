SelectorSimulationFunc = function(dat,
                                  TestProportion = 0.2,
                                  TailN,
                                  ErrorThreshold,
                                  VarThreshold,
                                  SelectorType,
                                  SelectorN,
                                  ModelType,
                                  InitialN,
                                  seed){
  ### Seed ###
  set.seed(seed)
  
  ### Validation ###
  ValidationFunc(SelectorType, ModelType)
  
  ### Train Test Split ###
  TestSize = floor(TestProportion * nrow(dat))
  TrainingIndices = sample(seq_len(nrow(dat)), size = nrow(dat) - TestSize)
  dat = dat[TrainingIndices,]
  TestSet = dat[-TrainingIndices,]
  
  ### Random Start ###
  RandomStart = RandomStartFunc(InitialN=InitialN, dat=dat)
  TrainingSet = RandomStart$TrainingSet
  CandidateSet = RandomStart$CandidateSet
  
  ### Set Up ###
  NClass = length(unique(TestSet$Y))
  Error = numeric(nrow(CandidateSet))
  ClassError = matrix(nrow = nrow(CandidateSet),
                      ncol = NClass)
  colnames(ClassError) = paste0("Class", 1:NClass)
  StopIter = NULL
  
  ### Progress Bar ###
  pb = txtProgressBar(min = 0, 
                      max = nrow(CandidateSet),
                      style = 3,  
                      width = 50,
                      char = "=")
  start_time = Sys.time()
  
  ### Simulation ###
  for(iter in 1:nrow(CandidateSet)){
    ## Progress Bar ##
    setTxtProgressBar(pb, iter)
    
    ## Train Model ##
    ModelTypeSwitchResults = ModelTypeSwitchFunc(TrainingSet, ModelType)
    Model = ModelTypeSwitchResults$Model
    # PredictedLabels = ModelTypeSwitchResults$TrainingPredictedLabels
    # LabelProbabilities = ModelTypeSwitchResults$TrainingLabelProbabilities
    
    ### Error and Stopping Criteria ### 
    TestErrorResults = TestErrorFunction(Model, ModelType, TestSet)
    LabelProbabilities = TestErrorResults$TestPredictedProbabilities
    Error[iter] = TestErrorResults$Error
    ClassError[iter,] = TestErrorResults$ClassError
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
              ClassError = ClassError,
              StopIter = StopIter,
              SelectorType = SelectorType,
              run_time = run_time))
}
