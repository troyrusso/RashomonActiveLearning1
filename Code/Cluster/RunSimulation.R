### Summary:
### Inputs:
### Output:

# Set Up
## Libraries
library(MASS)
library(tidyverse)
library(ggplot2)
library(dplyr)
library(class)
library(glmnet)
library(nnet)
library(RcppAlgos)

## Rm. Var.
rm(list=ls())

## My Functions

source("Code/functions/Selector/BreakingTiesSelector.R")
source("Code/functions/Selector/ModelTypeSwitch.R")
source("Code/functions/Selector/MostUncertainObservation.R")
source("Code/functions/Selector/RandomSelector.R")
source("Code/functions/Selector/RandomStart.R")
source("Code/functions/Selector/SelectorTypeSwitch.R")
source("Code/functions/Selector/StoppingCriteria.R")
source("Code/functions/Selector/TestError.R")
source("Code/functions/Selector/Validation.R")
source("Code/functions/Plots/ActiveLearningPlot.R")
source("Code/functions/Plots/ClassErrorPlot.R")
source("Code/functions/Plots/SelectorTypeComparisonPlotFunc.R")
source("Code/functions/Main/GenerateData.R")
source("Code/functions/Main/GenerateData2.R")
source("Code/functions/Main/GenerateData3.R")
source("Code/functions/Main/RashomonFunc.R")
source("Code/functions/Main/SimulationFunc.R")

## Rashomon TVA Functions
source("rashomon-tva-R-main/R/aggregate.R")
source("rashomon-tva-R-main/R/count.R")
source("rashomon-tva-R-main/R/find_rashomon_set.R")
source("rashomon-tva-R-main/R/globals.R")
source("rashomon-tva-R-main/R/loss.R")
source("rashomon-tva-R-main/R/predictions.R")
source("rashomon-tva-R-main/R/RashomonSet.R")
source("rashomon-tva-R-main/R/rashomontva-package.R")
source("rashomon-tva-R-main/R/utils.R")


seed = 123
set.seed(seed)
N = 1000
K = 4
NClass = 2
ClassProportion = c(3/5, 2/5)
# ClassProportion = rep(1/NClass, NClass)
MeanMatrix = rep(0,K)


## Parser ###
option_list = list(
  make_option(c("--seed"), type = "integer", default = 1, help = "seed", metavar = "integer"),
  make_option(c("--N"), type = "integer", default = 100, help = "Number of observations", metavar = "integer"),
  make_option(c("--K"), type = "integer", default = 3, help = "Number of covariates", metavar = "integer"),
  make_option(c("--NClass"), type = "integer", default = 2, help = "Number of classes", metavar = "integer"),
  make_option(c("--ClassProportion"), type = "complex", default = c(1/2,1/2), help = "Proportion of classes", metavar = "complex"),
  make_option(c("--MeanMatrix"), type = "complex", default = rep(0,3), help = "Mean Matrix", metavar = "co,plex"),
  make_option(c("--CorrelationVal"), type = "numeric", default = -0.4, help = "Mean Matrix", metavar = "numeric"),
  make_option(c("--ModelType"), type = "character", default = "Logistic", help = "Predictor model type", metavar = "character"),
  make_option(c("--SelectorType"), type = "character", default = "Logistic", help = "Selector type", metavar = "character"),
  make_option(c("--TestProportion"), type = "numeric", default = 0.2, help = "Test set proportion", metavar = "numeric"),
  make_option(c("--SelectorN"), type = "numeric", default = -0.4, help = "Number of observations to query", metavar = "numeric"),
  make_option(c("--InitialN"), type = "numeric", default = -0.4, help = "Initial number of classes", metavar = "numeric"),
  make_option(c("--Output"), type = "character", default = NULL, help = "Path to store", metavar = "character")
)
arg.parser = OptionParser(option_list = option_list)
args = parse_args(arg.parser)

## Parameters ##
seed = args$seed
N = args$N
K = args$K
NClass = args$NClass
ClassProportion = args$ClassProportion
MeanMatrix = args$MeanMatrix
CorrelationVal = args$CorrelationVal
ModelType = args$ModelType
SelectorType = args$SelectorType
TestProportion = args$TestProportion
SelectorN = args$SelectorN
InitialN = args$InitialN
Output = args$Output


# seed = 123
# N = 1000
# K = 4
# NClass = 2
# ClassProportion = c(3/5, 2/5)
# MeanMatrix = rep(0,K)
# CorrelationVal = -0.9
# ModelType = "LASSO"
# SelectorType = "BreakingTies"
# TestProportion = 0.2
# SelectorN = 1
# InitialN = 10


### Simulation ###
## Data Generating Process
DGPResults = GenerateDataFunc3(N, K, NClass, ClassProportion, MeanMatrix, VarCov)
dat = DGPResults$dat
TrueBetas = DGPResults$TrueBetas

## Simulation 
SimulationFunc(dat = dat,
               TestProportion = TestProportion,
               SelectorType = "Random",
               SelectorN = SelectorN,
               ModelType = ModelType,
               InitialN = InitialN,
               seed = seed) -> SimResultsRandom

saveRDS(SimulationResults,Output)

