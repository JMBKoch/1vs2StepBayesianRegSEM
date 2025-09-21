# functions.R                                             (c) J.M.B. Koch 2022
# All functions used in main.R
# dependencies: tidyverse (magrittr, tidyr, dplyr, ggplot2), mvtnorm, bayesplot

# Part 1: functions for executing simulation study
# simDatasets() -----------------------------------------------------------
# function that prepares a list with (nIter X nrow(cond)) datasets 
simDatasets <- function(condPop, modelPars, nIter){
   
    ### TBA: work with different levels of cross-loadings!!!
    simY <- function(main, cross, Psi, Theta, N){
      L <- matrix(NA, nrow = 6, ncol = 2)
      L[1:3, 1] <- main[1:3]
      L[4:6, 2] <- main[4:6]
      L[4:6, 1] <- cross[1:3]
      L[1:3, 2] <- cross[4:6]
      Sigma <- L%*%Psi%*%t(L) + Theta
      Y <- mvtnorm::rmvnorm(N, rep(0, 6), Sigma)
      return(Y)
    }
    
    # allocate memory for the final output, a nested list
    datasets <- list()
    
    # prepare nIter x "# unique combination of conditions" datasets
    for (i in 1:nrow(condPop)){
      # simulate & prepare data 50x per set of conditions (row of conditionsRHSP)
      dat <- list()
      for (j in 1:nIter){
        
        # specify crossloadings & N based on conditions
        if(condPop[i, ]$cross == 0.2){
          cross <- modelPars$cross2
        } else{
          cross <- modelPars$cross5
        }
        
        N <- condPop[i, ]$N
        
        dat[[j]] <- simY(modelPars$main, cross = cross, modelPars$Psi, modelPars$Theta, N)
      }
      # save data in appropriate element of final output
      datasets[[i]] <- list(dat)
    }
    # return datasets
    return(datasets)

}

# prepareDat() ------------------------------------------------------------

# function to prepare stan data object from a unique element of the output of simDat()
# based on a unique combination of hyper-pars
prepareDat <- function(datasets, condPrior, nIter){ 
  
  # helper function for unlisting on only first level;
  #  (c) Heibl 2016 (https://github.com/heibl/ips/blob/master/R/unlistFirstLevel.R)
  #  (didn't just use package because not possible with version of R I'm using)
  unlistFirstLevel <- function(z, use.names = TRUE){
    
    ## get ID of elements which are list ...
    id <- sapply(z, is.list)
    ## ... but not of class 'phylo'
    id <- id & !sapply(z, inherits, what =  "phylo")
    
    if ( any(id) ){
      
      ## unlist
      zz <- vector(mode = "list")
      for ( i in seq_along(z) ){
        if ( id[i] ) zz <- c(zz, z[[i]])
        else zz <- c(zz, z[i])
      }
      
      ## preserve names
      if ( use.names ){
        d <- sapply(z, length)
        names(zz) <- rep(names(d), d)
      }
      
      z <- zz
    }
    z
  }
  
  # allocate memory for nIter datasets per set of current prior conditions
  dataStanCondCurrent <- list()
  
  # allocate memory for nested output
  dataStan <- list()
  
  # unlist datasets
  datasetsUnlisted <- lapply(rapply(datasets, enquote, how = "unlist"), eval)
  
  # make vector of the cross-loading: based on datasim, this is simply 0.2
  #  for first half, and 0.5 for second half. 
  cross <- numeric(length(datasetsUnlisted))
  cross[1:length(datasetsUnlisted)/2] <- 0.2
  cross[(length(datasetsUnlisted)/2 + 1):length(datasetsUnlisted)] <- 0.5
  # make vector of iteration
  iter <- rep(1:nIter, length(datasets))

  # start nested loop
  for (pos in 1:nrow(condPrior)){
    for(i in 1:length(datasetsUnlisted)){ 

    
    # grab current conditions
    condCurrent <- condPrior[pos, ]
    
    # grab current dataset
    Y <- datasetsUnlisted[[i]]

    
    if(condCurrent$prior == "SVNP"){
  
      dataStanCondCurrent[[i]] <-  list(
        N = nrow(Y),
        cross = cross[i],
        iter = iter[i],
        P = ncol(Y),
        Q = 2,
        Y = (Y), 
        #prior = "SVNP",
        sigma = condCurrent$sigma
      )
    }else if(condCurrent$prior == "SVNP_hyper"){
      
      dataStanCondCurrent[[i]] <-  list(
        N = nrow(Y),
        cross = cross[i],
        iter = iter[i],
        P = ncol(Y),
        Q = 2,
        Y = (Y)
        #prior = "SVNP",
      )
    } else if(condCurrent$prior == "RHSP"){
      dataStanCondCurrent[[i]] <- list(
        N = nrow(Y),
        cross = cross[i],
        iter = iter[i],
        P = ncol(Y),
        Q = 2,
        Y = Y, 
        #prior = "RHSP",
        scaleGlobal = condCurrent$scaleGlobal, # scale omega
        scaleLocal = condCurrent$scaleLocal, # scale lambda
        dfGlobal = condCurrent$dfGlobal, # df for half-t prior omega
        dfLocal = condCurrent$dfLocal, # df for half-t prior tau_j
        nu = condCurrent$nu, # df IG for c^2
        scaleSlab = condCurrent$scaleSlab # scale of slab
      )
      } 
    } 
    dataStan[[pos]] <- dataStanCondCurrent
  }
  #return unnested output, such that it can be looped over in sampling()
  unlistFirstLevel(dataStan)
}

# saveResults() ------------------------------------------------------------
# function takes rstan object and saves the results 
saveResults <- function(rstanObj, condPrior, condPop, modelPars){
  
  # save sigma for SVNP_hyper
  if(condPrior$prior == "SVNP_hyper"){
    SigmaEstMean <- apply(as.matrix(rstanObj, pars = "sigma"), 2, mean)
    SigmaEstMed <- apply(as.matrix(rstanObj, pars = "sigma"), 2, median)
  }
  
  # save true cross loading based on condPop
  crossTrue <- numeric(6)
  if (condPop$cross == 0.5){
    crossTrue <- c(0.5, 0, 0, 0, 0, 0.5)
  }else if (condPop$cross == 0.2){
    crossTrue <- c(0.2, 0, 0, 0, 0, 0.2)
  }
  # save in format that's convenient for computing quantiles below
  crossMatrix <- as.matrix(rstanObj, pars = "lambdaCrossC") 
  
  # estimates Lambda 
  mainEstMean <- apply(as.matrix(rstanObj, pars = "lambdaMainC"), 2, mean)
  mainEstMed <-  apply(as.matrix(rstanObj, pars = "lambdaMainC"), 2, median)
  mainEstVar <-  apply(as.matrix(rstanObj, pars = "lambdaMainC"), 2, var)
  crossEstMean <- apply(crossMatrix, 2, mean)
  crossEstMed <-  apply(crossMatrix, 2, median)
  crossEstVar <-  apply(crossMatrix, 2, var)
  

  # estimates Theta
  thetaEstMean <- apply(as.matrix(rstanObj, pars = "theta"), 2, mean)
  thetaEstMed <- apply(as.matrix(rstanObj, pars = "theta"), 2, median)
  thetaEstVar <- apply(as.matrix(rstanObj, pars = "theta"), 2, var)
  
  # estimate Factor-Corr
  factCorrEstMean <-  apply(as.matrix(rstanObj, pars = "PsiC[2, 1]"), 2, mean)
  factCorrEstMed <-   apply(as.matrix(rstanObj, pars = "PsiC[2, 1]"), 2, median)
  factCorrEstVar <-   apply(as.matrix(rstanObj, pars = "PsiC[2, 1]"), 2, var)

  ## bias
  # mean
  biasMainMean <-     abs(mainEstMean - modelPars$main)
  biasCrossMean <-    abs(factCorrEstMean - crossTrue)
  biasThetaMean <-    abs(thetaEstMean - diag(modelPars$Theta))
  biasFactCorrMean <- abs(factCorrEstMean - modelPars$Psi[2, 1])
  
  # median
  biasMainMed <-     abs(mainEstMed - modelPars$main)
  biasCrossMed <-    abs(factCorrEstMed - crossTrue)
  biasThetaMed <-    abs(thetaEstMed - diag(modelPars$Theta))
  biasFactCorrMed <- abs(factCorrEstMed - modelPars$Psi[2, 1])
  
  
  ## Selection part of CrossLoadings, i.e. different configs of credible intervals
  # compute Quantiles of Cross loadings
  crossQuantiles <- t(apply(crossMatrix, 2, quantile, c(0.025, 0.975, 0.05, 0.95, 0.10, 0.90, 0.25, 0.75)))
  # Compute IsZero based on Tresholds
  isZeroTres0.10Mean <- sapply(crossEstMean, function(x) ifelse(abs(x) < 0.10, 0, 1))
  isZeroTres0.10Med <- sapply(crossEstMed, function(x) ifelse(abs(x) < 0.10, 0, 1))
  isZeroTres0.15Mean <- sapply(crossEstMean,  function(x) ifelse(abs(x) < 0.15, 0, 1))
  isZeroTres0.15Med <- sapply(crossEstMed, function(x) ifelse(abs(x) < 0.15, 0, 1))
  isZeroTres0.05Mean <- sapply(crossEstMean,  function(x) ifelse(abs(x) < 0.05, 0, 1))
  isZeroTres0.05Med <- sapply(crossEstMed, function(x) ifelse(abs(x) < 0.05, 0, 1))
  isZeroTres0Mean <- sapply(crossEstMean,  function(x) ifelse(abs(x) == 0, 0, 1))
  isZeroTres0Med <- sapply(crossEstMed, function(x) ifelse(abs(x) == 0, 0, 1))
  # Compute IsZero based on CI'
  isZero95CI <- apply(crossQuantiles[, 1:2] , 1 , function(x) between(0, x[1], x[2]))
  isZero90CI <- apply(crossQuantiles[, 3:4] , 1 , function(x) between(0, x[1], x[2]))
  isZero80CI <- apply(crossQuantiles[, 5:6] , 1 , function(x) between(0, x[1], x[2]))
  isZero50CI <- apply(crossQuantiles[, 7:8] , 1 , function(x) between(0, x[1], x[2]))
  
  # cbind and return output
  out <- cbind(1:6,
               mainEstMean, 
               mainEstMed,
               mainEstVar,
               biasMainMean,
               biasMainMed,
               crossEstMean,
               crossEstMed,
               crossEstVar,
               biasCrossMean,
               biasCrossMed,
               thetaEstMean,
               thetaEstMed,
               thetaEstVar,
               biasThetaMean,
               biasThetaMed,
               crossQuantiles,
               isZeroTres0.10Mean,
               isZeroTres0.10Med,
               isZeroTres0.15Mean,
               isZeroTres0.15Med,
               isZeroTres0.05Mean,
               isZeroTres0.05Med,
               isZeroTres0Mean,
               isZeroTres0Med,
               isZero95CI,
               isZero90CI,
               isZero80CI, 
               isZero50CI) %>% 
        as_tibble()
  colnames(out)[1] <- "item"
  

  # recode output into wide format and cbind convergence into it
  out <- tidyr::pivot_wider(out, 
                            names_from = item, 
                            values_from = colnames(out[-1])) 
  # cbind in est Sigma foor SVNP_hyper
  if (condPrior$prior == "SVNP_hyper") {
    out <- cbind(out, SigmaEstMean)
    out <- cbind(out, SigmaEstMed)
  }
  
  # cbind estimates of corr (only 1 per six items) into output
  out <- cbind(out, 
               factCorrEstMean, 
               factCorrEstMed, 
               factCorrEstVar,
               biasFactCorrMean,
               biasFactCorrMed)

  
  ## cinb
  out <- cbind(out, condPrior, condPop)
  rownames(out) <- NULL
  
  # return output
  return(out)
  
}

# convergence() -----------------------------------------------------------
# takes rstan object as input and computes and returns convergence diagnostics
convergence <- function(rstanObj, condPrior, condPop) {
  
  # start with Rhat and n_eff
  conv <- as.data.frame(
    t(summary(rstanObj, pars = c("lambdaMainC", 
                                 "lambdaCrossC", 
                                 "PsiC[1,2]", 
                                 "theta"))$summary[, 9:10]))
  
  # recode output into a nicer format and including condition config
  conv$parameter <- rownames(conv)
  rownames(conv) <- NULL
  
  # add max treedepth and sum divergent transitions
  tree <- subset(bayesplot::nuts_params(rstanObj), Parameter == "treedepth__")
  conv$maxTree <- max(tree$Value)
  div <- subset(bayesplot::nuts_params(rstanObj), Parameter == "divergent__")
  conv$sumDiv  <- sum(div$Value)
  # save runtime
  time  <-  get_elapsed_time(rstanObj)
  conv$warmupT1 <- time["chain:1", "warmup"]
  conv$warmupT2 <- time["chain:2", "warmup"]
  conv$sampleT1 <- time["chain:1", "sample"]
  conv$sampleT2 <- time["chain:2", "sample"]
  # cbind conditions into output
  conv <- cbind(conv, 
                rbind(condPrior, condPrior), #rbinding to avoid warning of short variable row names
                rbind(condPop, condPop)) 
  # return output
  return(conv)
  
}

# sampling() --------------------------------------------------------------
# takes as input the conditions chain-length, warmup, n_chains, n_parallel chains &
#   all hyperparameters sourced from parameters.R
sampling <- function(pos, prior, dataStan, modelPars, samplePars, wishart){
  
  
  # select current data
  datCurrent <- dataStan[[pos]]
  
  # Execute prior-specific steps
  if (prior == "SVNP"){
    
    # compile model (if already compiled this will just not be executed)
    if (wishart) {
      model <- cmdstan_model(here::here("stan/SVNP_wishart.stan"))
    } else{
      model <- cmdstan_model(here::here("stan/SVNP.stan"))
    }

    # select current hyper-parameter conditions
    condPriorCurrent <- data.frame(
                           prior = "SVNP",
                           sigma = datCurrent$sigma
                           )
      
  } else if (prior == "SVNP_hyper"){
    
    # compile model (if already compiled this will just not be executed)
    if (wishart) {
      model <- cmdstan_model(here::here("stan/SVNP_hyper_wishart.stan"))
    } else{
      model <- cmdstan_model(here::here("stan/SVNP_hyper.stan"))
    }
    
    # select current hyper-parameter conditions
    condPriorCurrent <- data.frame(
      prior = "SVNP_hyper")

    } else if (prior == "RHSP"){
    
    if (wishart) {
        model <- cmdstan_model(here::here("stan/RHSP_wishart.stan"))
    } else{
        model <- cmdstan_model(here::here("stan/RHSP.stan"))
      }
    
    # select current hyper-parameter conditions
    condPriorCurrent <- data.frame(prior = "RHSP",
                                   scaleGlobal = datCurrent$scaleGlobal,
                                   scaleLocal = datCurrent$scaleLocal,
                                   dfGlobal = datCurrent$dfGlobal,
                                   dfLocal = datCurrent$dfLocal,
                                   nu = datCurrent$nu,
                                   scaleSlab = datCurrent$scaleSlab)
  }
  
  # specify current condPop
  condPopCurrent <- data.frame(
    N = datCurrent$N,
    cross = datCurrent$cross
  )
  
  # Draw the Samples 
  samples <- model$sample(data = datCurrent,
                          chains = samplePars$nChain, 
                          iter_warmup = samplePars$nWarmup,
                          iter_sampling = samplePars$nSampling)
  
  # save as rstan object
  rstanObj <- read_stan_csv(samples$output_files())
  
  # save Results
  output <- saveResults(rstanObj,
                        condPrior = condPriorCurrent, 
                        condPop = condPopCurrent, 
                        modelPars = modelPars)
  # add iteration to output
  output$iteration <- datCurrent$iter
  # add pos (for easy matching based on unique codition config)
  output$pos <- pos
  # rbind output into final output
  # save convergence diagnostics
  conv <- convergence(rstanObj, condPrior = condPriorCurrent, condPop = condPopCurrent)
  # add iteration
  conv$iteration <- datCurrent$iter
  # add pos (for easy matching based on unique condition config)
  conv$pos <- pos
    
  # Write output to disk (per set of conditions in an appending fashion)
  if (!dir.exists(here::here("output/"))){
    message("creating output dir because it doesn't exist")
  }
  # Define file paths
  spec_suffix <- ifelse(wishart, "_wishart", "")
  resultsPath <- paste0(here::here("output/"),
                        "results", 
                        condPriorCurrent$prior,
                        spec_suffix,
                        ".RDS")
  
  convPath<- paste0(here::here("output/"),
                     "conv", 
                     condPriorCurrent$prior,
                     spec_suffix,
                     ".RDS")
  
  # Function to append new results to existing file
  append_rds <- function(new_data, file_name) {
    if (file.exists(file_name)) {
      # Read existing data
      existing_data <- read_rds(file_name)
      
      # Combine old and new data
      combined_data <- dplyr::bind_rows(existing_data, new_data) 
      
      # Write updated data back
      write_rds(combined_data, file_name)
    } else {
      # If file doesn't exist, simply write new data
      write_rds(new_data, file_name)
    }
  }
  
  # Save results in an appending manner
  append_rds(output, resultsPath)
  append_rds(conv, convPath)
 
  # return list with results and convergence diags
  return(list(results = output,
              convergence = conv))
  
}


# runPipeline()  --------------------------------
runPipeline <- function(prior, 
                        wishart, 
                        condPop,
                        modelPars,
                        nIter,
                        condPrior
                        ){
  
  projRoot <- here::here()
  
  # simulate pop data if it doesnt exist yet
  if (!file.exists(here::here('data/datasets.RDS'))){
    datasets <- simDatasets(condPop, 
                            modelPars, 
                            nIter)
    message('Population data generated and saved to data/datasets.RDS')
    readr::write_rds(datasets, here::here('data/datasets.RDS'))
  } else {
    datasets <- readr::read_rds(here::here('data/datasets.RDS'))
    message('Population data read in from data/datasets.RDS')
  }
  
  # simulate data for current prior if it doesnt exist yet
  # read in data for current prior if it already exists
  
  datModelPath <- paste0(projRoot, '/data/data', prior, ".RDS")
  if (!file.exists(datModelPath)){
    datStanModel <- prepareDat(datasets, condPrior, nIter)
    
    readr::write_rds(datStanModel, file = datModelPath)
    message(
      paste0('Data for ' , prior, ' generated and saved to ', datModelPath)
    )
  } else {
    datStanModel <- readr::read_rds(datModelPath)
  }
  
  # transform data to wishart format
  if (wishart) {
    datStanModel <- purrr::imap(datStanModel, 
                            ~ { .x$S <- cov(.x$Y) 
                                .x$Y <- NULL
                                return(.x)
                              })
  }
  
  # execute simulation for current prior
  suffix <- ifelse(wishart, "_wishart", "")
  outputPath <- paste0(here("output/"), prior, suffix, ".RDS")
  
  clusters <- makePSOCKcluster(nClusters)
  
  clusterExport(clusters, varlist = c("datStanModel"), 
                envir = environment())
  
  clusterEvalQ(clusters, {
    
    # packages
    library(here)
    source(here('R/packages.R'))
    # functions & params
    source(here('R/functions.R'))
    source(here('R/parameters.R'))
  })
  
  # run function clustered over individual combo's of
  #  iteration, condPop and condPrior
  
  message(paste0('Executing sampling for ', prior))
  
  outputFinalModel <- clusterApplyLB(clusters,
                                      1:length(datStanModel),
                                      sampling,
                                      dataStan = datStanModel,
                                      prior = prior,
                                      modelPars = modelPars,
                                      samplePars = samplePars,
                                      wishart = wishart)
  # close clusters
  stopCluster(clusters)
  
  return(list(prior= prior,
              wishart = wishart,
              output = outputFinalModel))
  
}

