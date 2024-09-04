### Summary:
### Inputs:
### Output:

MostUncertainObservationsFunc = function(LabelProbabilities, 
                                         TestSet, 
                                         CandidateSet, 
                                         ModelType,
                                         CovariateList){
  
  if(ModelType %in% c("Linear","RashomonLinear", "Factorial")){
    TestSet = cbind(TestSet, LabelProbabilities)
    IDRec = arrange(TestSet, desc(LabelProbabilities))$ID[1]
    MostUncertainObs = data.frame(TestSet)[TestSet$ID %in% IDRec, CovariateList]
  }else if(!(ModelType %in% c("Linear","RashomonLinear", "Factorial"))){
    ProbMax1 = apply(X = LabelProbabilities[, setdiff(colnames(LabelProbabilities), "ID")], 
                     MARGIN = 1, 
                     FUN = max)
    ProbMax2 = apply(X = LabelProbabilities[, setdiff(colnames(LabelProbabilities), "ID")], 
                     MARGIN = 1, 
                     FUN = function(x) {sort(x,partial=length(x)-1)[length(x)-1]})
    TestSet$BreakingTiesProb = ProbMax1 - ProbMax2
    IDRec = arrange(TestSet, BreakingTiesProb)$ID[1]
    MostUncertainObs = TestSet[TestSet$ID %in% IDRec, CovariateList]
  }
  return(MostUncertainObs)
  
}
  
  
  
  
  
  