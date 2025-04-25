cd RunSimulations
for file in ./*sbatch
do
	sbatch "$file"
done

##!/usr/bin/env bash
# Go to the RunSimulations subdirectory
# cd "$(dirname "$0")/RunSimulations"

# # Don’t treat an empty glob as literal “*.sbatch”
# shopt -s nullglob

# # Loop and submit
# for job in *.sbatch; do
#   echo "Submitting $job → compute"
#   sbatch -A stf -p compute "$job"
# done