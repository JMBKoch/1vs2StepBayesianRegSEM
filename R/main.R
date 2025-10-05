# main.R (c) J.M.B. Koch 2022
# This is the main script running the simulation 
# Dependencies: functions.R; parameters.R; 

# pkg setup --------------------------------------------------------------
if (!requireNamespace("here", quietly = TRUE) ){
  install.packages("here")
}
source(here::here('R/packages.R'))

# source functions and conditions in global scope ------------------------
source(here::here('R/functions.R'))
source(here::here('R/parameters.R'))

# SVNP --------------------------------------------------------------------
SVNP <- runPipeline(prior = "SVNP", 
                    wishart = TRUE, 
                    condPop,
                    modelPars,
                    condPrior = condSVNP,
                    nIter,
                    nClusters)

# SVNP hyper --------------------------------------------------------------
SVNP_hyper <- runPipeline(prior = "SVNP_hyper", 
                          wishart = TRUE, 
                          condPop,
                          modelPars,
                          condPrior = condSVNP_hyper,
                          nIter,
                          nClusters)


# lasso -------------------------------------------------------------------
LASSO <- runPipeline(prior = "LASSO", 
                     wishart = TRUE, 
                     condPop,
                     modelPars,
                     condPrior = condLASSO,
                     nIter,
                     nClusters)

# lasso hyper -------------------------------------------------------------
LASSO_hyper <- runPipeline(prior = "LASSO_hyper", 
                           wishart = TRUE, 
                           condPop,
                           modelPars,
                           condPrior = condLASSO_hyper,
                           nIter,
                           nClusters)

# RHSP --------------------------------------------------------------------
RHSP <- runPipeline("RHSP", 
                    wishart = TRUE, 
                    condPop,
                    modelPars,
                    condPrior = condRHSP,
                    nIter,
                    nClusters)

