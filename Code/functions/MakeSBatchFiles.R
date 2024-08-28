### Summary:
### Inputs:
### Output:

# Read CSV file
rm(list=ls())
dir = paste0("/Users/simondn/Documents/RashomonActiveLearning/Code/Cluster/")
ParameterVector <- read.csv(paste0(dir,"/ParameterVectorALL.csv"))

# Loop through each row
for (i in 1:nrow(ParameterVector)) {
  job_name = ParameterVector[i, "JobName"]
  seed = ParameterVector[i, "seed"]
  N = ParameterVector[i, "N"]
  K = ParameterVector[i, "K"]
  NClass = ParameterVector[i, "NClass"]
  ClassProportion = ParameterVector[i, "ClassProportion"]
  CovCorrVal = ParameterVector[i, "CovCorrVal"]
  NBins = ParameterVector[i, "NBins"]
  ModelType = ParameterVector[i, "ModelType"]
  SelectorType = ParameterVector[i, "SelectorType"]
  TestProportion = ParameterVector[i, "TestProportion"]
  SelectorN = ParameterVector[i, "SelectorN"]
  InitialN = ParameterVector[i, "InitialN"]
  output = ParameterVector[i, "Output"]

  
  # Create .sbatch file for the current simulation
  sbatch_file <- file(paste0(dir,
                             "/RunSimulation/",
                             job_name, 
                             ".sbatch"), "w")
  writeLines(
    c(
      "#!/bin/bash",
      paste("#SBATCH --job-name", job_name),
      "#SBATCH --partition medium",
      "#SBATCH --ntasks 1",
      "#SBATCH --time 7-00:00:00",
      "#SBATCH --mem-per-cpu=6000",
      paste("#SBATCH -o ClusterMessages/out/myscript_", 
            job_name, 
            "_%j.out", 
            sep=""),
      paste("#SBATCH -e ClusterMessages/error/myscript_", 
            job_name, 
            "_%j.err", 
            sep=""),
      "#SBATCH --mail-type=ALL",
      "#SBATCH --mail-user=simondn@uw.edu",
      "",
      "cd ~/RashomonActiveLearning",
      "module load R",
      "Rscript Code/functions/Main/RunSimulation.R \\",
      
      
      
      paste("    --job_name ", job_name, "\\", sep=""),
      paste("    --seed ", seed, " \\", sep=""),
      paste("    --N ", N, " \\", sep=""),
      paste("    --K ", K, " \\", sep=""),
      paste("    --NClass ", NClass, " \\", sep=""),
      paste("    --ClassProportion ", ClassProportion, " \\", sep=""),
      paste("    --CovCorrVal '", CovCorrVal, "' \\", sep=""),
      paste("    --NBins ", NBins, " \\", sep=""),
      paste("    --ModelType ", ModelType, " \\", sep=""),
      paste("    --SelectorType ", SelectorType, " \\", sep=""),
      paste("    --TestProportion ", TestProportion, " \\", sep=""),
      paste("    --SelectorN ", SelectorN, " \\", sep=""),
      paste("    --InitialN '", InitialN, "' \\", sep=""),
      paste("    --output ", output, " \\", sep="")
    ),
    con=sbatch_file
  )
  close(sbatch_file)
}

print("Sbatch files generated successfully.")


