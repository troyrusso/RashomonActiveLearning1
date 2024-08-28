#!/bin/bash
#SBATCH --job-name Sim_3_1000_4_2_NA_0_3_LASSO_BreakingTies_0.2_1_10
#SBATCH --partition medium
#SBATCH --ntasks 1
#SBATCH --time 7-00:00:00
#SBATCH --mem-per-cpu=6000
#SBATCH -o ClusterMessages/out/myscript_Sim_3_1000_4_2_NA_0_3_LASSO_BreakingTies_0.2_1_10_%j.out
#SBATCH -e ClusterMessages/error/myscript_Sim_3_1000_4_2_NA_0_3_LASSO_BreakingTies_0.2_1_10_%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=simondn@uw.edu

cd ~/RashomonActiveLearning
module load R
Rscript Code/functions/Main/RunSimulation.R \
    --job_name Sim_3_1000_4_2_NA_0_3_LASSO_BreakingTies_0.2_1_10\
    --seed 3 \
    --N 1000 \
    --K 4 \
    --NClass 2 \
    --ClassProportion NA \
    --CovCorrVal '0' \
    --NBins 3 \
    --ModelType LASSO \
    --SelectorType BreakingTies \
    --TestProportion 0.2 \
    --SelectorN 1 \
    --InitialN '10' \
    --output Results/3_1000_4_2_NA_0_3_LASSO_BreakingTies_0.2_1_10.rds \
