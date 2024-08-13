SimulationFunc = function(dat,
                          TestProportion = 0.2,
                          SelectorType,
                          SelectorN,
                          ModelType,
                          InitialN,
                          seed){
  ### Seed ###
  set.seed(seed)
  
  ### Validation ###
  ValidationFunc(dat, SelectorType, ModelType)
  
  ### Train Test Split ###
  TestSize = floor(TestProportion * nrow(dat))
  TrainingIndices = sample(seq_len(nrow(dat)), size = nrow(dat) - TestSize)
  TestSet = dat[-TrainingIndices,]
  dat = dat[TrainingIndices,]

  ### Random Start ###
  RandomStart = RandomStartFunc(InitialN=InitialN, dat=dat)
  TrainingSet = RandomStart$TrainingSet
  CandidateSet = RandomStart$CandidateSet
  
  ### Set Up ###
  ModelList = vector('list', nrow(CandidateSet))
  NClass = length(unique(TestSet$Y))
  TestSetPrediction = numeric(nrow(CandidateSet) * nrow(TestSet)) %>% 
    matrix(nrow = nrow(CandidateSet),
           ncol = nrow(TestSet))
  colnames(TestSetPrediction) = rownames(TestSet)
  Error = numeric(nrow(CandidateSet))
  ClassError = matrix(nrow = nrow(CandidateSet),
                      ncol = NClass)
  colnames(ClassError) = paste0("Class", 1:NClass)
  # StopIter = NULL
  
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
    ModelList[[iter]] = Model
    
    ### Error and Stopping Criteria ### 
    TestErrorResults = TestErrorFunction(Model, ModelType, TestSet)
    TestSetPrediction[iter ,] = TestErrorResults$TestPredictedLabels
    LabelProbabilities = TestErrorResults$TestPredictedProbabilities
    Error[iter] = TestErrorResults$Error
    ClassError[iter,] = TestErrorResults$ClassError
    
    ### Selector ###
    SelectorDataSets = SelectorTypeSwitchFunc(ModelType = ModelType,
                                              SelectorType = SelectorType, 
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

  return(list(ModelList = ModelList,
              Error = Error,
              ClassError = ClassError,
              SelectorType = SelectorType,
              TestSet = TestSet,
              TestSetPrediction = TestSetPrediction,
              run_time = run_time))
}
