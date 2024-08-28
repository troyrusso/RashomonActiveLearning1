### Summary:
### Inputs:
### Output:

library(stats)
library(factoextra)
library(ggpubr)


NClusters = 5

KMeansCandidateSetCluster = function(CandidateSet,NClusters){
  ClusterDat = CandidateSet[, setdiff(colnames(CandidateSet), c("Y","ID"))]
  
  ### Distance Matrix ###
  DissimilarityMatrix = factoextra::get_dist(ClusterDat, method = "canberra")
  MDS = stats::cmdscale(DissimilarityMatrix) %>% as.data.frame()
  CandidateCluster = stats::kmeans(ClusterDat, NClusters)$cluster %>% as.factor()
  
  ### Plot ###
  MDSPlot = mutate(MDS, groups = CandidateCluster, Y = CandidateSet$Y)
  ClusterPlot = ggpubr::ggscatter(MDSPlot, x = "V1", y = "V2",
                                  # label = "groups",
                                  shape = "Y",
                                  color = "groups",
                                  palette = "jco",
                                  size = 1,
                                  ellipse = TRUE,
                                  ellipse.type = "convex",
                                  repel = TRUE)
  
}