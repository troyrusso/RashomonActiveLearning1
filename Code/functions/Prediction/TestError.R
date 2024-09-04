### Summary:
### Inputs:
### Output:

TestErrorFunction = function(Model, ModelType, TestSet, CovariateList, LabelName){
  
  ### Set Up ###
  NClass = length(unique(TestSet$Y))
  ClassError = numeric(NClass)
  
  ### Switch ###
  switch(ModelType,
         Logistic = {
           TestPredictedProbabilities = as.matrix(predict(Model, 
                                                          newdata = TestSet, 
                                                          type = "response"))
           TestPredictedLabels = 1*(predict(Model, 
                                            newdata = TestSet, 
                                            type = "response")>0.5)
           TestPredictedProbabilities = cbind(ID = as.numeric(rownames(TestPredictedProbabilities)),
                                              Class1 = TestPredictedProbabilities[,1], 
                                              Class2 = 1-TestPredictedProbabilities[,1])
         },
         LASSO = {
           TestPredictedProbabilities = predict(Model,
                                                newx = as.matrix(TestSet[, CovariateList]),
                                                type = "response")
           TestPredictedLabels = ifelse(TestPredictedProbabilities > 0.5,1,0)
           
           TestPredictedProbabilities = cbind(ID = as.numeric(rownames(TestPredictedProbabilities)),
                                              Class1 = TestPredictedProbabilities[,1], 
                                              Class2 = 1-TestPredictedProbabilities[,1])
         },
         Multinomial = {
           TestPredictedProbabilities = predict(Model,
                                                newdata = TestSet,
                                                type = "prob")
           TestPredictedLabels = predict(Model,
                                         newdata = TestSet)
         },
         MultinomLASSO = {
           TestPredictedProbabilities = predict(Model,
                                                newx = as.matrix(TestSet[, CovariateList]),
                                                type = "response")[,,]
           TestPredictedLabels = predict(Model,
                                         newx = as.matrix(TestSet[, CovariateList]),
                                         type = "class") %>% as.factor
         },
         RandomForest = {
           TestPredictedLabels = predict(Model, TestSet)
           TestPredictedProbabilities = predict(Model, TestSet, type = "prob")
           TestPredictedProbabilities = cbind(ID = as.numeric(rownames(TestPredictedProbabilities)),
                                              Class1 = TestPredictedProbabilities[,1], 
                                              Class2 = 1-TestPredictedProbabilities[,1])
         },
         Linear = {
           ModelPrediction = predict(Model, newdata = TestSet, se.fit = TRUE)
           TestPredictedLabels = ModelPrediction$fit
           TestPredictedProbabilities = ModelPrediction$se.fit
         },
         RashomonLinear = {
           RashomonSetNum = length(Model)
           NewTestSet = assign_universal_label(TestSet, arm_cols = CovariateList)
           
           # policies = create_policies_from_data(TestSet, CovariateList)
           # sigma <- initialize_sigma(M = length(CovariateList), R = RashomonParameters$R)
           # hasse_edges <- lattice_edges(sigma, policies)
           
           # sapply(1:RashomonSetNum,  function(x) predict(Model[[x]], NewTestSet$universal_label))
           TestPredictedProbabilities = NULL
         }
  )

  ### Error ###
  if(ModelType %in% c("Linear","RashomonLinear")){
    Error = mean((TestPredictedLabels - TestSet$YStar)^2)
    ClassError = tapply(X = 1:length(TestSet$Y), # Class Error
                        INDEX = TestSet$Y, 
                        FUN = function(i) mean((TestPredictedLabels[i] - TestSet$YStar[i])^2)) %>%
      as.vector
  }else if(!(ModelType %in% c("Linear","RashomonLinear"))){
    Error = mean(TestPredictedLabels != TestSet$Y) # Overall Error
    ClassError = tapply(X = 1:length(TestSet$Y), # Class Error
                        INDEX = TestSet$Y, 
                        FUN = function(i) mean(TestPredictedLabels[i] != TestSet$Y[i])) %>%
      as.vector
  }
  
  return(list(Error = Error,
              ClassError = ClassError,
              TestPredictedLabels = TestPredictedLabels,
              TestPredictedProbabilities = TestPredictedProbabilities))
}
