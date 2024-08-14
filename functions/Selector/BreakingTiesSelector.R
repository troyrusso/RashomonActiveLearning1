### Summary:
### Inputs:
### Output:

BreakingTiesSelectorFunc = function(LabelProbabilities, 
                                    TestSet, 
                                    TrainingSet, 
                                    CandidateSet, 
                                    ModelType,
                                    SelectorN=1){
  
  ### Last Observations ###
  if(nrow(CandidateSet) ==1){
    
    SelectedObservation = CandidateSet
    TrainingSet = rbind(TrainingSet, SelectedObservation)
    CandidateSet = CandidateSet[CandidateSet$ID != SelectedObservation$ID,]
    
    return(list(TrainingSet = TrainingSet,
                CandidateSet = CandidateSet))
  }else{
  
  ### Most Uncertain Observation ###
    MostUncertainObs = MostUncertainObservationsFunc(LabelProbabilities = LabelProbabilities, 
                                                     TestSet = TestSet, 
                                                     TrainingSet = TrainingSet, 
                                                     CandidateSet = CandidateSet, 
                                                     ModelType = ModelType,
                                                     SelectorN=SelectorN)
  
  ### Distance Metric - or use norm? ###
  # (dist(rbind(MostUncertainObs[, setdiff(names(MostUncertainObs), c("YStar"))],
  #            CandidateSet[, setdiff(names(CandidateSet), c("ID", "Y", "YStar"))]),
  #      method = "euclidean") %>%
  #   as.matrix)[,1] -> DistMatrix
  # sort(DistMatrix,partial=length(DistMatrix)-1)[length(DistMatrix)-1]
    
  VarCovMatrix = cov(rbind(MostUncertainObs,
                           CandidateSet[, setdiff(names(CandidateSet), c("ID", "Y", "MalDistance"))]))
  MalDistance = try(stats::mahalanobis(x = as.matrix(CandidateSet[, setdiff(names(CandidateSet), c("ID", "Y", "MalDistance"))]),
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



