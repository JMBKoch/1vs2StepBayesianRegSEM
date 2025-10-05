# ---------------- Package setup -------------------
# bootstrap renv
source('renv/activate.R')

# ----- Required packages -----
pkgCRAN <- c(
  "rstan", "tidyverse", "mvtnorm", "parallel", 
  "bayesplot", "here", "furrr"
)

pkgGithub <- c(
  "cmdstanr" = "stan-dev/cmdstanr"
)

# ----- Install missing CRAN packages -----
missingCRAN <- pkgCRAN[!sapply(pkgCRAN, function(pkg) {
  suppressWarnings(requireNamespace(pkg, quietly = TRUE))
})]

if(length(missingCRAN) > 0){
  message("Installing missing CRAN packages: ", paste(missingCRAN, collapse = ", "))
  renv::install(missingCRAN)
}

# ----- Install missing GitHub packages -----
missingGH <- names(pkgGithub)[!sapply(names(pkgGithub), function(pkg) {
  suppressWarnings(requireNamespace(pkg, quietly = TRUE))
})]

if(length(missingGH) > 0){
  for(pkg in missingGH){
    message("Installing GitHub package: ", pkgGithub[[pkg]])
    renv::install(pkgGithub[[pkg]])
  }
}

# ----- CmdStan installation if needed -----
cmdstanVersionReq <- "2.34.0"
cmdstanVersionInstalled <- tryCatch(
  cmdstanr::cmdstan_version(),
  error = function(e) NA
)
if(!cmdstanVersionReq %in% cmdstanVersionInstalled || is.na(cmdstanVersionInstalled)){
  cmdstanr::install_cmdstan(version = cmdstanVersionReq)
}

# ----- Load all packages -----
allPkgs <- c(pkgCRAN, names(pkgGithub))
for(pkg in allPkgs){
  library(pkg, character.only = TRUE)
}
