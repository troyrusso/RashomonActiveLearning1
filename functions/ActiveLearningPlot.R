### Summary:
### Inputs:
### Output:

ActiveLearningPlotFunc = function(Error, StopIter, SelectorType){
  ErrorScatterPlot = ggplot() +
    geom_line(mapping = aes(x = 1:length(Error), y = Error)) + 
    geom_vline(xintercept = StopIter, color = "red") + 
    geom_hline(yintercept = Error[StopIter], color = "black", linetype = "dotted", alpha = 0.4) + 
    annotate("text", x = StopIter, y = max(Error), label = StopIter) + 
    annotate("text", x = 0, y = Error[StopIter], label = round(Error[StopIter],3)) + 
    ggtitle(paste0("Selector type: ", SelectorType))
  
}