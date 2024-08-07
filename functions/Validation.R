### Summary:
### Inputs:
### Output:


ValidationFunc = function(dat, SelectorType, ModelType){
  if(!(SelectorType %in% c("Random", "BreakingTies"))){
  stop("SelectorType has to be Random or BreakingTies")}
  
  if(!(ModelType %in% c("Logistic", "LASSO", "Multinomial", "MultinomLASSO"))){
  stop("ModelType has to be Logistic, LASSO, Multinomial, or MultinomLASSO")
  }
  
  if(length(unique(dat$Y)) > 2 & ModelType %in% c("Logistic", "LASSO")){
    stop(paste0("There are ", length(unique(dat$Y)), " classes. Change ModelType to Multinomial "))
  }
  
}