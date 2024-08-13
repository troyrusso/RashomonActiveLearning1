### Summary:
### Inputs:
### Output:


ValidationFunc = function(dat, SelectorType, ModelType){
  
  SelectorTypeList = c("Random", "BreakingTies")
  ModelTypeList = c("Logistic", "LASSOClassification", "Multinomial", "MultinomLASSO", "Linear", "LASSORegression")
  
  if(!(SelectorType %in% SelectorTypeList)){
  stop("SelectorType has to be Random or BreakingTies")}
  
  if(!(ModelType %in% ModelTypeList)){
  stop("ModelType has to be Logistic, LASSOClassification, Multinomial, MultinomLASSO, linear")
  }
  
  if(length(unique(dat$Y)) > 2 & ModelType %in% c("Logistic", "LASSO")){
    stop(paste0("There are ", length(unique(dat$Y)), " classes. Change ModelType to Multinomial "))
  }
  
}