### Summary: Randomly selects data until there is one of each class
### Inputs:
# InitialN: Number of observations to sample at each iteartion
# dat: data set
### Output:
# dat: A training set and a candidate set

RandomSelectorFunc = function(SelectorN = 1, TrainingSet, CandidateSet){
  
  ### Sample ###
  SelectedIndex = sample(CandidateSet$ID, 1)
  SelectedObservation = CandidateSet[CandidateSet$ID == SelectedIndex,]

  ### Set Mutation ###
  TrainingSet = rbind(TrainingSet, SelectedObservation)
  CandidateSet = CandidateSet[CandidateSet$ID != SelectedIndex,]

  return(list(TrainingSet = TrainingSet,
              CandidateSet = CandidateSet))
}
