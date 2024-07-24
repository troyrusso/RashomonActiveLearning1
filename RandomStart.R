### Summary: Randomly selects data until there is one of each class
### Inputs:
# InitialN: Number of observations to sample at each iteartion
# dat: data set
### Output:
# dat: A training set and a candidate set

RandomStartFunc = function(InitialN = 1, dat){
  
  ### Set Up ###
  N = nrow(dat)
  Classes = sort(unique(dat$Label))

  TrainingIndices = sample(1:N, InitialN)
  CandidateIndices = setdiff(1:N, TrainingIndices)
  TrainingSet = dat[TrainingIndices, ]
  CandidateSet = dat[CandidateIndices, ]
  
  ### While Loop ###
  while(length(unique(TrainingSet$Label)) != length(Classes)){
    
    ## Draw ##
    TrainingIndices = c(TrainingIndices, sample(CandidateIndices, InitialN))
    CandidateIndices = setdiff(CandidateIndices, TrainingIndices)
    TrainingSet = dat[TrainingIndices, ]
    CandidateSet = dat[CandidateIndices, ]
  }

  return(list(TrainingSet = TrainingSet,
              CandidateSet = CandidateSet))
}
