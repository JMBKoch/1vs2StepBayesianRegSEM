# source functions and conditions in global scope ------------------------
source('R/functions.R')
source('R/parameters.R')

model <- cmdstan_model("stan/RHSP_wishart.stan")

datSVNP <- readr::read_rds("data/dataSVNP.RDS")

datRHSP <- readr::read_rds("data/dataRHSP.RDS")
wishart <- TRUE
if (wishart) {
  datStanModel <- purrr::imap(datRHSP, 
                              ~ { .x$S <- cov(.x$Y) 
                              .x$Y <- NULL
                              return(.x)
                              })
}

datCurrent <- datStanModel[[1]]
samples <- model$sample(data = datCurrent,
                        chains = samplePars$nChain, 
                        iter_warmup = samplePars$nWarmup,
                        iter_sampling = samplePars$nSampling)

read_stan_csv(samples$output_files())


model_normal <- cmdstan_model("stan/RHSP.stan")

datCurrent_normal <- dataStanRHSP[[23]]


samples_normal <- model_normal$sample(data = datCurrent_normal,
                        chains = samplePars$nChain, 
                        iter_warmup = samplePars$nWarmup,
                        iter_sampling = samplePars$nSampling)
