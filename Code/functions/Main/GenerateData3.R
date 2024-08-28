### Summary: Simulates data
### Inputs:
# N: Number of observations
# K: Number of covariates.
# ClassProportion: Proportion of each class
# MeanMatrix: Average of each covariate
# CorrVal: Correlation between variables
### Output:
# dat: A data set

GenerateDataFunc3 = function(N, K, NClass, ClassProportion, MeanMatrix, CovCorrVal){
  
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
  if(K == 1){
    print("Need at least two covariates.")
  }
  
  ### Correlation Matrix ###
  # if(length(VarCov) == 1){
  #   SigmaMatrix = diag(K)
  #   SigmaMatrix[SigmaMatrix==0] = VarCov}else if(length(VarCov) != 1){
  #     SigmaMatrix = VarCov
  #   }
  SigmaMatrix = diag(K)
  SigmaMatrix[1,2] = CovCorrVal
  SigmaMatrix[2,1] = CovCorrVal
      

  ### True Betas ###
  TrueBetas = matrix(rnorm(n = K * (NClass - 1), mean = 0, sd = 1),
                     ncol = K)

  ### Predictors ###
  X = MASS::mvrnorm(n = NClass*N,
                    mu = MeanMatrix,
                    Sigma = SigmaMatrix)
  
  ### Probabilities ###
  Logit = X %*% t(TrueBetas)
  Logit = cbind(0, Logit)#
  Probs = exp(Logit)/rowSums(exp(Logit))#

  # ### Labels ###
  Y = apply(Probs, 1, function(p) sample(1:NClass, size = 1, prob = p))-1
  
  # ### Preliminary Data Set ###
  PrelimDat = data.frame(Y = as.factor(Y), X = X)
  
  ### Class Proportion ###
  NClassSamples = round(N * ClassProportion)
  NClassSamples[1] = NClassSamples[1]+ (N - sum(NClassSamples))
  IndicesList = lapply(X = 0:(NClass-1),
                       FUN = function(c) sample(x = rownames(PrelimDat[PrelimDat$Y == c, ]),
                                                size = NClassSamples[c+1],
                                                replace = FALSE))
  dat = cbind(ID = 1:N,PrelimDat[unlist(IndicesList), ])
  colnames(dat) = c("ID", "Y", paste0("X", 1:K))
  rownames(dat) = dat$ID
  
  ### Return ###
  return(list(dat = dat,
              TrueBetas = TrueBetas,
              noise = dat$epsilon))
}
