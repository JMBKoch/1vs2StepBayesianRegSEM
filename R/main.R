# main.R (c) J.M.B. Koch 2022
# This is the main script running the simulation 
# Dependencies: functions.R; parameters.R; 

# renv setup  ---------------------------------------------------
# install renv if its not installed
source('renv/activate.R')
renv::restore(prompt = FALSE)

# load packages and handle cmdstan install
source(here::here('R/packages.R'))

# source functions and conditions in global scope ------------------------
source(here::here('R/functions.R'))
source(here::here('R/parameters.R'))

# SVNP --------------------------------------------------------------------
SVNP <- runPipeline("SVNP_wishart")
SVNP$timeElapsed

# SVNP hyper --------------------------------------------------------------
SVNP_hyper <- runPipeline("SVNP_hyper_wishart")
SVNP_hyper$timeElapsed

# RHSP --------------------------------------------------------------------
RHSP <- runPipeline("RHSP_wishart")
RHSP$timeElapsed
