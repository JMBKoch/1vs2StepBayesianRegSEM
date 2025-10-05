# main.R (c) J.M.B. Koch 2022
# This is the main script running the simulation 
# Dependencies: functions.R; parameters.R; 

# package setup  ---------------------------------------------------
# install renv if its not installed
source('renv/activate.R')
# required packages
pkgRequ <- c(
  "rstan", "tidyverse", "mvtnorm", "parallel", "bayesplot", "here", "cmdstanr", "furrr"
)

# install manually (renv::restore() is unreliable)
renv::install(pkgRequ)
pkgGithub <- c("cmdstanr" = "stan-dev/cmdstanr")

for (pkg in names(pkgGithub)) {
  renv::install(pkgGithub[[pkg]])
}

# ---- CmdStan installation if needed ----
cmdstanVersionReq <- "2.34.0"
cmdstanVersionInstalled <- tryCatch(
  cmdstanr::cmdstan_version(),
  error = function(e) NA
)
if(!cmdstanVersionReq %in% cmdstanVersionInstalled || is.na(cmdstanVersionInstalled)){
  cmdstanr::install_cmdstan(version = cmdstanVersionReq)
}

# ---- Load all packages ----
for (pkg in pkgRequ) {
  library(pkg, character.only = TRUE)
}

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

