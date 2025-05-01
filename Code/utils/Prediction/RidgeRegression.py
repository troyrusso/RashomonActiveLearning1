# Summary: Initializes and fits a ridge regression model.
# Input:
#   df_Train: The training data.
#   alpha_val: Ridge regression penalty.
# Output: RidgeRegressionModel: A ridge regression model.

### Libraries ###
from sklearn.linear_model import Ridge

### Function ###
#this is hard coded rn change if we don't want
def RidgeRegressionFunction(df_Train, alpha_val = 0.01):
    RidgeRegressionModel = Ridge(alpha = alpha_val)
    RidgeRegressionModel.fit(df_Train.loc[:, df_Train.columns != "Y"], df_Train["Y"])
    return RidgeRegressionModel