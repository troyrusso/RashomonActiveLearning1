### Summary: 
### Inputs:
### Output:

# NEED TO WORK ON THIS MORE TO GENERALIZE #

ClassErrorPlotFunc = function(SimulationResults){
  
  ### Set Up ###
  ClassErrorDat = data.frame(SimulationResults$ClassError) %>% 
    mutate(iter = 1:nrow(SimulationResults$ClassError)) %>%
    pivot_longer(c(Class1,Class2))
  colnames(ClassErrorDat) = c("iter", "Class", "error")
  
  ### Plot ###
  ErrorClassPlot = ggplot() + 
    geom_line(data = ClassErrorDat,
              mapping = aes(x = iter, y = error, linetype = Class))
  
  return(ErrorClassPlot)
}