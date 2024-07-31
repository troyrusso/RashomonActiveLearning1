### Summary:
### Inputs:
### Output:


ValidationFunc = function(SelectorType, ModelType){
  if(!(SelectorType %in% c("Random", "BreakingTies"))){
  stop("SelectorType has to be Random or BreakingTies")}
  
  if(!(ModelType %in% c("Logistic", "LASSO"))){
  stop("SelectorType has to be Random or BreakingTies")
}
  
}