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
  if(!(SelectorType %in% c("Random", "BreakingTies"))){
    stop("SelectorType has to be Random or BreakingTies")
  }
  if(!(ModelType %in% c("Logistic", "LASSO"))){
    stop("SelectorType has to be Random or BreakingTies")
  }
  
  
  ### Progres Bar ###
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
    # Multinomial #
    # MultinomModel = multinom(as.factor(Y) ~ .,
    #                 data = TrainingSet[, setdiff(names(TrainingSet), c("ID"))],
    #                 trace = FALSE)
    # MultinomModelPredicted = predict(MultinomModel,
    #                                  newdata = TrainingSet)
    # Error[iter] = mean(MultinomModelPredicted != TrainingSet$Y)
    
    switch(ModelType,
           Logistic = {
             Model = glm(Y ~ ., 
                         data = TrainingSet[, setdiff(names(TrainingSet), c("ID"))],
                         family = "binomial")
             PredictedLabels = 1*(predict(Model, 
                                          newdata = TrainingSet, 
                                          type = "response")>0.5)+1
             LabelProbabilities = as.matrix(predict(Model, 
                                                    newdata = TrainingSet, 
                                                    type = "response"))
             LabelProbabilities = cbind(ID = as.numeric(rownames(LabelProbabilities)),
                                               Class1 = LabelProbabilities[,1], 
                                               Class2 = 1-LabelProbabilities[,1])
           },
           LASSO = {
             # Best Lambda #
             LassoRegression = glmnet(x = as.matrix(TrainingSet[, setdiff(names(TrainingSet), c("Y"))]),
                                      y = as.matrix(TrainingSet$Y),
                                      alpha = 1,
                                      family = "binomial")
             MinLambda = min(LassoRegression$lambda)
             
             # Prediction #
             LabelProbabilities = predict(LassoRegression,
                                               newx = as.matrix(TrainingSet[, setdiff(names(TrainingSet), c("Y"))]),
                                               s = MinLambda,
                                               type = "response")
             PredictedLabels = ifelse(LabelProbabilities > 0.5,1,0)+1
             LabelProbabilities = cbind(ID = as.numeric(rownames(LabelProbabilities)),
                                        Class1 = LabelProbabilities[,1], 
                                        Class2 = 1-LabelProbabilities[,1])
           }
           
           )
    
    
    ### Eror and Stopping Criteria ###    
    Error[iter] = mean(PredictedLabels != TrainingSet$Y)
    if(iter > TailN){if(is.null(StopIter)){StopIter = StoppingCriteriaFunc(ErrorVector = Error[1:iter], 
                                                                           ErrorThreshold = ErrorThreshold, 
                                                                           VarThreshold = VarThreshold, 
                                                                           TailN = TailN)}}
    
    ### Selector ###
    switch(SelectorType,
           Random = {
             SelectorDataSets = RandomSelectorFunc(SelectorN = SelectorN, TrainingSet, CandidateSet)},
           BreakingTies = {
             SelectorDataSets = BreakingTiesSelectorFunc(ClassProbabilities = LabelProbabilities,
                                                    TrainingSet = TrainingSet,
                                                    CandidateSet = CandidateSet,
                                                    SelectorN = SelectorN)})
    
    ### Set Mutation ###
    TrainingSet = SelectorDataSets$TrainingSet
    CandidateSet = SelectorDataSets$CandidateSet
  }
  
  ### System Time ###
  close(pb)
  end_time = Sys.time()
  run_time = end_time - start_time
  
  ErrorScatterPlot = ggplot() +
    geom_line(mapping = aes(x = 1:length(Error), y = Error)) + 
    geom_vline(xintercept = StopIter, color = "red") + 
    geom_hline(yintercept = Error[StopIter], color = "black", linetype = "dotted", alpha = 0.4) + 
    annotate("text", x = StopIter, y = max(Error), label = StopIter) + 
    annotate("text", x = 0, y = Error[StopIter], label = round(Error[StopIter],3)) + 
    ggtitle(paste0("Selector type: ", SelectorType))
  
  
  return(list(Error = Error,
              StopIter = StopIter,
              ErrorScatterPlot = ErrorScatterPlot,
              run_time = run_time))
}
