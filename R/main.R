################################################################################
# main.R                                              (c) J.M.B. Koch 2022
################################################################################
# This is the main script running the simulation 
# Dependencies: functions.R; parameters.R; 

# source functions and conditions outside clusters ------------------------
source('R/functions.R')
source('R/parameters.R')

# Prepare data SVNP ------------------------------------------------------------
# simulate data
if (!file.exists('data/datasets.RDS')){
datasets <- simDatasets(condPop = condPop, modelPars = modelPars, nIter = nIter)
# save raw data
readr::write_rds(datasets, file = 'data/datasets.RDS' )
}else {
  datasets <- readr::read_rds('data/datasets.RDS')
}
# prepare data for stan
if (!file.exists('data/dataStanSVNP.RDS')){
dataStanSVNP <- prepareDat(datasets, condSVNP, nIter)
# save stan-ready data
readr::write_rds(dataStanSVNP, file = "data/dataStanSVNP.RDS")
} else{
# load stan-ready data generally
  dataStanSVNP <- readr::read_rds("data/dataStanSVNP.RDS")
}
## Execute simulation for SVNP ---------------------------------------------
if( file.exists("output/resultsSVNP.RDS")){
  stop("output already exists. Please remove or backup before proceeding.")
}else if (length(dataStanSVNP) != (nIter*condSVNP)){
  stop("something went wrong with simulating the data!")
}else{
# do the sampling where every available core (nWorkers in condtions.R) does 
#    one unique combination of conditions
# measure start time
startTimeSVNP <- Sys.time()
# create clusters
clusters <- makePSOCKcluster(nClusters) 
# source functions & parameters within clusters
clusterCall(clusters, 
            function() source('R/functions.R'))
clusterCall(clusters, 
            function() source('R/parameters.R'))
# Load packages per cluster
clusterCall(clusters, 
            function() lapply(packages, library, character.only = TRUE))
# read in stan-ready data within clusters
clusterCall(clusters,
            function() load("data/dataStanSVNP.RDS"))

# run functon in clustered way where it's clustered over individual combo's of 
#  iteration, condPop and condPrior
outputFinalSVNP <- clusterApplyLB(clusters, 
                                  1:length(dataStanSVNP),
                                  sampling,
                                  dataStan = dataStanSVNP, 
                                  prior = "SVNP",
                                  modelPars = modelPars, 
                                  samplePars = samplePars)
# close clusters
stopCluster(clusters) 
# measure end time
endTimeSVNP <- Sys.time()
# measure elapsed time
elapsedTimesSVNP <- endTimeSVNP-startTimeSVNP
}

# Prepare data SVNP hyper ------------------------------------------------------------
# simulate data
if (!file.exists('data/datasets.RDS')){
  datasets <- simDatasets(condPop = condPop, modelPars = modelPars, nIter = nIter)
  # save raw data
  readr::write_rds(datasets, file = 'data/datasets.RDS ' )
}else {
  datasets <- readr::read_rds('data/datasets.RDS')
}
# prepare data for stan
if (!file.exists('data/dataStanSVNP_hyper.RDS')){
  dataStanSVNP_hyper <- prepareDat(datasets, condSVNP_hyper, nIter)
  # save stan-ready data
  readr::write_rds(dataStanSVNP_hyper, file = "data/dataStanSVNP_hyper.RDS")
} else{
  # load stan-ready data generally
  dataStanSVNP_hyper <- readr::read_rds("data/dataStanSVNP_hyper.RDS")
}

## Execute simulation for SVNP hyper ---------------------------------------------
# breaks
if( file.exists("output/resultsSVNP_hyper.RDS")){
  stop("output already exists. Please remove or backup before proceeding.")
}else if (length(dataStanSVNP_hyper) != (nIter*condSVNP_hyper)){
    stop("something went wrong with simulating the data!")
}else{
  # do the sampling where every available core (nWorkers in condtions.R) does 
  #    one unique combination of conditions
  # measure start time
  startTimeSVNP <- Sys.time()
  # create clusters
  clusters <- makePSOCKcluster(nClusters) 
  # source functions & parameters within clusters
  clusterCall(clusters, 
              function() source('R/functions.R'))
  clusterCall(clusters, 
              function() source('R/parameters.R'))
  # Load packages per cluster
  clusterCall(clusters, 
              function() lapply(packages, library, character.only = TRUE))
  # read in stan-ready data within clusters
  clusterCall(clusters,
              function() dataStanSVNP_hyper <- readr::read_rds("data/dataStanSVNP_hyper.RDS"))
  
  # run function clustered over individual combo's of 
  #  iteration, condPop and condPrior
  outputFinalSVNP_hyper  <- clusterApplyLB(clusters, 
                                          1:length(dataStanSVNP_hyper),
                                          sampling,
                                          dataStan = dataStanSVNP_hyper, 
                                          prior = "SVNP_hyper",
                                          modelPars = modelPars, 
                                          samplePars = samplePars)
  # close clusters
  stopCluster(clusters) 
  # measure end time
  endTimeSVNP_hyper  <- Sys.time()
  # measure elapsed time
  elapsedTimesSVNP_hyper <- endTimeSVNP_hyper-startTimeSVNP_hyper
}

# Execute simulation for RHSP ---------------------------------------------

# load data if it exists, else make it
if (file.exists("data/dataStanRHSP.RDS")) {
  dataStanRHSP <- read_rds("data/dataStanRHSP.RDS")
}else{
# prepare data for stan
dataStanRHSP <- prepareDat(datasets, condRHSP, nIter)
# save stan-ready data
save(dataStanRHSP, file = "~/data/dataStanRHSP.RDS")
}

## Execute simulation for RHSP ---------------------------------------------
if( file.exists("output/resultsRHSP.RDS")){
  stop("output already exists. Please remove or backup before proceeding.")
}else {
if (length(dataStanRHSP) != (nIter*condRHSP)){
  stop("something went wrong with simulating the data!")
}
# do the sampling where every available core (nWorkers in condtions.R) does
#    one unique combination of conditions
# measure start time
startTimeRHSP <- Sys.time()
# create clusters
clusters <- makePSOCKcluster(nClusters)
# source functions & parameters within clusters
clusterCall(clusters,
           function() source('~/1vs2StepBayesianRegSEM/R/functions.R'))
clusterCall(clusters,
           function() source('~/1vs2StepBayesianRegSEM/R/parameters.R'))
# Load packages per cluster
clusterCall(clusters,
           function() lapply(packages, library, character.only = TRUE))
# read in stan-ready data within clusters
clusterCall(clusters,
           function() load("~/1vs2StepBayesianRegSEM/data/dataStanRHSP.RDS"))

# run functon in clustered way where it's clustered over individual combo's of
#  iteration, condPop and condPrior
outputFinalRHSP <- clusterApplyLB(clusters,
                                 1:length(dataStanRHSP),
                                 sampling,
                                 dataStan = dataStanRHSP,
                                 prior = "RHSP",
                                 modelPars = modelPars,
                                 samplePars = samplePars)
# close clusters
stopCluster(clusters)
# measure end time
endTimeRHSP <- Sys.time()
#measure elapsed time
elapsedTimesRHSP <- endTimeRHSP-startTimeRHPS
}






