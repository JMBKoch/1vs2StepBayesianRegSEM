# Packages ----------------------------------------------------------------
# packages ----------------------------------------------------------------
# install renv if its not installed
if (!require(renv, quietly = TRUE)){
  install.packages("renv")
}
# activate renv env in current session
renv::activate()  
# restore current renv packages & versions
renv::restore(prompt = FALSE)


# cmdstanR setup ----------------------------------------------------------
cmdstanVersionReq <- "2.34.0"
cmdstanVersionInstalled <- tryCatch(
  cmdstanr::cmdstan_version(),
  error = function(e) NA
)

if(!cmdstanVersionReq %in% cmdstanVersionInstalled || is.na(cmdstanVersionInstalled)){
  cmdstanr::install_cmdstan(version = cmdstanVersionReq)
}


# load all packages -------------------------------------------------------
packages <- c("cmdstanr", # MCMC sampling using stan
                "rstan", # postprocessing of samples
                "tidyverse", # data wrangling, plotting, pipes
                "mvtnorm", # data simulation
                "parallel",
                "bayesplot", # convergence diagnostics 
                "here"
              )

# Attach all packages
invisible(lapply(cran_packages, function(pkg) {
  suppressPackageStartupMessages(library(pkg, character.only = TRUE))
}))
