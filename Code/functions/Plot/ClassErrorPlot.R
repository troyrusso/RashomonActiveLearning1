### Summary: 
### Inputs:
### Output:

# NEED TO WORK ON THIS MORE TO GENERALIZE #

ClassErrorPlotFunc = function(SimulationResults, xlower = NULL, xupper = NULL){
  
  ### Set Up ###
  ClassErrorDat = data.frame(SimulationResults$ClassError) %>% 
    mutate(iter = seq(SimulationResults$InitialTrainingSetN+SelectorN, SelectorN*length(SimulationResults$Error)+SimulationResults$InitialTrainingSetN, by =SelectorN)) %>%
    pivot_longer(-iter)
  colnames(ClassErrorDat) = c("iter", "Class", "error")

  if(is.null(xlower)){xlower = 0}
  if(is.null(xupper)){xupper = tail(ClassErrorDat,1)$iter +SelectorN}

  ### Plot ###
  ErrorClassPlot = ggplot() + 
    geom_line(data = ClassErrorDat,
              mapping = aes(x = iter, y = error, color = Class)) +
    scale_x_continuous(breaks = c(seq(xlower,xupper, 100), SimulationResults$InitialTrainingSetN),
                       lim = c(xlower, xupper)) +
    xlab("Number of annotated observations") +
    ylab("Test Set Error") + 
    ggtitle(paste0("Selector type: ", SimulationResults$SelectorType))
  
  
  return(ErrorClassPlot)
}