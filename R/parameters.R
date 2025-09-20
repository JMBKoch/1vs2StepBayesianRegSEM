################################################################################
# parameters.R                                            (c) J.M.B. Koch 2022
################################################################################
# This file contains the specification of all relevant study parameters
# setting seed for reproducibility ----------------------------------------
set.seed(0704)

# Model--------------------------------------------------------------------
# Lambda
main <- c(.75, .75, .75, .75, .75, .75)
cross2 <- c(.2, 0, 0, 0, 0, .2)
# Psi
Psi <- matrix(rep(NA, 4), ncol = 2)
diag(Psi) <- 1
Psi[1, 2] <- Psi[2, 1] <- 0.5
# Theta
Theta <- diag(rep(0.3, 6))
# save all in one object for easier passing to functions
modelPars <- list(
                main = main,
                cross2 = cross2,
                Psi = Psi,
                Theta = Theta
                  )

# Hyper-Parameters: -------------------------------------------------------
# Small Variance Normal Prior fixed ---------------------------------------------
sigma <- c(sqrt(0.1))

# Regularized Horseshoe Prior ---------------------------------------------
scaleGlobal <- c(1) # scale for half-t prior omega
scaleLocal <- c(1) # scale for half-t prior tau_j
dfGlobal <- c(1) # df for half-t prior omega
dfLocal <- c(1) # df for half-t prior tau_j
nu <- c(1) # df IG for c^2 (slab)
scaleSlab <- c(1) # scale of slab

# Population conditions ----------------------------------------------------
N <- c(100)
cross <- c(0.2)

# Making condition objects ------------------------------------------------
condPop   <- 
  expand.grid(
    N = N,
    cross = cross
  )

condSVNP <- 
  expand.grid(
    prior = "SVNP",
    sigma = sigma
  )

condSVNP_hyper <- 
  tibble(prior = "SVNP_hyper")

condRHSP <- 
  expand.grid(
    prior = "RHSP",
    scaleGlobal = scaleGlobal, 
    scaleLocal = scaleLocal,
    dfGlobal = dfGlobal,
    dfLocal = dfLocal,
    nu = nu,
    scaleSlab = scaleSlab
  )

# Sampling parameters -----------------------------------------------------
# save in one list for easier passing to functions
samplePars <- list(
                nChain = 2,
                nWarmup = 2000,
                nSampling = 4000
                )

# Parallelization Parameter -----------------------------------------------
nClusters <- 6 # depending on machine, original study run with 12 for SVNP and 46 for RHSP

# other study parameters --------------------------------------------------
nIter <- 10 # in paper(s) Iterations are referred to as "Replications"

# Convergence Criteria ----------------------------------------------------
convCriteria <- list(
  strict = list(
    minPropNEFF = .10,
    maxRhat = 1.05,
    maxPropDIV = .05
  )
)

# # Model--------------------------------------------------------------------
# # Lambda
# main <- c(.75, .75, .75, .75, .75, .75)
# cross1 <- c(.1, 0, 0, 0, 0, .1)
# cross2 <- c(.2, 0, 0, 0, 0, .2)
# cross5 <- c(.5, 0, 0, 0, 0, .5)
# # Psi
# Psi <- matrix(rep(NA, 4), ncol = 2)
# diag(Psi) <- 1
# Psi[1, 2] <- Psi[2, 1] <- 0.5
# # Theta
# Theta <- diag(rep(0.3, 6))
# # save all in one object for easier passing to functions
# modelPars <- list(
#   main = main,
#   cross1 = cross1,
#   cross2 = cross2,
#   cross5 = cross5,
#   Psi = Psi,
#   Theta = Theta
# )
# 
# # Hyper-Parameters: -------------------------------------------------------
# # Small Variance Normal Prior fixed ---------------------------------------------
# sigma <- c(sqrt(0.1), # specified such that sigma^2 > sigma
#            sqrt(0.01), 
#            sqrt(0.001))
# 
# # Regularized Horseshoe Prior ---------------------------------------------
# scaleGlobal <- c(0.1, 1) # scale for half-t prior omega
# scaleLocal <- c(0.1, 1) # scale for half-t prior tau_j
# dfGlobal <- c(1, 3) # df for half-t prior omega
# dfLocal <- c(1, 3) # df for half-t prior tau_j
# nu <- c(1, 3) # df IG for c^2 (slab)
# scaleSlab <- c(0.1, 1, 5) # scale of slab
# 
# # Population conditions ----------------------------------------------------
# N <- c(100, 200, 500)
# cross <- c(0.1, 0.2, 0.5)
# 
# # Making condition objects ------------------------------------------------
# condPop   <- 
#   expand.grid(
#     N = N,
#     cross = cross
#   )
# 
# condSVNP <- 
#   expand.grid(
#     prior = "SVNP",
#     sigma = sigma
#   )
# 
# condSVNP_hyper <- 
#   tibble(prior = "SVNP_hyper")
# 
# condRHSP <- 
#   expand.grid(
#     prior = "RHSP",
#     scaleGlobal = scaleGlobal, 
#     scaleLocal = scaleLocal,
#     dfGlobal = dfGlobal,
#     dfLocal = dfLocal,
#     nu = nu,
#     scaleSlab = scaleSlab
#   )
# 
# # Sampling parameters -----------------------------------------------------
# # save in one list for easier passing to functions
# samplePars <- list(
#   nChain = 2,
#   nWarmup = 2000,
#   nSampling = 4000
# )
# 
# # Parallelization Parameter -----------------------------------------------
# nClusters <- 6 # depending on machine, original study run with 12 for SVNP and 46 for RHSP
# 
# # other study parameters --------------------------------------------------
# nIter <- 200 # in paper(s) Iterations are referred to as "Replications"
# 
# # Convergence Criteria ----------------------------------------------------
# convCriteria <- list(
#   strict = list(
#     minPropNEFF = .10,
#     maxRhat = 1.05,
#     maxPropDIV = .05
#   )
# )
# 
# 
# 
