### Summary:
### Inputs:
### Output:

# Multinomial #
# MultinomModel = multinom(as.factor(Y) ~ .,
#                 data = TrainingSet[, setdiff(names(TrainingSet), c("ID"))],
#                 trace = FALSE)
# MultinomModelPredicted = predict(MultinomModel,
#                                  newdata = TrainingSet)
# Error[iter] = mean(MultinomModelPredicted != TrainingSet$Y)

ModelTypeSwitchFunc = function(TrainingSet, ModelType){
  switch(ModelType,
       Logistic = {
         Model = glm(Y ~ ., 
                     data = TrainingSet[, setdiff(names(TrainingSet), c("ID"))],
                     family = "binomial")
         PredictedLabels = 1*(predict(Model, 
                                      newdata = TrainingSet, 
                                      type = "response")>0.5)+1
         LabelProbabilities = as.matrix(predict(Model, 
                                                newdata = TrainingSet, 
                                                type = "response"))
         LabelProbabilities = cbind(ID = as.numeric(rownames(LabelProbabilities)),
                                    Class1 = LabelProbabilities[,1], 
                                    Class2 = 1-LabelProbabilities[,1])
       },
       LASSO = {
         # Best Lambda #
         LassoRegression = glmnet(x = as.matrix(TrainingSet[, setdiff(names(TrainingSet), c("Y"))]),
                                  y = as.matrix(TrainingSet$Y),
                                  alpha = 1,
                                  family = "binomial")
         MinLambda = min(LassoRegression$lambda)
         
         # Prediction #
         LabelProbabilities = predict(LassoRegression,
                                      newx = as.matrix(TrainingSet[, setdiff(names(TrainingSet), c("Y"))]),
                                      s = MinLambda,
                                      type = "response")
         PredictedLabels = ifelse(LabelProbabilities > 0.5,1,0)+1
         LabelProbabilities = cbind(ID = as.numeric(rownames(LabelProbabilities)),
                                    Class1 = LabelProbabilities[,1], 
                                    Class2 = 1-LabelProbabilities[,1])
       }
       
  )
  
  return(list(PredictedLabels = PredictedLabels,
              LabelProbabilities = LabelProbabilities))
  }