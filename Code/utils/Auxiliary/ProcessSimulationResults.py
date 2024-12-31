# Summary: A python script to extract the error and time for the active learning simulation. It accesses each of the .pkl result files
#          from the simulations, and places each error (time) into a row in the ErrorMatrix.csv (TimeMatrix.csv) file.
# Input: 
#   DataType: A string that indicates either "Simulate" for the simulation or the name of the DataFrame in the Data folder.
#   ModelType: Predictive model. Examples can be LinearRegression or RandomForestRegresso.
#   Categories: The last identifying portion of the results file.
#               For the DUREAL, UNREAL, and RandomForests methods, the respective inputs are
#               {"MTTreeFarms_UEI0_NE100_Reg0.01_RBA0.01.pkl", 
#                "MTTreeFarms_UEI1_NE100_Reg0.01_RBA0.01.pkl",
#                "MTRandomForestClassification_UEI0_NE100_Reg0.01_RBA0.01.pkl"}
# Output: Outputs the matrices ErrorMatrix and TimeMatrix into the ProcessedResults folder.

### Import libraries ###
import os
import pickle
import argparse
import numpy as np
import pandas as pd

### Extract Error and Time Function ###
def ExtractInformation(files):

    ### Set Up ###
    ErrorVec = []
    TimeVec = []
    SelectionHistoryVec = []
    AllTreeCountVec = []
    UniqueTreeCounttVec = []
    for file in files:
        try:
            with open(file, "rb") as f:
                data = pickle.load(f)
                ErrorVec.append(data["ErrorVec"])
                TimeVec.append(data["ElapsedTime"])
                SelectionHistoryVec.append(data["SelectionHistory"])
                AllTreeCountVec.append(data["TreeCount"]["AllTreeCount"])
                UniqueTreeCounttVec.append(data["TreeCount"]["UniqueTreeCount"])
        except Exception as e:
            print(f"Error loading file {file}: {e}")
    return np.array(ErrorVec), np.array(TimeVec), np.array(SelectionHistoryVec), np.array(AllTreeCountVec), np.array(UniqueTreeCounttVec)

### Parser ###
parser = argparse.ArgumentParser(description="Aggregate simulation results.")
parser.add_argument("--DataType", type=str, required=True, help="Type of data.")
parser.add_argument("--ModelType", type=str, required=True, help="Prediction model type.")
parser.add_argument("--Categories", type=str, required=True, help="Single category string.")
args = parser.parse_args()

### Set Up ###
cwd = os.getcwd()
ResultsDirectory = os.path.join(cwd, "Results", args.DataType, args.ModelType)
OutputDirectory = os.path.join(ResultsDirectory, "ProcessedResults")
RawDirectory = os.path.join(ResultsDirectory, "Raw")
Category = args.Categories

### Extract File Names ###
CategoryFileNames = []
for filename in os.listdir(RawDirectory):
    if filename.endswith(".pkl") and filename.endswith(Category):
        CategoryFileNames.append(os.path.join(RawDirectory, filename))

### Extract Data ###
if not CategoryFileNames:
    print(f"Warning: No files found for category {Category}. Exiting.")
    exit(1)
print(f"Processing category: {Category} with {len(CategoryFileNames)} files")
ErrorVec, TimeVec, SelectionHistoryVec, AllTreeCountVec, UniqueTreeCounttVec = ExtractInformation(CategoryFileNames)
ErrorMatrix = pd.DataFrame(ErrorVec.squeeze())
TimeMatrix = pd.DataFrame(TimeVec.squeeze())
SelectionHistoryVec = pd.DataFrame(SelectionHistoryVec.squeeze())
AllTreeCountVec = pd.DataFrame(AllTreeCountVec.squeeze())
UniqueTreeCounttVec = pd.DataFrame(UniqueTreeCounttVec.squeeze())

### Save ###
ErrorMatrix.to_csv(os.path.join(OutputDirectory, "ErrorVec", f"{Category.replace('.pkl', '')}_ErrorMatrix.csv"), index=False)
TimeMatrix.to_csv(os.path.join(OutputDirectory, "ElapsedTime", f"{Category.replace('.pkl', '')}_TimeMatrix.csv"), index=False)
AllTreeCountVec.to_csv(os.path.join(OutputDirectory, "TreeCount", f"{Category.replace('.pkl', '')}_AllTreeCount.csv"), index=False)
UniqueTreeCounttVec.to_csv(os.path.join(OutputDirectory, "TreeCount", f"{Category.replace('.pkl', '')}_UniqueTreeCount.csv"), index=False)
SelectionHistoryVec.to_csv(os.path.join(OutputDirectory, "SelectionHistory", f"{Category.replace('.pkl', '')}_SelectionHistory.csv"), index=False)
print(f"Saved {Category} files!")
