# Summary: Runs active learning procedure by querying candidate observations from df_Candidate and adding them to the training set df_Train.
# Input: A dictionary SimulationConfigInputUpdated with the following keys and values:
#   DataFileInput: A string that indicates either "Simulate" for the simulation or the name of the DataFrame in the Data folder.
#   df_Train: The given train dataset from the function TrainTestCandidateSplit in the script OneIterationFunction.
#   df_Test: The given test dataset from the function TrainTestCandidateSplit in the script OneIterationFunction.
#   df_Candidate: The given candidate dataset from the function TrainTestCandidateSplit in the script OneIterationFunction.
#   Seed: Seed for reproducability.
#   TestProportion: Proportion of the data that is reserved for testing.
#   CandidateProportion: Proportion of the data that is initially "unseen" and later added to the training set.
#   SelectorType: Selector type. Examples can be GSx, GSy, or PassiveLearning.
#   ModelType: Predictive model. Examples can be LinearRegression or RandomForestRegresso.
#   UniqueErrorsInput: A binary input indicating whether to prune duplicate trees in TreeFarms.
#   n_estimators: The number of trees for a random forest.
#   regularization: Penalty on the number of splits in a tree.
#   rashomon_bound_adder: A float indicating the Rashomon threshold: (1+\epsilon)*OptimalLoss
#   Type: A string {"Regression", "Classification"} indicating the prediction objective.
# Output:
#   ErrorVec: A 1xM vector of errors with M being the number of observations in df_Candidate. 
#   SelectedObservationHistory: The index of the queried candidate observation at each iteration
#   TreeCount: A dictionary that contains two keys: {AllTreeCount, UniqueTreeCount} indicating
#                          the number of trees in the Rashomon set from TreeFarms and the number of unique classification patterns.

### Import functions ###
from utils.Main import *
from utils.Selector import *
from utils.Auxiliary import *
from utils.Prediction import *
import pandas as pd
def linear_schedule(i, T):
                return i / T

### Function ###
def LearningProcedure(SimulationConfigInputUpdated):

    ### Set Up ###
    ErrorVec = []
    SelectedObservationHistory = []
    TreeCount = {"AllTreeCount": [], "UniqueTreeCount": []}

    #for adaptive
    prev_error = None
    SimulationConfigInputUpdated["w"] = 0.5

    ### Algorithm ###
    #for i in range(len(SimulationConfigInputUpdated["df_Candidate"])):
    T = len(SimulationConfigInputUpdated["df_Candidate"])
    for i in range(T):

        selected = SimulationConfigInputUpdated["SelectorType"]
        if selected.startswith("WiGSFunction"):
        #       SimulationConfigInputUpdated["SelectorType"] = "WiGSFunction"
        # ── SCHEDULING INJECTION ─────────────────────────────────────
        # linear schedule from 0→1 over T steps (use i+1 so it never hits zero)
        #if selected == "WiGSFunction_linear":
            SimulationConfigInputUpdated["w"] = (i+1) / T
            #print("i" + str(i))
            SimulationConfigInputUpdated["SelectorType"] = "WiGSFunction"
        #print("reached!!")
        #elif selected == "WiGSFunction_exponential":
            # alpha = SimulationConfigInputUpdated.get("alpha", 10.0 / T)
            # w = 1 - np.exp(-alpha * (i + 1))
            # SimulationConfigInputUpdated["w"] = w
            # print("reached!!")
            #SimulationConfigInputUpdated["SelectorType"] = "WiGSFunction"
        # ─────────────────────────────────────────────────────────────
        #print("w: " + str(SimulationConfigInputUpdated["w"]))

        ### Prediction Model ###
        print("Iteration: " + str(i))
        ModelType = globals().get(SimulationConfigInputUpdated["ModelType"], None)
        ModelArgsFiltered = FilterArguments(ModelType, SimulationConfigInputUpdated)
        Model = ModelType(**ModelArgsFiltered)
        SimulationConfigInputUpdated['Model'] = Model

        ### Test Error ###
        TestErrorOutput = TestErrorFunction(InputModel = Model, df_Test = SimulationConfigInputUpdated["df_Test"], Type = SimulationConfigInputUpdated["Type"])
        if('TREEFARMS' in str(type(Model))):                                                       # If Rashomon
            CurrentError = TestErrorOutput["Error_Duplicate"]
        else: 
            CurrentError = TestErrorOutput["ErrorVal"]                                               # One output for non-Rashomon
        ErrorVec.append(CurrentError)

        ### Sampling Procedure ###
        SelectorType = globals().get(SimulationConfigInputUpdated["SelectorType"], None)
        SelectorArgsFiltered = FilterArguments(SelectorType, SimulationConfigInputUpdated)
        SelectorFuncOutput = SelectorType(**SelectorArgsFiltered)
        QueryObservationIndex = SelectorFuncOutput["IndexRecommendation"]
        QueryObservation = SimulationConfigInputUpdated["df_Candidate"].loc[[QueryObservationIndex]]
        SelectedObservationHistory.append(QueryObservationIndex)
        
        ### WiGS ###
        ## disable if not doing an adaptive wi ##
        # ─── adaptive‐w update ────────────────────────────────────
        if selected == "WiGSFunction_adaptive":
            dx = SelectorFuncOutput.get("d_nX", 0.0)
            dy = SelectorFuncOutput.get("d_nY", 0.0)
            if prev_error is not None:
                delta   = prev_error - CurrentError
                eta = 0.1
                new_w = SimulationConfigInputUpdated["w"] + eta*(dy - dx)*delta
                # clip into [0,1]
                SimulationConfigInputUpdated["w"] = max(0.0, min(1.0, new_w))
        prev_error = CurrentError
        # # ────────────────────────────────────────────────────────────



        ### Update Train and Candidate Sets ###
        SimulationConfigInputUpdated["df_Train"] = pd.concat([SimulationConfigInputUpdated["df_Train"], QueryObservation])
        SimulationConfigInputUpdated["df_Candidate"] = SimulationConfigInputUpdated["df_Candidate"].drop(QueryObservationIndex) 

        ### Store Number of (Unique) Trees ###
        if('TREEFARMS' in str(type(Model))):
            TreeCount["AllTreeCount"].append(SelectorFuncOutput["AllTreeCount"])          # Store number of trees
            TreeCount["UniqueTreeCount"].append(SelectorFuncOutput["UniqueTreeCount"])    # Store number of unique/duplicate trees

    ### RETURN ###
    LearningProcedureOutput = {"ErrorVec": ErrorVec,
                               "TreeCount": TreeCount,
                               "SelectedObservationHistory": SelectedObservationHistory}
                              
    return LearningProcedureOutput