import xgboost as xgb

def XGBoostRegressorFunction(df_Train):
    XGBModel = xgb.XGBRegressor(random_state=42, n_estimators=100)
    XGBModel.fit(df_Train.loc[:, df_Train.columns != "Y"], df_Train["Y"])
    return XGBModel
