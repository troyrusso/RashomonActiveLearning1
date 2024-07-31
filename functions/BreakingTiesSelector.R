### Summary:
### Inputs:
### Output:

BreakingTiesSelectorFunc = function(ClassProbabilities, 
                                    TestSet, 
                                    TrainingSet, 
                                    CandidateSet, 
                                    SelectorN=1){
  
  ### Last Observations ###
  if(nrow(CandidateSet) ==1){
    
    SelectedObservation = CandidateSet
    TrainingSet = rbind(TrainingSet, SelectedObservation)
    CandidateSet = CandidateSet[CandidateSet$ID != SelectedObservation$ID,]
    
    return(list(TrainingSet = TrainingSet,
                CandidateSet = CandidateSet))
  }else{
  
  ### Selector ###
  ProbMax1 = apply(X = ClassProbabilities[, setdiff(colnames(ClassProbabilities), "ID")], MARGIN = 1, FUN = max)
  ProbMax2 = apply(X = ClassProbabilities[, setdiff(colnames(ClassProbabilities), "ID")], 
                   MARGIN = 1, 
                   FUN = function(x) {sort(x,partial=length(x)-1)[length(x)-1]})
  TestSet$BreakingTiesProb = ProbMax1 - ProbMax2
  IDRec = arrange(TestSet, BreakingTiesProb)$ID[1:SelectorN]
  MostUncertainObs = TestSet[TestSet$ID==IDRec, 
                                 setdiff(names(TestSet), c("ID", "Y", "BreakingTiesProb"))]
  
  ### Distance Metric - or use norm? ###
  # (dist(rbind(MostUncertainObs,
  #            CandidateSet[, setdiff(names(CandidateSet), c("ID", "Y", "MalDistance"))]),
  #      method = "euclidean") %>%
  #   as.matrix)[,1] -> DistMatrix
  # sort(DistMatrix,partial=length(DistMatrix)-1)[length(DistMatrix)-1]

  # print(c(nrow(TrainingSet),nrow(CandidateSet)))
  
  VarCovMatrix = cov(rbind(MostUncertainObs,
                           CandidateSet[, setdiff(names(CandidateSet), c("ID", "Y", "MalDistance"))]))
    MalDistance = try(stats::mahalanobis(x = as.matrix(CandidateSet[, setdiff(names(CandidateSet), c("ID", "Y" , "MalDistance"))]),
                                         center = as.matrix(MostUncertainObs),  
                                         cov = VarCovMatrix),
                  silent = TRUE)
    
    if(inherits(MalDistance, 'try-error')){
      return(list(TrainingSet = TrainingSet,
                  CandidateSet = CandidateSet))
    }else{
      CandidateSet$MalDistance = MalDistance
    }

  ### Matched Candidate Data ###
  MatchedCandidateRowNum = sort(CandidateSet$MalDistance,index.return = TRUE)$ix[1:SelectorN]
  SelectedObservation = CandidateSet[MatchedCandidateRowNum,]
  
  ### Set Mutation ###
  TrainingSet = rbind(TrainingSet[, setdiff(names(TrainingSet), c("BreakingTiesProb"))], 
                      SelectedObservation[, setdiff(names(SelectedObservation), c("MalDistance"))])
  CandidateSet = CandidateSet[CandidateSet$ID != SelectedObservation$ID, 
                              setdiff(names(CandidateSet), c("MalDistance"))]
  
  return(list(TrainingSet = TrainingSet,
              CandidateSet = CandidateSet))
  }
}



