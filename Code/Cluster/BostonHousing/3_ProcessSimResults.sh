### Current Directory Name ###
CURRENT_DIR=$(basename "$PWD")
echo "Processing results for dataset: $CURRENT_DIR"
cd ~/RashomonActiveLearning1

### Extract PassiveLearning Results ###
cd ~/RashomonActiveLearning1
python Code/utils/Auxiliary/ProcessSimulationResults.py \
    --DataType "$CURRENT_DIR" \
    --ModelType "RandomForestClassification" \
    --Categories "PLA0.pkl"

### Extract Random Forests Results ###
cd ~/RashomonActiveLearning1
#RandomForestClassification
python Code/utils/Auxiliary/ProcessSimulationResults.py \
    --DataType "$CURRENT_DIR" \
    --ModelType "RandomForestClassification" \
    --Categories "RFA0.pkl"

# #chat gpt one here 
# #!/usr/bin/env bash

# # 1) Jump to project root
# cd ~/RashomonActiveLearning1

# DATASET=BostonHousing
# MODELT=TreeFarms

# echo "Processing results for dataset: $DATASET, model: $MODELT"

# # 2) Process DPL0.025
# python Code/utils/Auxiliary/ProcessSimulationResults.py \
#   --DataType   "$DATASET" \
#   --ModelType  "$MODELT" \
#   --Categories "DPL0.025"

# # 3) Process UNQ0.025
# python Code/utils/Auxiliary/ProcessSimulationResults.py \
#   --DataType   "$DATASET" \
#   --ModelType  "$MODELT" \
#   --Categories "UNQ0.025"



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
