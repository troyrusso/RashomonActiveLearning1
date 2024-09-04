### Summary: 
### Inputs:
### Output:

# NEED TO WORK ON THIS MORE TO GENERALIZE #


SelectorTypeComparisonPlotFunc = function(SimulationType1, 
                                          SimulationType2,
                                          StopIter1,
                                          StopIter2,
                                          SelectorN,
                                          xlower = NULL, 
                                          xupper = NULL){
  ### Validation ###
  if(SimulationType1$InitialTrainingSetN != SimulationType2$InitialTrainingSetN){
    stop("Starting points are not the same.")
  }

  if(length(SimulationType1$Error) != length(SimulationType2$Error)){
    stop("Ending points are not the same.")
  }  
  
  if((SimulationType1$Error[length(SimulationType1$Error)] - SimulationType2$Error[length(SimulationType2$Error)])>1e-5){
    warning("The error rate with all observations labelled are not the same.")
  }
  
  # Joint Errors #
  InitialTrainingSetN = SimulationType1$InitialTrainingSetN
  JointErrors = data.frame(cbind(SimulationType1$Error, SimulationType2$Error))
  JointErrors$iter = seq(InitialTrainingSetN+SelectorN, SelectorN*length(SimulationType1$Error)+InitialTrainingSetN, by =SelectorN)
  colnames(JointErrors) = c(SimulationType1$SelectorType, SimulationType2$SelectorType, "iter")
  JointErrors = pivot_longer(JointErrors, c(Random, BreakingTies))
  colnames(JointErrors) = c("iter", "SelectorType", "value")

  ### Set Up ###
  if(is.null(xlower)){xlower = 0}
  if(is.null(xupper)){xupper = tail(JointErrors,1)$iter+SelectorN}
  StopIter1 = StopIter1 + InitialTrainingSetN
  StopIter2 = StopIter2 + InitialTrainingSetN
  
  # Stop Iter Line
  # JointStopIter = c(SimulationType1$StopIter,SimulationType1$SelectorType,
  #                   SimulationType2$StopIter,SimulationType2$SelectorType) %>%
  #   matrix(nrow = 2, ncol = 2, byrow = TRUE)
  # colnames(JointStopIter) = c("StopIter", "SelectorType")
  # JointStopIter$StopIter = as.numeric(JointStopIter$StopIter)
  
  ### Plot ###
  ErrorScatterPlot = ggplot() +
    
    ## Lines ##
    geom_line(data = JointErrors,
              mapping = aes(x = iter, y = value, linetype = SelectorType)) + 
    
    ## Iteration Stop Line ##
    geom_vline(xintercept = as.numeric(JointErrors[StopIter1,"iter"]),
               color = "red",
               linetype = "dashed") + 
    
    geom_vline(xintercept = as.numeric(JointErrors[StopIter2,"iter"]),
               color = "red",
               linetype = "solid") + 
    
    ## Aesthetics ##
    scale_x_continuous(breaks = c(seq(xlower,xupper, 100), 
                                  as.numeric(JointErrors[StopIter1,"iter"]),
                                  as.numeric(JointErrors[StopIter2,"iter"]), 
                                  SimulationType1$InitialTrainingSetN),
                       lim = c(xlower, xupper))    +
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
    xlab("Number of annotated observations") +
    ylab("Test Set Error") +
    ggtitle("Simulation by Error") +
    theme(plot.title = element_text(size = 15, hjust = 0.5))
  
  return(ErrorScatterPlot)
}
