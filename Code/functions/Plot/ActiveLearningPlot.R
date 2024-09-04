### Summary:
### Inputs:
### Output:

ActiveLearningPlotFunc = function(Error, 
                                  StopIter, 
                                  InitialTrainingSetN, 
                                  SelectorType, 
                                  SelectorN,
                                  xlower = NULL, 
                                  xupper = NULL){
  ### Set Up ###
  PlotDat = cbind(LabelledObsNSeq = seq(InitialTrainingSetN+SelectorN, SelectorN*length(Error)+InitialTrainingSetN, by =SelectorN), 
                  Error) %>% data.frame
  if(is.null(xlower)){xlower = 0}
  if(is.null(xupper)){xupper = tail(PlotDat,1)$LabelledObsNSeq+SelectorN}

  ### Plot ###
  ErrorScatterPlot = ggplot(data = PlotDat) +
    
    ### Lines ###
    geom_line(mapping = aes(x = LabelledObsNSeq, y = Error)) + 
    geom_vline(xintercept = PlotDat[StopIter,"LabelledObsNSeq"], color = "red") + 
    geom_hline(yintercept = PlotDat[StopIter,"Error"], color = "black", linetype = "dotted", alpha = 0.4) + 

    ### Aesthetic ###
    annotate("text", x = 0, y = Error[StopIter], label = round(Error[StopIter],3)) + 
    scale_x_continuous(breaks = c(seq(xlower,xupper, 100), PlotDat[StopIter,"LabelledObsNSeq"], InitialTrainingSetN),
                       lim = c(xlower, xupper)) +
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
    xlab("Number of annotated observations") +
    ylab("Test Set Error") +
    ggtitle(paste0("Selector type: ", SelectorType))
  
}