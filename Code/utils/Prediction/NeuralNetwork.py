from sklearn.neural_network import MLPRegressor

def NeuralNetworkFunction(df_Train):
    NeuralNetworkModel = MLPRegressor(hidden_layer_sizes=(100,), max_iter=200, random_state=42)
    NeuralNetworkModel.fit(df_Train.loc[:, df_Train.columns != "Y"], df_Train["Y"])
    return NeuralNetworkModel
