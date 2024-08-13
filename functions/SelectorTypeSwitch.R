### Summary:
### Inputs:
### Output:

SelectorTypeSwitchFunc = function(ModelType,
                                  SelectorType, 
                                  SelectorN, 
                                  TestSet,
                                  TrainingSet, 
                                  CandidateSet, 
                                  LabelProbabilities){
  switch(SelectorType,
         Random = {
           SelectorDataSets = RandomSelectorFunc(SelectorN = SelectorN,
                                                 TrainingSet = TrainingSet, 
                                                 CandidateSet = CandidateSet)},
         BreakingTies = {
           SelectorDataSets = BreakingTiesSelectorFunc(ModelType = ModelType,
                                                       LabelProbabilities = LabelProbabilities,
                                                       TestSet = TestSet,
                                                       TrainingSet = TrainingSet,
                                                       CandidateSet = CandidateSet,
                                                       SelectorN = SelectorN)})
  
  return(SelectorDataSets)
}