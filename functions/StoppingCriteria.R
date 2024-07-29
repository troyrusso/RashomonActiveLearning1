### Summary: Randomly selects data until there is one of each class
### Inputs:
# InitialN: Number of observations to sample at each iteartion
# dat: data set
### Output:
# dat: A training set and a candidate set

StoppingCriteriaFunc = function(ErrorVector, ErrorThreshold, VarThreshold, TailN){
  
  if(length(ErrorVector) >= TailN){
    
    ### Condition 1: Low Error ###
    if(all(tail(ErrorVector, TailN) <= ErrorThreshold)){Cond1 = TRUE}else{Cond1 = FALSE}
    
    ### Condition 2: Low Variation ###
    if(var(tail(ErrorVector, TailN)) <= VarThreshold){Cond2 = TRUE}else{Cond2 = FALSE}
  }else{
    Cond1 = FALSE
    Cond2 = FALSE
  }
  
  ### Return ###
  if(Cond1 & Cond2){return(IterStop = length(ErrorVector))}else{return(NULL)}
  }