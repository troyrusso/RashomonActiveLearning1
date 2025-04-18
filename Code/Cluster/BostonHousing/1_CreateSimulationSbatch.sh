#!/bin/bash

### Current Directory Name ###
CURRENT_DIR=$(basename "$PWD")
echo "Processing results for dataset: $CURRENT_DIR"

cd ~/RashomonActiveLearning1
python Code/utils/Auxiliary/CreateRunSimSbatch.py \
    --DataType "$CURRENT_DIR" \
