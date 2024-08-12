### Summary:
### Inputs:
### Output:

MostUncertainObservationsFunc = function(ClassProbabilities, 
                                         TestSet, 
                                         TrainingSet, 
                                         CandidateSet, 
                                         ModelType,
                                         SelectorN=1){
  
  
  if((ModelType %in% c("Logistic", "LASSO", "Multinomial", "MultinomLASSO"))){
    
  ### Selector ###
  ProbMax1 = apply(X = ClassProbabilities[, setdiff(colnames(ClassProbabilities), "ID")], 
                   MARGIN = 1, 
                   FUN = max)
  ProbMax2 = apply(X = ClassProbabilities[, setdiff(colnames(ClassProbabilities), "ID")], 
                   MARGIN = 1, 
                   FUN = function(x) {sort(x,partial=length(x)-1)[length(x)-1]})
  TestSet$BreakingTiesProb = ProbMax1 - ProbMax2
  IDRec = arrange(TestSet, BreakingTiesProb)$ID[1:SelectorN]
  MostUncertainObs = TestSet[TestSet$ID==IDRec, 
                             setdiff(names(TestSet), c("ID", "Y", "BreakingTiesProb"))]
  }else if(ModelType == "Linear"){
    TestSet$BreakingTiesProb = ClassProbabilities
    IDRec = arrange(TestSet, desc(BreakingTiesProb))$ID[1:SelectorN]
    MostUncertainObs = TestSet[TestSet$ID==IDRec, 
                               setdiff(names(TestSet), c("ID", "Y", "BreakingTiesProb"))]
    
  }
  
  return(MostUncertainObs)
  
}
  
  
  
  
  
  