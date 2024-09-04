### Y and X ###
CovariateList = c("X1", "X2", "X3", "X4")
LabelName = "YStar"

### Data Sets ###
directory = "/Users/simondn/Documents/RashomonActiveLearning/"
TrainingSet = read.csv(paste0(directory,"Code/TrainingSet.csv"))
TestSet = read.csv(paste0(directory,"Code/TestSet.csv"))
dat = rbind(TrainingSet,TestSet)

dat = assign_universal_label(dat, arm_cols = CovariateList)
TrainingSet = dat[dat$ID %in% TrainingSet$ID]
TestSet = dat[dat$ID %in% TestSet$ID]

### Parameters ###
N = nrow(TrainingSet)
M = length(CovariateList)
K = 4
NBins = 3
H = Inf                           # Maximum number of pools/splits
R = NBins+1                       # Bins of each arm (assume 0 exists)
reg = 0.1                         # Penalty on the splits
theta = 2                         # Threshold; determine relative to best model
inactive = 0


### Rashomon Profiles ###
# NewTrainingSet = assign_universal_label(TrainingSet, arm_cols = CovariateList)
aggregate_rashomon_profiles(TrainingSet,                           # TrainingSet
                            value = LabelName,                        # Response names
                            arm_cols = CovariateList,                 # Covariate names
                            M = length(CovariateList),                # Number of covariates
                            H = H,                                    # Maximum number of pools/splits
                            R = R,                                    # Bins of each arm (assume 0 exists)
                            reg = reg,                                # Penalty on the splits
                            theta = theta,                            # Threshold; determine relative to best model
                            inactive = inactive) -> RashomonProfiles  # Losses will always be the last one - (active arms)
RashomonSetNum = length(RashomonProfiles[[1]])
RashomonMakeObjects = make_rashomon_objects(RashomonProfiles)

### Rashomon Loss ###
RashomonLosses = RashomonProfiles[[2]][[length(RashomonProfiles[[2]])]]$losses

### Training Set Prediction ###
TrainingPredictedLabels = sapply(1:RashomonSetNum,  function(x) predict(RashomonMakeObjects[[x]], TrainingSet$universal_label))

### Test Set Predictions ###
# NewTestSet = assign_universal_label(TestSet, arm_cols = CovariateList)
TestPredictedLabels = sapply(1:RashomonSetNum,  function(x) predict(RashomonMakeObjects[[x]], TestSet$universal_label))



