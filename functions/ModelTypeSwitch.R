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
  formula = paste0()
  

  switch(ModelType,
       Logistic = {
         # Model and Prediction #
         Model = glm(Y ~ ., 
                     data = TrainingSet[, setdiff(names(TrainingSet), c("ID", "YStar"))],
                     family = "binomial")
         TrainingLabelProbabilities = as.matrix(predict(Model, 
                                                newdata = TrainingSet, 
                                                type = "response"))
         TrainingLabelProbabilities = cbind(ID = as.numeric(rownames(TrainingLabelProbabilities)),
                                    Class1 = TrainingLabelProbabilities[,1],
                                    Class2 = 1-TrainingLabelProbabilities[,1])
         TrainingPredictedLabels = 1*(predict(Model, 
                                              newdata = TrainingSet[, setdiff(names(TrainingSet), c("ID", "YStar"))], 
                                              type = "response")>0.5)+1
       },
       LASSO = {
         # Best Lambda #
         LassoRegression = glmnet(x = as.matrix(TrainingSet[, setdiff(names(TrainingSet), c("Y", "ID", "YStar"))]),
                                  y = as.matrix(TrainingSet$Y),
                                  alpha = 1,
                                  family = "binomial")
         MinLambda = min(LassoRegression$lambda)
         
         # Model and Prediction #
         Model = glmnet(x = as.matrix(TrainingSet[, setdiff(names(TrainingSet), c("ID","Y", "YStar"))]),
                        y = as.matrix(TrainingSet$Y),
                        alpha = 1,
                        lambda = MinLambda,
                        family = "binomial")
         
         TrainingLabelProbabilities = predict(Model,
                                      newx = as.matrix(TrainingSet[, setdiff(names(TrainingSet), c("ID","Y", "YStar"))]),
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
                                data = TrainingSet[, setdiff(names(TrainingSet), c("ID", "YStar"))],
                                trace = FALSE)
         TrainingLabelProbabilities = predict(Model,
                                              newdata = TrainingSet[, setdiff(names(TrainingSet), c("ID", "YStar"))],
                                              type = "prob")
         TrainingPredictedLabels = predict(Model,
                                          newdata = dat) %>% as.factor
       },
       MultinomLASSO = {
         # Best Lambda #
         LassoRegression = glmnet(x = as.matrix(TrainingSet[, setdiff(names(TrainingSet), c("ID", "Y", "YStar"))]),
                                  y = as.matrix(TrainingSet$Y),
                                  alpha = 1,
                                  family = "multinomial")
         MinLambda = min(LassoRegression$lambda)
         
         # Model and Prediction #
         Model = glmnet(x = as.matrix(TrainingSet[, setdiff(names(TrainingSet), c("ID","Y", "YStar"))]),
                        y = as.matrix(TrainingSet$Y),
                        alpha = 1,
                        lambda = MinLambda,
                        family = "multinomial")
         TrainingLabelProbabilities = predict(Model,
                                              newx = as.matrix(TrainingSet[, setdiff(names(TrainingSet), c("ID","Y", "YStar"))]),
                                              s = MinLambda,
                                              type = "response")[,,]
         TrainingLabelProbabilities =  cbind(ID = as.numeric(rownames(TrainingLabelProbabilities)),
                                             TrainingLabelProbabilities)
         colnames(TrainingLabelProbabilities) = c("ID", paste0("Class", 1:(ncol(TrainingLabelProbabilities)-1)))
         
         TrainingPredictedLabels = predict(Model,
                                           newx = as.matrix(TrainingSet[, setdiff(names(TrainingSet), c("ID","Y", "YStar"))]),
                                           s = MinLambda,
                                           type = "class") %>% as.factor
       },
       Linear = {
         
         Model = lm(YStar ~.,
                    data = TrainingSet[, setdiff(names(TrainingSet), c("ID", "Y"))])
         TrainingLabelProbabilities = NA
         TrainingPredictedLabels = predict(Model, 
                                           newdata = TrainingSet[, setdiff(names(TrainingSet), c("ID", "Y"))])
       }

  )
  
  return(list(Model = Model,
              TrainingPredictedLabels = TrainingPredictedLabels,
              TrainingLabelProbabilities = TrainingLabelProbabilities))
  }