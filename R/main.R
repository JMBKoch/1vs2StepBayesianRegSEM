# main.R                                              (c) J.M.B. Koch 2022
# This is the main script running the simulation 
# Dependencies: functions.R; parameters.R; 

# source functions and conditions in global scope ------------------------
source(here::here('R/packages.R'))
source(here::here('R/functions.R'))
source(here::here('R/parameters.R'))

SVNP <- runPipeline("SVNP_wishart")
SVNP$timeElapsed