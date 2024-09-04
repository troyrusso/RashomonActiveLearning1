SimulationFunc = function(dat,
                          LabelName,
                          CovariateList,
                          TestProportion = 0.2,
                          SelectorType,
                          SelectorN,
                          ModelType,
                          InitialN,
                          RashomonParameters = NULL,
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
  InitialTrainingSetN = nrow(TrainingSet)
  InitialCandidateSetN = nrow(CandidateSet)
  
  ### Set Up ###
  MaxIterationN = ceiling(nrow(CandidateSet)/SelectorN)
  ModelList = vector('list', MaxIterationN)
  NClass = length(unique(TestSet$Y))
  TestSetPrediction = numeric(MaxIterationN * nrow(TestSet)) %>% 
    matrix(nrow = MaxIterationN,
           ncol = nrow(TestSet))
  colnames(TestSetPrediction) = rownames(TestSet)
  Error = numeric(MaxIterationN)
  ClassError = matrix(nrow = MaxIterationN,
                      ncol = NClass)
  colnames(ClassError) = paste0("Class", 1:NClass)
  SelectedObservationHistory = numeric(MaxIterationN * SelectorN) %>%
    matrix(nrow = MaxIterationN,
           ncol = SelectorN)

  ### Progress Bar ###
  pb = txtProgressBar(min = 0, 
                      max = MaxIterationN,
                      style = 3,  
                      width = 50,
                      char = "=")
  start_time = Sys.time()
  
  ### Simulation ###
  for(iter in 1:MaxIterationN){
    ## Progress Bar ##
    setTxtProgressBar(pb, iter)
    
    ## Train Model ##
    ModelTypeSwitchResults = ModelTypeSwitchFunc(TrainingSet, 
                                                 LabelName, 
                                                 CovariateList, 
                                                 ModelType,
                                                 RashomonParameters = RashomonParameters)
    Model = ModelTypeSwitchResults$Model
    ModelList[[iter]] = Model
    
    ### Error and Stopping Criteria ### 
    TestErrorResults = TestErrorFunction(Model, ModelType, TestSet, CovariateList, LabelName)
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
                                              CovariateList = CovariateList,
                                              LabelProbabilities = LabelProbabilities)
    ### Set Mutation ###
    TrainingSet = SelectorDataSets$TrainingSet
    CandidateSet = SelectorDataSets$CandidateSet
    SelectedObservationHistory[iter,] = SelectorDataSets$SelectedObservationID
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
              InitialTrainingSetN = InitialTrainingSetN,
              InitialCandidateSetN = InitialCandidateSetN,
              SelectedObservationHistory = SelectedObservationHistory,
              run_time = run_time))
}

