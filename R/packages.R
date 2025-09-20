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

