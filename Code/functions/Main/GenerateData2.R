### Summary: Simulates data
### Inputs:
# N: Number of observations
# K: Number of covariates.
# ClassProportion: Proportion of each class
# MeanMatrix: Average of each covariate
# CorrVal: Correlation between variables
### Output:
# dat: A data set

GenerateDataFunc2 = function(N, K, NClass, ClassProportion, MeanMatrix, CorrVal){
  
  ### Validations ###
  if(length(ClassProportion) != NClass){
    print(paste0("The length of ClassProportion has to be ", NClass ,"."))
  }
  if(round(sum(ClassProportion), 1e-10) != 1){
    print("The sum of ClassProportion has to be 1")
  }
  if(length(MeanMatrix) != K){
    print(paste0("The length of Betas has to be ", K ,"."))
  }
  
  ### Correlation Matrix ###
  SigmaMatrix = diag(K)
  SigmaMatrix[SigmaMatrix==0] = CorrVal
  
  ### Class Counts ###
  ClassCounts = round(N * ClassProportion)
  ClassCounts[NClass] = N - sum(ClassCounts[1:(NClass-1)])
  
  ### True Betas ###
  TrueBetas = rnorm(n = K+1, mean = NClass, sd = 1)
  
  ### Covariates ###
  X = MASS::mvrnorm(n = N,
              mu = MeanMatrix,
              Sigma = SigmaMatrix)
  epsilon = rnorm(n = N, mean = 0, sd = 1)
  YStar = TrueBetas[1] + X %*% TrueBetas[c(-1)] + epsilon
  dat = data.frame(YStar,X, epsilon)
  

  ### Labels ###
  Y = rep(1:length(ClassCounts), ClassCounts)
  dat = cbind(ID = 1:N, Y = as.factor(Y), arrange(dat,YStar))

  ### Return ###
  return(list(YStar = dat$YStar,
              # dat = dat[,setdiff(names(dat),c("YStar", "epsilon"))],
              dat = dat[,setdiff(names(dat),c("epsilon"))],
              TrueBetas = TrueBetas,
              noise = dat$epsilon))
}
# YStar - (TrueBetas[1] + as.matrix(dat[c(3,4)]) %*% TrueBetas[c(-1)] + noise)


# dat = dat[,setdiff(names(dat),c("YStar"))]
# ScratchModel = glm(Y ~ .,  dat[, setdiff(names(dat), c("ID"))], family = "binomial")
# ScratchPredicted = 1*(predict(ScratchModel, newdata = dat, type = "response")>0.5)+1
# mean(ScratchPredicted != dat$Y)

