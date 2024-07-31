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
         
         # Model and Prediction #
         Model = glm(Y ~ ., 
                     data = TrainingSet[, setdiff(names(TrainingSet), c("ID"))],
                     family = "binomial")
         TrainingPredictedLabels = 1*(predict(Model, 
                                      newdata = TrainingSet, 
                                      type = "response")>0.5)+1
         TrainingLabelProbabilities = as.matrix(predict(Model, 
                                                newdata = TrainingSet, 
                                                type = "response"))
         TrainingLabelProbabilities = cbind(ID = as.numeric(rownames(TrainingLabelProbabilities)),
                                    Class1 = TrainingLabelProbabilities[,1],
                                    Class2 = 1-TrainingLabelProbabilities[,1])
       },
       LASSO = {
         # Best Lambda #
         LassoRegression = glmnet(x = as.matrix(TrainingSet[, setdiff(names(TrainingSet), c("Y", "ID"))]),
                                  y = as.matrix(TrainingSet$Y),
                                  alpha = 1,
                                  family = "binomial")
         MinLambda = min(LassoRegression$lambda)
         
         # Model and Prediction #
         Model = glmnet(x = as.matrix(TrainingSet[, setdiff(names(TrainingSet), c("ID","Y"))]),
                        y = as.matrix(TrainingSet$Y),
                        alpha = 1,
                        lambda = MinLambda,
                        family = "binomial")
         
         TrainingLabelProbabilities = predict(Model,
                                      newx = as.matrix(TrainingSet[, setdiff(names(TrainingSet), c("ID","Y"))]),
                                      s = MinLambda,
                                      type = "response")
         TrainingPredictedLabels = ifelse(TrainingLabelProbabilities > 0.5,1,0)+1
         TrainingLabelProbabilities = cbind(ID = as.numeric(rownames(TrainingLabelProbabilities)),
                                    Class1 = TrainingLabelProbabilities[,1],
                                    Class2 = 1-TrainingLabelProbabilities[,1])
       }
       
  )
  
  return(list(Model = Model,
              TrainingPredictedLabels = TrainingPredictedLabels,
              TrainingLabelProbabilities = TrainingLabelProbabilities))
  }