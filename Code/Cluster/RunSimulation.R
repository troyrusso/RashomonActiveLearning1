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
library(optparse)


## Rm. Var.
rm(list=ls())

## My Functions
if(exists("directory")){
  source(paste0(directory,"Code/functions/Main/LoadFunctions.R"))
}else if(!exists("directory")){source("Code/functions/Main/LoadFunctions.R")}


### Class Proprtion 

## Parser ###
option_list = list(
  make_option(c("--seed"), type = "integer", default = 1, help = "seed", metavar = "integer"),
  make_option(c("--N"), type = "integer", default = 100, help = "Number of observations", metavar = "integer"),
  make_option(c("--K"), type = "integer", default = 3, help = "Number of covariates", metavar = "integer"),
  make_option(c("--NClass"), type = "integer", default = 2, help = "Number of classes", metavar = "integer"),
  make_option(c("--ClassProportion"), type = "complex", default = NULL, help = "Proportion of classes", metavar = "complex"),
  make_option(c("--CovCorrVal"), type = "numeric", default = -0.4, help = "Mean Matrix", metavar = "numeric"),
  make_option(c("--ModelType"), type = "character", default = "Logistic", help = "Predictor model type", metavar = "character"),
  make_option(c("--SelectorType"), type = "character", default = "Random", help = "Selector type", metavar = "character"),
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
CovCorrVal = args$CovCorrVal
ModelType = args$ModelType
SelectorType = args$SelectorType
TestProportion = args$TestProportion
SelectorN = args$SelectorN
InitialN = args$InitialN
Output = args$Output


### Simulation 
SimulationFunc(N = N,
               K = K,
               NClass = NClass,
               ClassProportion = ClassProportion,
               CovCorrVal = CovCorrVal,
               TestProportion = TestProportion,
               SelectorType = SelectorType,
               SelectorN = SelectorN,
               ModelType = ModelType,
               InitialN = InitialN,
               seed = seed) -> SimulationResults

saveRDS(SimulationResults,Output)

