### Current Directory Name ###
# CURRENT_DIR=$(basename "$PWD")
# echo "Processing results for dataset: $CURRENT_DIR"
# cd ~/RashomonActiveLearning1

# ### Extract PassiveLearning Results ###
# cd ~/RashomonActiveLearning1
# python Code/utils/Auxiliary/ProcessSimulationResults.py \
#     --DataType "$CURRENT_DIR" \
#     --ModelType "RandomForestClassification" \
#     --Categories "PLA0.pkl"

# ### Extract Random Forests Results ###
# cd ~/RashomonActiveLearning1
# #RandomForestClassification
# python Code/utils/Auxiliary/ProcessSimulationResults.py \
#     --DataType "$CURRENT_DIR" \
#     --ModelType "RandomForestClassification" \
#     --Categories "RFA0.pkl"

#chat gpt one here 
#!/usr/bin/env bash
cd "$(dirname "$0")"

CURRENT_DIR=$(basename "$PWD")
echo "Processing results for dataset: $CURRENT_DIR"

# Duplicate‐TreeFarms (ε=0.025)
python Code/utils/Auxiliary/ProcessSimulationResults.py \
  --DataType   "$CURRENT_DIR" \
  --ModelType  "TreeFarms" \
  --Categories "DPL0.025"

# Unique‐TreeFarms (ε=0.025)
python Code/utils/Auxiliary/ProcessSimulationResults.py \
  --DataType   "$CURRENT_DIR" \
  --ModelType  "TreeFarms" \
  --Categories "UNQ0.025"


# ### Extract Duplicate TREEFARMS Results ###
# python Code/utils/Auxiliary/ProcessSimulationResults.py \
#     --DataType "$CURRENT_DIR" \
#     --ModelType "TreeFarms" \
#     --Categories "DA0.02.pkl"

# ### Extract Unique TREEFARMS Results ###
# python Code/utils/Auxiliary/ProcessSimulationResults.py \
#     --DataType "$CURRENT_DIR" \
#     --ModelType "TreeFarms" \
#     --Categories "UA0.02.pkl"
