### Summary: 
### Inputs:
### Output:

# NEED TO WORK ON THIS MORE TO GENERALIZE #


SelectorTypeComparisonPlotFunc = function(SimulationType1, SimulationType2){
  
  ### Set Up ###
  
  # Error Lines #
  JointErrors = data.frame(cbind(SimulationType1$Error, SimulationType2$Error))
  JointErrors$iter = 1:nrow(JointErrors)
  colnames(JointErrors) = c(SimulationType1$SelectorType, SimulationType2$SelectorType, "iter")
  JointErrors = pivot_longer(JointErrors, c(Random, BreakingTies))
  colnames(JointErrors) = c("iter", "SelectorType", "value")
  
  # Stop Iter Line
  # JointStopIter = c(SimulationType1$StopIter,SimulationType1$SelectorType,
  #                   SimulationType2$StopIter,SimulationType2$SelectorType) %>%
  #   matrix(nrow = 2, ncol = 2, byrow = TRUE)
  # colnames(JointStopIter) = c("StopIter", "SelectorType")
  # JointStopIter$StopIter = as.numeric(JointStopIter$StopIter)
  # 
  ### Plot ###
  ErrorScatterPlot = ggplot() +
    
    ## Lines ##
    geom_line(data = JointErrors,
              mapping = aes(x = iter, y = value, linetype = SelectorType)) + 
    
    ## Iteration Stop Line ##
    geom_vline(xintercept = SimulationType1$StopIter,
               color = "red",
               linetype = "dashed") + 
    
    geom_vline(xintercept = SimulationType2$StopIter,
               color = "red",
               linetype = "solid") + 
    
    ## Aesthetics ##
    xlab("Iterations") +
    ylab("Error") +
    ggtitle("Simulation by Error") +
    theme(plot.title = element_text(size = 15, hjust = 0.5))
  
  return(ErrorScatterPlot)
}