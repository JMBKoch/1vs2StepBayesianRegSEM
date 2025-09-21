# required packages
pkgRequ <- c(
  "rstan", "tidyverse", "mvtnorm", "parallel", "bayesplot", "here", "cmdstanr", "furrr"
)

# missing packages
missing <- pkgRequ[!vapply(pkgRequ, requireNamespace, logical(1), quietly = TRUE)]

# github packages lookup
pkgGithubLookup <- list('cmdstanr' =  "stan-dev/cmdstanr")
# overwrite missing github names with their repo
missing[which(missing == names(pkgGithubLookup))] <- pkgGithubLookup[which(missing == names(pkgGithubLookup))]

if (length(missing) >= 1) {
  message("Installing missing packages ...")
  renv::install(missing, prompt = FALSE)
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
