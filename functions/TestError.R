### Summary:
### Inputs:
### Output:

TestErrorFunction = function(Model, ModelType, TestSet){
  
  
  newX = as.matrix(TestSet[, setdiff(names(TestSet), c("ID","Y"))])
  
  if(ModelType %in% c("Logistic", "LASSO")){
    TestPredictedProbabilities = predict(Model,
                                         newx = newX,
                                         type = "response")
    TestPredictedLabels = ifelse(TestPredictedProbabilities > 0.5,1,0)+1

    TestPredictedProbabilities = cbind(ID = as.numeric(rownames(TestPredictedProbabilities)),
                                       Class1 = TestPredictedProbabilities[,1], 
                                       Class2 = 1-TestPredictedProbabilities[,1])
  }else{print("Need binary outcome right now.")}
  Error = mean(TestPredictedLabels != TestSet$Y)

  return(list(Error = Error,
              TestPredictedProbabilities = TestPredictedProbabilities))
}
