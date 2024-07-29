### Summary:
### Inputs:
### Output:

BreakingTiesSelectorFunc = function(Model, TrainingDataSet, SelectorN = 2){
  
  ModelProbabilities = predict(Model,
                               newdata = TrainingDataSet,
                               type = "prob")
  
  ProbMax1 = apply(X = ModelProbabilities, MARGIN = 1, FUN = max)
  ProbMax2 = apply(X = ModelProbabilities, 
                   MARGIN = 1, 
                   FUN = function(x) {sort(x,partial=length(x)-1)[length(x)-1]})
  
  TrainingDataSet$BreakingTiesProb = ProbMax1 - ProbMax2
  IDRec = arrange(TrainingDataSet, BreakingTiesProb)$ID[1:SelectorN]
  
  return(IDRec)
}
