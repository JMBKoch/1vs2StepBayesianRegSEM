# source functions and conditions in global scope ------------------------
source('R/functions.R')
source('R/parameters.R')

model <- cmdstan_model("stan/RHSP_wishart.stan")

model_normal <- cmdstan_model("stan/RHSP.stan")
samples <- model$sample(data = datCurrent,
                        chains = samplePars$nChain, 
                        iter_warmup = samplePars$nWarmup,
                        iter_sampling = samplePars$nSampling)