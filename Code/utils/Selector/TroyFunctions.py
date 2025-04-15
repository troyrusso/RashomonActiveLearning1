# Summary: Loads the three greedy sampling methods from Wu, Lin, and Huang (2018). 
#   GSx samples based on the covariate space, GSy based on the output space, and iGS on both.
# Input:
#   df_Train: The training set.
#   df_Candidate: The candidate set.
#   Model: The predictive model.
#   distance: The distance metric.
# Output:
#   IndexRecommendation: The index of the recommended observation from the candidate set to be queried.


### Libraries ###
import numpy as np
import pandas as pd
from scipy.spatial.distance import cdist

### GSx ###
def GSxFunctionAverage(df_Train, df_Candidate, distance = "euclidean"):

    ### Calculate n*m distance from df_Candidate_n to df_Train_m
    d_nmX = cdist(df_Candidate.loc[:,df_Candidate.columns!= "Y"], df_Train.loc[:,df_Train.columns!= "Y"], metric = distance)

    ### Find the nearest neighbor for each of the n observation in df_Train_n ###
    d_nX = d_nmX.mean(axis=1)

    ### Return the index of the furthest AVERAGE neighbor ###
    MaxRowNumber = np.argmax(d_nX)
    IndexRecommendation = df_Candidate.iloc[[MaxRowNumber]].index[0]

    ### Output ###
    Output = {"IndexRecommendation": float(IndexRecommendation)}
    return(Output)

### GSy ###
def GSyFunctionAverage(df_Train, df_Candidate, Model, distance = "euclidean"):  ### NOTE: or should df_Train be df_Test

    ### Prediction ###
    if "[APARA'S PACKAGE]" in str(type(Model)):                                                                 # TODO: Rashomon
        # Predictions = Model.predict(df_Candidate.loc[:, df_Candidate.columns != "Y"])
        pass
    else:                                                                                                       # Not Rashomon
        Predictions = Model.predict(df_Candidate.loc[:, df_Candidate.columns != "Y"])

    ### Calculate the difference between f(x_n) and y_m ###
    d_nmY = cdist(Predictions.reshape(-1,1), df_Train["Y"].values.reshape(-1,1), metric = distance)

    ### Return the index of the furthest average error ###
    d_nY = d_nmY.mean(axis=1)
    MaxRowNumber = np.argmax(d_nY)
    IndexRecommendation = df_Candidate.iloc[[MaxRowNumber]].index[0]

    ### Output ###
    Output = {"IndexRecommendation": float(IndexRecommendation)}
    return(Output)
    
### iGS ###
def iGSFunctionAverage(df_Train, df_Candidate, Model, distance = "euclidean"):

    ### GSx ###
    d_nmX = cdist(df_Candidate.loc[:,df_Candidate.columns!= "Y"], df_Train.loc[:,df_Train.columns!= "Y"], metric = distance)
    d_nX = d_nmX.mean(axis=1)

    ### GSy ###
    ## Prediction ##
    if "[APARA'S PACKAGE]" in str(type(Model)):                                                                 # TODO: Rashomon
        # Predictions = Model.predict(df_Candidate.loc[:, df_Candidate.columns != "Y"])
        pass
    else:                                                                                                       # Not Rashomon
        Predictions = Model.predict(df_Candidate.loc[:, df_Candidate.columns != "Y"])
    d_nmY = cdist(Predictions.reshape(-1,1), df_Train["Y"].values.reshape(-1,1), metric = distance)
    d_nY = d_nmY.mean(axis=1)

    ### iGS ###
    d_nXY = d_nX*d_nY
    MaxRowNumber = np.argmax(d_nXY)
    IndexRecommendation = df_Candidate.iloc[[MaxRowNumber]].index[0]

    ### Output ###
    Output = {"IndexRecommendation": float(IndexRecommendation)}
    return(Output)

def iGSFunctionAverageStandardized(df_Train, df_Candidate, Model, distance="euclidean"):

    ### GSx ###
    d_nmX = cdist(
        df_Candidate.loc[:, df_Candidate.columns != "Y"],
        df_Train.loc[:, df_Train.columns != "Y"],
        metric=distance
    )
    d_nX = d_nmX.mean(axis=1)

    ### GSy ###
    # Prediction: Choose based on your Model type
    if "[APARA'S PACKAGE]" in str(type(Model)):
        # Predictions = Model.predict(df_Candidate.loc[:, df_Candidate.columns != "Y"])
        pass  # Adjust according to your needs
    else:
        Predictions = Model.predict(df_Candidate.loc[:, df_Candidate.columns != "Y"])
    d_nmY = cdist(
        Predictions.reshape(-1, 1),
        df_Train["Y"].values.reshape(-1, 1),
        metric=distance
    )
    d_nY = d_nmY.mean(axis=1)

    ### Standardize the Distances ###
    # Compute the z-scores for each set of distances
    # epsilon to avoid divide by zero error
    epsilon = 1e-8
    z_nX = (d_nX - np.mean(d_nX)) / (np.std(d_nX) + epsilon)
    z_nY = (d_nY - np.mean(d_nY)) / (np.std(d_nY) + epsilon)

    # Add the standardized distances instead of multiplying
    score = z_nX + z_nY

    ### iGS: Select the candidate with the highest score ###
    MaxRowNumber = np.argmax(score)
    IndexRecommendation = df_Candidate.iloc[[MaxRowNumber]].index[0]

    ### Output ###
    Output = {"IndexRecommendation": float(IndexRecommendation)}
    return Output


def iGSFunctionStandardized(df_Train, df_Candidate, Model, distance="euclidean"):
    ### GSx ###
    d_nmX = cdist(
        df_Candidate.loc[:, df_Candidate.columns != "Y"],
        df_Train.loc[:, df_Train.columns != "Y"],
        metric=distance
    )
    d_nX = d_nmX.min(axis=1)

    ### GSy ###
    # Prediction: Choose based on your Model type
    if "[APARA'S PACKAGE]" in str(type(Model)):
        # Predictions = Model.predict(df_Candidate.loc[:, df_Candidate.columns != "Y"])
        pass  # Adjust according to your needs
    else:
        Predictions = Model.predict(df_Candidate.loc[:, df_Candidate.columns != "Y"])
    d_nmY = cdist(
        Predictions.reshape(-1, 1),
        df_Train["Y"].values.reshape(-1, 1),
        metric=distance
    )
    d_nY = d_nmY.min(axis=1)

    ### Standardize the Distances ###
    # Compute the z-scores for each set of distances
    # epsilon to avoid divide by zero error
    epsilon = 1e-8
    z_nX = (d_nX - np.mean(d_nX)) / (np.std(d_nX) + epsilon)
    z_nY = (d_nY - np.mean(d_nY)) / (np.std(d_nY) + epsilon)

    # Add the standardized distances instead of multiplying
    score = z_nX + z_nY

    ### iGS: Select the candidate with the highest score ###
    MaxRowNumber = np.argmax(score)
    IndexRecommendation = df_Candidate.iloc[[MaxRowNumber]].index[0]

    ### Output ###
    Output = {"IndexRecommendation": float(IndexRecommendation)}
    return Output