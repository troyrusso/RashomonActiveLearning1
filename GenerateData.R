library(MASS)
### Summary: Simulates data
### Inputs:
# N: Number of observations
# K: Number of covariates.
# ClassProportion: Proportion of each class
# Betas: True coefficient values
# MeanMatrix: Average of each covariate
# CorrVal: Correlation between variables
### Output:
# dat: A data set

rm(list=ls())
GenerateData = function(N, K, NClass, ClassProportion, Betas, MeanMatrix, CorrVal){
  
  ### Validations ###
  ## Beta ##
  if(length(Betas) != K){
    print(paste0("The length of Betas has to be ", K ,"."))
  }
  
  ## Class Proportion ##
  if(length(ClassProportion) != NClass){
    print(paste0("The length of ClassProportion has to be ", NClass ,"."))
  }
  if(sum(ClassProportion) != 1){
    print("The sum of ClassProportion has to be 1")
  }
  
  ### Correlation Matrix ###
  SigmaMatrix = diag(K)
  SigmaMatrix[SigmaMatrix==0] = CorrVal
  
  ### Data ###
  X = mvrnorm(n = N,
              mu = MeanMatrix,
              Sigma = SigmaMatrix)
  epsilon = rnorm(n = N, mean = 0, sd = 1)
  YStar = X %*% Betas + epsilon

  ### Class Assignment ###
  ClassCounts = round(N*ClassProportion)
  ClassCounts[NClass] = N - sum(ClassCounts[1:(NClass-1)])
  Y = as.factor(rep(1:NClass, times = ClassCounts))
  dat = data.frame(Y,X)

  ### Return ###
  return(dat)
}


