# cd RunSimulations
# for file in ./*sbatch
# do
# 	sbatch "$file"
# done
#cd ~/RashomonActiveLearning1/Code/Cluster/BostonHousing
for job in *.sbatch; do
  sbatch -A stf -p compute "$job"
done