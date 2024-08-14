### Summary:
### Inputs:
### Output:

TestErrorFunction = function(Model, ModelType, TestSet){
  
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
                                                newx = as.matrix(TestSet[, setdiff(names(TestSet), c("ID","Y"))]),
                                                type = "response")
           TestPredictedLabels = ifelse(TestPredictedProbabilities > 0.5,1,0)
           
           TestPredictedProbabilities = cbind(ID = as.numeric(rownames(TestPredictedProbabilities)),
                                              Class1 = TestPredictedProbabilities[,1], 
                                              Class2 = 1-TestPredictedProbabilities[,1])
         },
         Multinomial = {
           TestPredictedProbabilities = predict(Model,
                                                newdata = TestSet[, setdiff(names(TestSet), c("ID"))],
                                                type = "prob")
           TestPredictedLabels = predict(Model,
                                         newdata = TestSet[, setdiff(names(TestSet), c("ID"))])
         },
         MultinomLASSO = {
           TestPredictedProbabilities = predict(Model,
                                                newx = as.matrix(TestSet[, setdiff(names(TestSet), c("ID","Y"))]),
                                                type = "response")[,,]
           TestPredictedLabels = predict(Model,
                                             newx = as.matrix(TestSet[, setdiff(names(TestSet), c("ID","Y"))]),
                                             type = "class") %>% as.factor
         }
  )

  ### Error ###
  Error = mean(TestPredictedLabels != TestSet$Y) # Overall Error
  ClassError = tapply(X = 1:length(TestSet$Y), # Class Error
                      INDEX = TestSet$Y, 
                      FUN = function(i) mean(TestPredictedLabels[i] != TestSet$Y[i])) %>%
    as.vector
  
  return(list(Error = Error,
              ClassError = ClassError,
              TestPredictedLabels = TestPredictedLabels,
              TestPredictedProbabilities = TestPredictedProbabilities))
}
