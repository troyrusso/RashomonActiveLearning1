### Summary:
### Inputs:
### Output:

ActiveLearningPlotFunc = function(Error, StopIter, SelectorType, xlower = NULL, xupper = NULL){
  ### Set Up ###
  if(is.null(xlower)){xlower = 0}
  if(is.null(xupper)){xupper = length(Error)}
  
  ### Plot ###
  ErrorScatterPlot = ggplot() +
    geom_line(mapping = aes(x = 1:length(Error), y = Error)) + 
    geom_vline(xintercept = StopIter, color = "red") + 
    geom_hline(yintercept = Error[StopIter], color = "black", linetype = "dotted", alpha = 0.4) + 
    annotate("text", x = StopIter, y = max(Error), label = StopIter) + 
    annotate("text", x = 0, y = Error[StopIter], label = round(Error[StopIter],3)) + 
    xlim(xlower, xupper) + 
    ggtitle(paste0("Selector type: ", SelectorType))
  
}