### Summary: Simulates data
### Inputs:
# N: Number of observations
# K: Number of covariates.
# ClassProportion: Proportion of each class
# MeanMatrix: Average of each covariate
# CorrVal: Correlation between variables
### Output:
# dat: A data set

GenerateDataFunc = function(N, K, NClass, ClassProportion, MeanMatrix, CorrVal){
  
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
  TrueBetas = matrix(data = rnorm(n = K*NClass, mean = NClass, sd = 1),
                     nrow = NClass,
                     ncol = K)
  
  # TrueBetas = 1:NClass *  TrueBetas 
  
  ### Covariates ###
  do.call(what = rbind, 
          args = lapply(X = 1:NClass, 
                        FUN = function(c){
                          X = mvrnorm(n = ClassCounts[c],
                                      mu = MeanMatrix,
                                      Sigma = SigmaMatrix)
                          epsilon = rnorm(n = ClassCounts[c], mean = 0, sd = 1)
                                      YStar = X %*% TrueBetas[c,] + epsilon
                                      Y = c
                                      data.frame(Y = as.factor(Y), YStar, X, epsilon)}
                        )
          ) -> dat
  dat = cbind(ID = 1:N, dat)

  ### Return ###
  rownames(TrueBetas) = paste0("Class",1:NClass)
  colnames(TrueBetas) = paste0("X",1:K)
  
  return(list(dat = dat[,setdiff(names(dat), c("YStar", "epsilon"))],
              YStar = dat$YStar,
              TrueBetas = TrueBetas,
              noise = dat$epsilon))
}
