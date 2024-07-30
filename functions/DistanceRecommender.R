### Summary:
### Inputs:
### Output:

BreakingTiesSelectorFunc = function(TrainingIDRec, TrainingSet, CandidateSet, SelectorN=1){
  
  ### Selector ###
  ProbMax1 = apply(X = ClassProbabilities[, setdiff(colnames(ClassProbabilities), "ID")], MARGIN = 1, FUN = max)
  ProbMax2 = apply(X = ClassProbabilities[, setdiff(colnames(ClassProbabilities), "ID")], 
                   MARGIN = 1, 
                   FUN = function(x) {sort(x,partial=length(x)-1)[length(x)-1]})
  
  TrainingSet$BreakingTiesProb = ProbMax1 - ProbMax2
  IDRec = arrange(TrainingSet, BreakingTiesProb)$ID[1:SelectorN]
  MostUncertainObs = TrainingSet[TrainingSet$ID==TrainingIDRec, setdiff(names(TrainingSet), c("ID", "Y"))]
  
  ### Distance Metric ###
  VarCovMatrix = cov(rbind(MostUncertainObs, CandidateSet[, setdiff(names(TrainingSet), c("ID", "Y"))]))
  CandidateSet$MalDistance = stats::mahalanobis(x = as.matrix(CandidateSet[, setdiff(names(TrainingSet), c("ID", "Y"))]), 
                                                center = as.matrix(MostUncertainObs),
                                                cov = VarCovMatrix)
  
  ### Matched Candidate Data ###
  MatchedCandidateRowNum = sort(CandidateSet$MalDistance,index.return = TRUE)$ix[1:SelectorN]
  SelectedObservation = CandidateSet[MatchedCandidateRowNum,]
  
  ### Set Mutation ###
  TrainingSet = rbind(TrainingSet, SelectedObservation[, setdiff(names(TrainingSet), c("MalDistance"))])
  CandidateSet = CandidateSet[CandidateSet$ID != SelectedObservation$ID,]
  
  return(list(TrainingSet = TrainingSet,
              CandidateSet = CandidateSet))
}
# 
# ScatterPlotX1X2 = ggplot(data = CombinedDataSet) +
#   geom_point(data = CandidateSet, mapping = aes(x = X1, y = X2))+
#   geom_point(data = TrainingSet[TrainingSet$ID==TrainingIDRec,], mapping = aes(x = X1, y = X2), color = "red") + 
#   geom_point(data = CandidateSet[CandidateSet$ID==MatchedCandidateObservationID,], 
#              mapping = aes(x = X1, y = X2), color = "blue") 
#   
  



