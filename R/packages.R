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
