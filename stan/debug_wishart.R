
# general prep ------------------------------------------------------------

source('R/functions.R')
source('R/parameters.R')

model <- cmdstan_model("stan/SVNP.stan")
model_wishart <- cmdstan_model("stan/SVNP_wishart.stan")

dataStanSVNP <- readr::read_rds("data/dataStanSVNP.RDS")


# svnp normal -------------------------------------------------------------
datCurrent<- dataStanSVNP[[1]]
samples_wishart <- model$sample(data = datCurrent,
                                chains = samplePars$nChain, 
                                iter_warmup = samplePars$nWarmup,
                                iter_sampling = samplePars$nSampling)
rstanObj <- read_stan_csv(samples_wishart$output_files()) # works

# these kind of steps done in post process
crossMatrix <- as.matrix(rstanObj, pars = "lambdaCrossC") 

# wishart -----------------------------------------------------------------

dataStanSVNP_wishart <- purrr::imap(dataStanSVNP, 
                                    ~ { .x$S <- cov(.x$Y) 
                                    .x$Y <- NULL
                                    return(.x)
                                    } )
datCurrent_wishart <- dataStanSVNP_wishart[[1]]

samples_wishart <- model_wishart$sample(data = datCurrent_wishart,
                        chains = samplePars$nChain, 
                        iter_warmup = samplePars$nWarmup,
                        iter_sampling = samplePars$nSampling)

rstanObj <- read_stan_csv(samples_wishart$output_files()) 
draws <- samples_wishart$draws()
