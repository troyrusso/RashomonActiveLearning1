### Summary:
### Inputs:
### Output:

SelectorTypeSwitchFunc = function(SelectorType, 
                                  SelectorN, 
                                  TrainingSet, 
                                  CandidateSet, 
                                  LabelProbabilities){
  switch(SelectorType,
         Random = {
           SelectorDataSets = RandomSelectorFunc(SelectorN = SelectorN, TrainingSet, CandidateSet)},
         BreakingTies = {
           SelectorDataSets = BreakingTiesSelectorFunc(ClassProbabilities = LabelProbabilities,
                                                       TrainingSet = TrainingSet,
                                                       CandidateSet = CandidateSet,
                                                       SelectorN = SelectorN)})
  
  return(SelectorDataSets)
}