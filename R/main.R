# main.R                                              (c) J.M.B. Koch 2022
# This is the main script running the simulation 
# Dependencies: functions.R; parameters.R; 

# source functions and conditions outside clusters ------------------------
source('R/functions.R')
source('R/parameters.R')

# check on right cmdstanr config -----------------------------------------
if (!as.package_version(cmdstanr::cmdstan_version()) <= as.package_version("2.34.0")){
  cli::cli_abort("cmdstanr version must be 2.34.0 (or lower) due to this bug: {.url https://github.com/stan-dev/rstan/issues/1133?utm_source=chatgpt.com}")
}

# SVNP  ------------------------------------------------------------

## Prepare data SVNP ------------------------------------------------------------
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
}else if (length(dataStanSVNP) != (nIter*nrow(condSVNP) * nrow(condPop))){
  stop("something went wrong with simulating the data!")
}

startTimeSVNP<- Sys.time()
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
            function() dataStanSVNP_wishart <- readr::read_rds("data/dataStanSVNP.RDS"))
# run function clustered over individual combo's of
#  iteration, condPop and condPrior
outputFinalSVNP_hyper  <- clusterApplyLB(clusters,
                                         1:length(dataStanSVNP),
                                         sampling,
                                         dataStan = dataStanSVNP,
                                         prior = "SVNP",
                                         modelPars = modelPars,
                                         samplePars = samplePars,
                                         wishart = FALSE)
# close clusters
stopCluster(clusters)
# measure end time
endTimeSVNP <- Sys.time()
# measure elapsed time
elapsedTimesSVNP <- endTimeSVNP-startTimeSVNP
elapsedTimesSVNP


# SVNP wishart ------------------------------------------------------------
## Prepare data for SVNP wishart ------------------------------------------------------------
# We can simply transform all simulated datasets to the empirical covariance matrix
dataStanSVNP_wishart <- purrr::imap(dataStanSVNP, 
                                   ~ { .x$S <- cov(.x$Y) 
                                       .x$Y <- NULL
                                       return(.x)
                                      } )


## Execute simulation for SVNP wishart ---------------------------------------------

# measure start time
startTimeSVNP_wishart <- Sys.time()
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

# export stan-ready data to cluster scope
clusterExport(clusters,
             varlist = c("dataStanSVNP_wishart"))
# run function clustered over individual combo's of
#  iteration, condPop and condPrior
outputFinalSVNP_wishart <- clusterApplyLB(clusters,
                                         1:length(dataStanSVNP_wishart),
                                         sampling,
                                         dataStan = dataStanSVNP_wishart,
                                         prior = "SVNP",
                                         modelPars = modelPars,
                                         samplePars = samplePars,
                                         wishart = TRUE)
# close clusters
stopCluster(clusters)
# measure end time
endTimeSVNP_wishart  <- Sys.time()
# measure elapsed time
elapsedTimesSVNP_wishart <- endTimeSVNP_wishart-startTimeSVNP_wishart
elapsedTimesSVNP_wishart

# SVNP hyper ------------------------------------------------------------
## Prepare data SVNP hyper ------------------------------------------------------------
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
if (file.exists("output/resultsSVNP_hyper.RDS")){
    stop("output already exists. Please remove or backup before proceeding.")
} else if (length(dataStanSVNP_hyper) != (nIter*nrow(condSVNP_hyper) * nrow(condPop))){
    stop("something went wrong with simulating the data!")
}

# do the sampling where every available core (nWorkers in condtions.R) does
#    one unique combination of conditions
# measure start time
startTimeSVNP_hyper <- Sys.time()
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
                                        samplePars = samplePars,
                                        wishart = FALSE)
# close clusters
stopCluster(clusters)
# measure end time
endTimeSVNP_hyper  <- Sys.time()
# measure elapsed time
elapsedTimesSVNP_hyper <- endTimeSVNP_hyper-startTimeSVNP_hyper
elapsedTimesSVNP_hyper

# SVNP hyper wishart ------------------------------------------------------
## prepare data voor SVNP hyper wishart ------------------------------------
dataStanSVNP_hyper_wishart <- purrr::imap(dataStan_hyper, 
                                      ~ { .x$S <- cov(.x$Y) 
                                      .x$Y <- NULL
                                      return(.x)
                                      } )

## Execute simulation for SVNP hyper wishart ---------------------------------------------

# measure start time
startTimeSVNP_hyper_wishart <- Sys.time()

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
# export stan-ready data to cluster scope
clusterExport(clusters,
              varlist = c("dataStanSVNP_hyper_wishart"))
# sample
outputFinalSVNP_hyper_wishart  <- clusterApplyLB(clusters,
                                         1:length(dataStanSVNP_hyper_wishart),
                                         sampling,
                                         dataStan = dataStanSVNP_hyper_wishart,
                                         prior = "SVNP_hyper",
                                         modelPars = modelPars,
                                         samplePars = samplePars,
                                         wishart = TRUE)
# close clusters
stopCluster(clusters)
# measure end time
endTimeSVNP_hyper_wishart  <- Sys.time()
# measure elapsed time
elapsedTimesSVNP_hyper_wishart <- endTimeSVNP_hyper_wishart-startTimeSVNP_hyper_wishart
elapsedTimesSVNP_hyper_wishart

# RHSP --------------------------------------------------------------------

## Prepare data voor RHSP ---------------------------------------------

# load data if it exists, else make it
# if (file.exists("data/dataStanRHSP.RDS")) {
#   dataStanRHSP <- readr::read_rds("data/dataStanRHSP.RDS")
# }else{
# # prepare data for stan
# dataStanRHSP <- prepareDat(datasets, condRHSP, nIter)
# # save stan-ready data
# save(dataStanRHSP, file = "~/data/dataStanRHSP.RDS")
# }

## Execute simulation for RHSP ---------------------------------------------
# if( file.exists("output/resultsRHSP.RDS")){
#   stop("output already exists. Please remove or backup before proceeding.")
# }else {
# if (length(dataStanRHSP) != (nIter*nrow(condRHSP) * nrow(condPop))){
#   stop("something went wrong with simulating the data!")
# }
# 
# # measure start time
# startTimeRHSP <- Sys.time()
# # create clusters
# clusters <- makePSOCKcluster(nClusters)
# # source functions & parameters within clusters
# clusterCall(clusters,
#            function() source('~/1vs2StepBayesianRegSEM/R/functions.R'))
# clusterCall(clusters,
#            function() source('~/1vs2StepBayesianRegSEM/R/parameters.R'))
# # Load packages per cluster
# clusterCall(clusters,
#            function() lapply(packages, library, character.only = TRUE))
# # read in stan-ready data within clusters
# clusterCall(clusters,
#            function() load("~/1vs2StepBayesianRegSEM/data/dataStanRHSP.RDS"))
# 
## sample
# outputFinalRHSP <- clusterApplyLB(clusters,
#                                  1:length(dataStanRHSP),
#                                  sampling,
#                                  dataStan = dataStanRHSP,
#                                  prior = "RHSP",
#                                  modelPars = modelPars,
#                                  samplePars = samplePars,
#                                  wishart = FALSE)
# # close clusters
# stopCluster(clusters)
# # measure end time
# endTimeRHSP <- Sys.time()
# #measure elapsed time
# elapsedTimesRHSP <- endTimeRHSP-startTimeRHPS


# RHSP wishart ------------------------------------------------------------


## Prepare data voor RHSP wishart ---------------------------------------------
# dataStanSVNP_wishart <- purrr::imap(dataStanRHSP, 
#                                     ~ { .x$S <- cov(.x$Y) 
#                                     .x$Y <- NULL
#                                     return(.x)
#                                     } )

## Execute simulation for RHSP wishart ---------------------------------------------

# # measure start time
# startTimeRHSP <- Sys.time()
# # create clusters
# clusters <- makePSOCKcluster(nClusters)
# # source functions & parameters within clusters
# clusterCall(clusters,
#             function() source('~/1vs2StepBayesianRegSEM/R/functions.R'))
# clusterCall(clusters,
#             function() source('~/1vs2StepBayesianRegSEM/R/parameters.R'))
# # Load packages per cluster
# clusterCall(clusters,
#             function() lapply(packages, library, character.only = TRUE))
# export stan-ready data to cluster scope
# clusterExport(clusters,
#               varlist = c("dataStanRHSP_wishart"))
# 
# # run functon in clustered way where it's clustered over individual combo's of
# #  iteration, condPop and condPrior
# outputFinalRHSP_wishart <- clusterApplyLB(clusters,
#                                   1:length(dataStanRHSP_wishart),
#                                   sampling,
#                                   dataStan = dataStanRHSP_wishart,
#                                   prior = "RHSP",
#                                   modelPars = modelPars,
#                                   samplePars = samplePars,
#                                   wishart = TRUE)
# # close clusters
# stopCluster(clusters)
# # measure end time
# endTimeRHSP_wishart <- Sys.time()
# #measure elapsed time
# elapsedTimesRHSP_wishart <- endTimeRHSP_wishart-startTimeRHPS_wishart