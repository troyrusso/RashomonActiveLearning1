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

  ### REMEMBER NO INTERCEPT ###

  switch(ModelType,
       Logistic = {
         # Model and Prediction #
         Model = glm(Y ~ . -1, 
                     data = TrainingSet[, setdiff(names(TrainingSet), c("ID"))],
                     family = "binomial")
         TrainingLabelProbabilities = as.matrix(predict(Model, 
                                                newdata = TrainingSet, 
                                                type = "response"))
         TrainingLabelProbabilities = cbind(ID = as.numeric(rownames(TrainingLabelProbabilities)),
                                    Class1 = TrainingLabelProbabilities[,1],
                                    Class2 = 1-TrainingLabelProbabilities[,1])
         TrainingPredictedLabels = 1*(predict(Model, 
                                              newdata = TrainingSet[, setdiff(names(TrainingSet), c("ID"))], 
                                              type = "response")>0.5)+1
       },
       LASSO = {
         # Best Lambda #
         LASSOCV = glmnet(x = as.matrix(TrainingSet[, setdiff(names(TrainingSet), c("Y", "ID"))]),
                          y = as.matrix(TrainingSet$Y),
                          alpha = 1,
                          family = "binomial",
                          intercept = FALSE)
         MinLambda = min(LASSOCV$lambda)
         
         # Model and Prediction #
         Model = glmnet(x = as.matrix(TrainingSet[, setdiff(names(TrainingSet), c("ID","Y"))]),
                        y = as.matrix(TrainingSet$Y),
                        alpha = 1,
                        lambda = MinLambda,
                        family = "binomial",
                        intercept = FALSE)
         
         TrainingLabelProbabilities = predict(Model,
                                      newx = as.matrix(TrainingSet[, setdiff(names(TrainingSet), c("ID","Y"))]),
                                      s = MinLambda,
                                      type = "response")
         TrainingLabelProbabilities = cbind(ID = as.numeric(rownames(TrainingLabelProbabilities)),
                                            TrainingLabelProbabilities)
         TrainingPredictedLabels = (ifelse(TrainingLabelProbabilities > 0.5,1,0)+1)%>% as.factor
         colnames(TrainingLabelProbabilities) = c("ID", paste0("Class", 1:(ncol(TrainingLabelProbabilities)-1)))
         
       },
       Multinomial = {
         # Model and Prediction #
         Model = nnet::multinom(formula = Y ~ ., 
                                data = TrainingSet[, setdiff(names(TrainingSet), c("ID"))],
                                trace = FALSE)
         TrainingLabelProbabilities = predict(Model,
                                              newdata = TrainingSet[, setdiff(names(TrainingSet), c("ID"))],
                                              type = "prob")
         TrainingPredictedLabels = predict(Model,
                                          newdata = dat) %>% as.factor
       },
       MultinomLASSO = {
         # Best Lambda #
         LassoRegression = glmnet(x = as.matrix(TrainingSet[, setdiff(names(TrainingSet), c("ID", "Y"))]),
                                  y = as.matrix(TrainingSet$Y),
                                  alpha = 1,
                                  family = "multinomial",
                                  intercept = FALSE)
         MinLambda = min(LassoRegression$lambda)
         
         # Model and Prediction #
         Model = glmnet(x = as.matrix(TrainingSet[, setdiff(names(TrainingSet), c("ID","Y"))]),
                        y = as.matrix(TrainingSet$Y),
                        alpha = 1,
                        lambda = MinLambda,
                        family = "multinomial",
                        intercept = FALSE)
         TrainingLabelProbabilities = predict(Model,
                                              newx = as.matrix(TrainingSet[, setdiff(names(TrainingSet), c("ID","Y"))]),
                                              s = MinLambda,
                                              type = "response")[,,]
         TrainingLabelProbabilities =  cbind(ID = as.numeric(rownames(TrainingLabelProbabilities)),
                                             TrainingLabelProbabilities)
         colnames(TrainingLabelProbabilities) = c("ID", paste0("Class", 1:(ncol(TrainingLabelProbabilities)-1)))
         
         TrainingPredictedLabels = predict(Model,
                                           newx = as.matrix(TrainingSet[, setdiff(names(TrainingSet), c("ID","Y"))]),
                                           s = MinLambda,
                                           type = "class") %>% as.factor
       },
       RandomForest = {
         Model = randomForest::randomForest(Y ~., data = TrainingSet[, setdiff(names(TrainingSet), c("ID"))])
         TrainingLabelProbabilities = predict(Model, 
                                              TrainingSet[, setdiff(names(TrainingSet), c("ID"))], 
                                              type = "prob")
         TrainingPredictedLabels = predict(Model, 
                                           TrainingSet[, setdiff(names(TrainingSet), c("ID"))])
       }
       
  )
  
  return(list(Model = Model,
              TrainingPredictedLabels = TrainingPredictedLabels,
              TrainingLabelProbabilities = TrainingLabelProbabilities))
  }