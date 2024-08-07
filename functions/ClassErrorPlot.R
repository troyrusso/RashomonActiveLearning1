### Summary: 
### Inputs:
### Output:

# NEED TO WORK ON THIS MORE TO GENERALIZE #

ClassErrorPlotFunc = function(SimulationResults, xlower = NULL, xupper = NULL){
  
  ### Set Up ###
  if(is.null(xlower)){xlower = 0}
  if(is.null(xupper)){xupper = length(SimulationResults$Error)}
  ClassErrorDat = data.frame(SimulationResults$ClassError) %>% 
    mutate(iter = 1:nrow(SimulationResults$ClassError)) %>%
    pivot_longer(-iter)
  colnames(ClassErrorDat) = c("iter", "Class", "error")

  ### Plot ###
  ErrorClassPlot = ggplot() + 
    geom_line(data = ClassErrorDat,
              mapping = aes(x = iter, y = error, color = Class)) +
    xlim(xlower, xupper) + 
    ggtitle(paste0("Selector type: ", SimulationResults$SelectorType))
  
  
  return(ErrorClassPlot)
}