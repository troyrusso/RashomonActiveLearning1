### Summary: Simulates data
### Inputs:
# N: Number of observations
# K: Number of covariates.
# ClassProportion: Proportion of each class
# MeanMatrix: Average of each covariate
# CorrVal: Correlation between variables
### Output:
# dat: A data set

GenerateDataFunc3 = function(N, K, NClass, ClassProportion, MeanMatrix, VarCov){
  
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
  if(NClass>2){
    stop("The current DGP function only supports binary classes.")
  }
  
  ### Correlation Matrix ###
  if(length(VarCov) == 1){
    SigmaMatrix = diag(K)
    SigmaMatrix[SigmaMatrix==0] = VarCov}else if(length(VarCov) != 1){
      SigmaMatrix = VarCov
    }
      
  ### True Betas ###
  TrueBetas = matrix(rnorm(n = K * (NClass - 1), mean = 0, sd = 1),
                     ncol = K)

  ### Predictors ###
  X = MASS::mvrnorm(n = 3*N,
                    mu = MeanMatrix,
                    Sigma = SigmaMatrix)
  
  ### Probabilities ###
  Logit = X %*% t(TrueBetas)
  Probs = 1/(1+exp(-Logit))

  ### Labels ###
  Y = rbinom(n = 3*N, size = 1, prob = Probs)

  ### Preliminary Data Set ###
  PrelimDat = data.frame(Y = as.factor(Y), X = X)
  
  ### Class Proportion ###
  NClassSamples = round(N * ClassProportion)
  IndicesList = lapply(X = 0:(NClass-1),
                       FUN = function(c) sample(x = rownames(PrelimDat[PrelimDat$Y == c, ]),
                                                size = NClassSamples[c+1],
                                                replace = FALSE))
  dat = cbind(ID = 1:N,PrelimDat[unlist(IndicesList), ])
  colnames(dat) = c("ID", "Y", paste0("X", 1:K))
  
  ### Return ###
  return(list(dat = dat,
              TrueBetas = TrueBetas,
              noise = dat$epsilon))
}
