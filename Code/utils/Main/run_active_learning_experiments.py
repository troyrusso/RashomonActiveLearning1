# import os
# import time
# import random
# import numpy as np
# import pandas as pd
# import matplotlib.pyplot as plt
# from scipy.stats import wilcoxon

# # -----------------------------------------------------------------------------
# #  (Optional) Utility: Wilcoxon Signed-Rank Test for Pairwise Comparisons
# # -----------------------------------------------------------------------------
# def WilcoxonRankSignedTest(SimulationErrorResults, round_p=None):
#     """
#     Computes the Wilcoxon Signed-Rank Test pairwise for each method in the simulation.
    
#     Parameters
#     ----------
#     SimulationErrorResults : dict
#         Dictionary with keys as method names and values as 1D numpy arrays 
#         containing the average (or final) error across simulations.
#     round_p : int or None, optional
#         If not None, rounds the p-values to this many decimal places.
        
#     Returns
#     -------
#     pval_df_masked : pd.DataFrame
#         Lower-triangular DataFrame of p-values (diagonal is 1), with the upper
#         triangle left blank.
#     """
#     methods = list(SimulationErrorResults.keys())
#     n_methods = len(methods)
#     p_vals = np.zeros((n_methods, n_methods))
    
#     for i in range(n_methods):
#         for j in range(i):
#             stat, pval = wilcoxon(
#                 SimulationErrorResults[methods[i]], 
#                 SimulationErrorResults[methods[j]]
#             )
#             if round_p is not None:
#                 p_vals[i, j] = np.round(pval, round_p)
#             else:
#                 p_vals[i, j] = pval
    
#     np.fill_diagonal(p_vals, 1)
    
#     # Convert to DataFrame
#     pval_df = pd.DataFrame(p_vals, index=methods, columns=methods)
    
#     # Mask out upper triangle
#     mask = np.tril(np.ones(pval_df.shape), k=0).astype(bool)
#     pval_df_masked = pval_df.where(mask, "")
#     return pval_df_masked


# # -----------------------------------------------------------------------------
# #  Master Function: run_active_learning_experiments
# # -----------------------------------------------------------------------------
# def run_active_learning_experiments(
#     datasets,
#     model_types,
#     selector_types,
#     OneIterationFunction,        # <-- The function that performs one AL run
#     TrainTestCandidateSplit,     # <-- Your custom splitting function
#     n_simulations=100,
#     test_proportion=0.2,
#     candidate_proportion=0.8,
#     plot=True,
#     do_wilcoxon=True,
#     round_wilcoxon=4,
#     output_dir="results"
# ):
#     """
#     Runs active learning experiments for each combination of dataset, model, and selector.
    
#     Parameters
#     ----------
#     datasets : dict
#         Dictionary of named datasets. Keys = dataset names, 
#         values = DataFrames with columns for features and a "Y" for the target.
#     model_types : list of str
#         List of model function names (as implemented in your codebase).
#     selector_types : list of str
#         List of selector function names.
#     OneIterationFunction : callable
#         Function that runs one full active learning iteration, returning a dict 
#         with keys like {"ErrorVec": ..., "ElapsedTime": ...}.
#     TrainTestCandidateSplit : callable
#         Function that splits a dataset into train, test, and candidate DataFrames.
#     n_simulations : int, optional
#         Number of simulations to run for each (dataset, model, selector) combo.
#     test_proportion : float, optional
#         Fraction of data to use as test set.
#     candidate_proportion : float, optional
#         Fraction of the remainder to use as the candidate pool.
#     plot : bool, optional
#         If True, plots the aggregated error curves.
#     do_wilcoxon : bool, optional
#         If True, performs pairwise Wilcoxon tests among selectors for each dataset+model.
#     round_wilcoxon : int, optional
#         Decimal places to round p-values in the Wilcoxon results.
#     output_dir : str, optional
#         Directory in which to save results (plots, Wilcoxon CSV, etc.).
        
#     Returns
#     -------
#     results_summary : dict
#         A nested dictionary with keys (dataset_name, model_name, selector_name) 
#         and values containing aggregated results:
#         {
#             "avg_error": <np.array>,
#             "avg_runtime": <float>,
#             "all_errors": <list of np.arrays>,
#             "all_runtimes": <list of floats>,
#         }
#     """
#     # -------------------------------------------------------------------------
#     # 1. Prepare output directory
#     # -------------------------------------------------------------------------
#     if not os.path.exists(output_dir):
#         os.makedirs(output_dir)
    
#     # A dictionary to hold the aggregated results
#     results_summary = {}
    
#     # -------------------------------------------------------------------------
#     # 2. Loop over each dataset
#     # -------------------------------------------------------------------------
#     for dataset_name, df in datasets.items():
        
#         # ---------------------------------------------------------------------
#         # 3. Loop over each model
#         # ---------------------------------------------------------------------
#         for model_name in model_types:
            
#             print(f"\n=== DATASET: {dataset_name} | MODEL: {model_name} ===")
            
#             # For storing errors & runtimes from each selector
#             # e.g. method_results["GSxFunction"] = [error_vec_sim1, error_vec_sim2, ...]
#             method_results = {sel: [] for sel in selector_types}
#             method_runtimes = {sel: [] for sel in selector_types}
            
#             # -----------------------------------------------------------------
#             # 4. Run simulations for each selector
#             # -----------------------------------------------------------------
#             for seed in range(n_simulations):
#                 # Split the data anew for each seed
#                 random.seed(seed)
#                 np.random.seed(seed)
                
#                 df_Train, df_Test, df_Candidate = TrainTestCandidateSplit(
#                     df, 
#                     test_proportion=test_proportion, 
#                     candidate_proportion=candidate_proportion
#                 )
                
#                 # A base configuration that each selector will use
#                 base_config = {
#                     "DataFileInput": dataset_name,
#                     "Seed": seed,
#                     "TestProportion": test_proportion,
#                     "CandidateProportion": candidate_proportion,
#                     "ModelType": model_name,
#                     "n_estimators": 100,  # used for random forest or other ensembles
#                     "Type": "Regression",
#                     "UniqueErrorsInput": 0,
#                     "regularization": 0.01,
#                     "RashomonThresholdType": "Adder",
#                     "RashomonThreshold": 0.05,
#                     "df_Train": df_Train.copy(),
#                     "df_Test": df_Test.copy(),
#                     "df_Candidate": df_Candidate.copy()
#                 }
                
#                 for selector_name in selector_types:
#                     config_current = base_config.copy()
#                     config_current["SelectorType"] = selector_name
                    
#                     # Run one active learning iteration
#                     result = OneIterationFunction(config_current)
                    
#                     # Extract error curve and runtime
#                     error_array = result["ErrorVec"]["Error"].values
#                     runtime = result["ElapsedTime"]
                    
#                     method_results[selector_name].append(error_array)
#                     method_runtimes[selector_name].append(runtime)
            
#             # -----------------------------------------------------------------
#             # 5. Aggregate results (average errors, average runtimes)
#             # -----------------------------------------------------------------
#             for selector_name in selector_types:
#                 error_matrix = np.array(method_results[selector_name])  
#                 avg_error_curve = np.mean(error_matrix, axis=0)
#                 avg_runtime = float(np.mean(method_runtimes[selector_name]))
                
#                 results_summary[(dataset_name, model_name, selector_name)] = {
#                     "avg_error": avg_error_curve,
#                     "avg_runtime": avg_runtime,
#                     "all_errors": method_results[selector_name],
#                     "all_runtimes": method_runtimes[selector_name],
#                 }
            
#             # -----------------------------------------------------------------
#             # 6. (Optional) Plot aggregated curves for each selector 
#             # -----------------------------------------------------------------
#             if plot:
#                 plt.figure(figsize=(10, 5))
#                 for selector_name in selector_types:
#                     info = results_summary[(dataset_name, model_name, selector_name)]
#                     n_points = len(info["avg_error"])
#                     x_values = np.linspace(
#                         100 * (1 - candidate_proportion), 
#                         100, 
#                         n_points
#                     )
#                     plt.plot(x_values, info["avg_error"], label=selector_name)
                
#                 plt.xlabel("Percent of Labelled Observations")
#                 plt.ylabel("RMSE")
#                 plt.title(
#                     f"{dataset_name}, {model_name}\n"
#                     f"Mean Error Across {n_simulations} Simulations"
#                 )
#                 plt.legend(loc="upper right")
                
#                 # Save figure to disk
#                 plot_filename = f"{dataset_name}_{model_name}_ActiveLearningComparison.png"
#                 plot_path = os.path.join(output_dir, plot_filename)
#                 plt.savefig(plot_path, dpi=120, bbox_inches="tight")
#                 plt.close()
                
#                 print(f"Saved plot: {plot_path}")
            
#             # -----------------------------------------------------------------
#             # 7. (Optional) Wilcoxon tests across selectors
#             # -----------------------------------------------------------------
#             if do_wilcoxon and len(selector_types) > 1:
#                 # Compare final iteration error (or average, etc.) across selectors
#                 simulation_error_results = {}
                
#                 for selector_name in selector_types:
#                     final_errs = []
#                     for sim_idx in range(n_simulations):
#                         # last iteration's error from each simulation
#                         final_errs.append(method_results[selector_name][sim_idx][-1])
#                     simulation_error_results[selector_name] = np.array(final_errs)
                
#                 pval_df = WilcoxonRankSignedTest(simulation_error_results, round_p=round_wilcoxon)
                
#                 # Save CSV
#                 csv_filename = f"{dataset_name}_{model_name}_Wilcoxon.csv"
#                 csv_path = os.path.join(output_dir, csv_filename)
#                 pval_df.to_csv(csv_path)
#                 print(f"Saved Wilcoxon results: {csv_path}")
    
#     return results_summary
import os
import random
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from scipy.stats import wilcoxon

def WilcoxonRankSignedTest(SimulationErrorResults, round_p=None):
    """
    Computes the Wilcoxon Signed-Rank Test pairwise for each method in the simulation.
    
    Parameters
    ----------
    SimulationErrorResults : dict
        Dictionary with keys as method names and values as 1D numpy arrays 
        containing the metric (e.g., final iteration error) across multiple runs.
    round_p : int or None, optional
        If not None, rounds the p-values to this many decimal places.
        
    Returns
    -------
    pval_df_masked : pd.DataFrame
        Lower-triangular DataFrame of p-values (diagonal is 1), with the upper
        triangle left blank.
    """
    methods = list(SimulationErrorResults.keys())
    n_methods = len(methods)
    p_vals = np.zeros((n_methods, n_methods))
    
    for i in range(n_methods):
        for j in range(i):
            stat, pval = wilcoxon(SimulationErrorResults[methods[i]], 
                                  SimulationErrorResults[methods[j]])
            p_vals[i, j] = np.round(pval, round_p) if round_p is not None else pval
    
    np.fill_diagonal(p_vals, 1)
    pval_df = pd.DataFrame(p_vals, index=methods, columns=methods)
    mask = np.tril(np.ones(pval_df.shape), k=0).astype(bool)
    pval_df_masked = pval_df.where(mask, "")
    return pval_df_masked

def run_active_learning_experiments(
    datasets,
    model_types,
    selector_types,
    OneIterationFunction,       # function to run a single active learning iteration
    TrainTestCandidateSplit,    # function to split the dataset into train, test, candidate sets
    n_simulations=100,
    test_proportion=0.2,
    candidate_proportion=0.8,
    plot=True,
    do_wilcoxon=True,
    round_wilcoxon=4,
    output_dir="results"
):
    """
    Runs active learning experiments for each combination of dataset, model, and selector.
    
    Parameters
    ----------
    datasets : dict
        Dictionary of named datasets. Keys are dataset names, values are DataFrames.
    model_types : list of str
        List of model function names (as strings) available in your codebase.
    selector_types : list of str
        List of selector function names (as strings) available in your codebase.
    OneIterationFunction : function
        Function that runs one iteration (or complete active learning process) given a config.
    TrainTestCandidateSplit : function
        Function that splits a dataset into training, test, and candidate sets.
    n_simulations : int, optional
        Number of simulations (with different seeds) per combination.
    test_proportion : float, optional
        Fraction of data used as test set.
    candidate_proportion : float, optional
        Fraction of the remaining data used as the candidate pool.
    plot : bool, optional
        If True, produces plots of the aggregated error curves.
    do_wilcoxon : bool, optional
        If True, performs Wilcoxon tests among selectors.
    round_wilcoxon : int, optional
        Number of decimals for rounding Wilcoxon p-values.
    output_dir : str, optional
        Directory to save results (plots, CSVs, etc.).
        
    Returns
    -------
    results_summary : dict
        Nested dictionary indexed by (dataset, model, selector) containing:
         - "avg_error": Averaged error curve (numpy array)
         - "avg_runtime": Average runtime (float)
         - "all_errors": List of error curves (one per simulation)
         - "all_runtimes": List of runtimes (one per simulation)
    """
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    
    results_summary = {}
    
    # Loop over datasets
    for dataset_name, df in datasets.items():
        # Loop over each model type
        for model_name in model_types:
            print(f"\n=== DATASET: {dataset_name} | MODEL: {model_name} ===")
            method_results = {sel: [] for sel in selector_types}
            method_runtimes = {sel: [] for sel in selector_types}
            
            # Run simulations for each selector
            for seed in range(n_simulations):
                random.seed(seed)
                np.random.seed(seed)
                
                # Build the base configuration dictionary
                base_config = {
                "DataFileInput": os.path.join(os.getcwd(), "dataset_files", dataset_name),# Updated path
                "Seed": seed,
                "TestProportion": test_proportion,
                "CandidateProportion": candidate_proportion,
                "ModelType": model_name,
                "n_estimators": 100,
                "Type": "Regression",
                "UniqueErrorsInput": 0,
                "regularization": 0.01,
                "RashomonThresholdType": "Adder",
                "RashomonThreshold": 0.05,
            }

                
                # Use the base config values for splitting (positional arguments)
                df_Train, df_Test, df_Candidate = TrainTestCandidateSplit(
                    df, base_config["TestProportion"], base_config["CandidateProportion"]
                )


                # **********************************************************************
                # For debugging: reduce the candidate set to 50 random rows ******************************
                df_Candidate = (
                    df_Candidate.sample(n=20, random_state=seed)
                    .copy()
                )
                ##### ******************************************************************
                # Add the splits into the config
                base_config["df_Train"] = df_Train.copy()
                base_config["df_Test"] = df_Test.copy()
                base_config["df_Candidate"] = df_Candidate.copy()
                
                # Run each selector
                for selector_name in selector_types:
                    config_current = base_config.copy()
                    config_current["SelectorType"] = selector_name
                    result = OneIterationFunction(config_current)
                    
                    # Extract error vector and runtime from the result
                    error_array = result["ErrorVec"]["Error"].values
                    runtime = result["ElapsedTime"]
                    
                    method_results[selector_name].append(error_array)
                    method_runtimes[selector_name].append(runtime)
            
            # Aggregate results for each selector
            for selector_name in selector_types:
                error_matrix = np.array(method_results[selector_name])  # shape: (n_simulations, n_iterations)
                avg_error_curve = np.mean(error_matrix, axis=0)
                avg_runtime = float(np.mean(method_runtimes[selector_name]))
                
                results_summary[(dataset_name, model_name, selector_name)] = {
                    "avg_error": avg_error_curve,
                    "avg_runtime": avg_runtime,
                    "all_errors": method_results[selector_name],
                    "all_runtimes": method_runtimes[selector_name],
                }
            
            # Plot aggregated error curves if requested
            if plot:
                fig = plt.figure(figsize=(10, 5))
                for selector_name in selector_types:
                    info = results_summary[(dataset_name, model_name, selector_name)]
                    n_points = len(info["avg_error"])
                    x_values = np.linspace(100 * (1 - candidate_proportion), 100, n_points)
                    plt.plot(x_values, info["avg_error"], label=selector_name)
                
                plt.xlabel("Percent of Labelled Observations")
                plt.ylabel("RMSE")
                plt.title(f"Dataset: {dataset_name}, Model: {model_name}\nMean Error Across {n_simulations} Simulations")
                plt.legend(loc="upper right")
                
                plot_filename = f"{dataset_name}_{model_name}_Comparison.png"
                plot_path = os.path.join(output_dir, plot_filename)
                plt.savefig(plot_path, dpi=120, bbox_inches="tight")
                plt.close(fig)
                print(f"Saved plot: {plot_path}")
            
            # Perform Wilcoxon tests if requested
            if do_wilcoxon and len(selector_types) > 1:
                simulation_error_results = {}
                for selector_name in selector_types:
                    final_errors_all_sims = [method_results[selector_name][i][-1] for i in range(n_simulations)]
                    simulation_error_results[selector_name] = np.array(final_errors_all_sims)
                
                pval_df = WilcoxonRankSignedTest(simulation_error_results, round_p=round_wilcoxon)
                wilcox_filename = f"{dataset_name}_{model_name}_Wilcoxon.csv"
                wilcox_path = os.path.join(output_dir, wilcox_filename)
                pval_df.to_csv(wilcox_path)
                print(f"Saved Wilcoxon results: {wilcox_path}")
    
    return results_summary
