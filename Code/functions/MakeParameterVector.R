### Summary: 
### Inputs:
### Output:

### Set Up ###
library(tidyverse)
rm(list=ls())
dir = paste0("/Users/simondn/Documents/RashomonActiveLearning/Code/Cluster/")

seed = 1234567890
N = 1000
K = 4
NClass = 2
# ClassProportion = c(3/5, 2/5)
ClassProportion = rep(1/NClass, NClass)
MeanMatrix = rep(0,K)
CovCorrVal = -0.9
TestProportion = 0.2
SelectorN = 1
InitialN = 10
ModelType = "LASSO" #Supported Types: Logistic, LASSO, Multinomial, MultinomLASSO, RandomForest
NBins = 3

ExpandGridCombinations = expand.grid(seed = seq(1:20),
                                     N = c(1000),
                                     K = c(4),
                                     NClass = c(2),
                                     ClassProportion = c(NA),
                                     CovCorrVal = c(0),
                                     NBins = c(3),
                                     ModelType = c("LASSO", "Logistic"),
                                     SelectorType = c("Random", "BreakingTies"),
                                     TestProportion = c(0.2),
                                     SelectorN = c(1),
                                     InitialN = c(10))

### Run SLURM Simulations ###
Simulation_Combinations = ExpandGridCombinations %>%
  mutate(JobName = paste0("Sim", "_",
                          seed, "_",
                          N, "_",
                          K, "_",
                          NClass, "_",
                          ClassProportion, "_",
                          CovCorrVal, "_",
                          NBins, "_",
                          ModelType, "_",
                          SelectorType, "_",
                          TestProportion, "_",
                          SelectorN, "_",
                          InitialN),
         Output = paste0("Results/",
                         seed, "_",
                         N, "_",
                         K, "_",
                         NClass, "_",
                         ClassProportion, "_",
                         CovCorrVal, "_",
                         NBins, "_",
                         ModelType, "_",
                         SelectorType, "_",
                         TestProportion, "_",
                         SelectorN, "_",
                         InitialN, 
                         ".rds"))
write.csv(Simulation_Combinations, file = paste0(dir,"ParameterVectorALL.csv"))





