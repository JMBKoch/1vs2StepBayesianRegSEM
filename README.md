# Getting A Step Ahead: Using the Regularized Horseshoe Prior to Select Cross-Loadings in Bayesian Regularized Structural Equation Modeling (SEM)


This repository contains the code of my Master's Thesis in Methodology & Statistics at Utrecht University (September '21 - June '22). 

You can clone the repository by running:

`git clone https://github.com/JMBKoch/1vs2StepBayesianRegSEM/`.

- The most recent version of the research article reporting the results of this project can be found on [`/Rmd/thesis`](/Rmd/thesis).

- Note that all scripts assume that this repository has been cloned to the home directory of a unix-based system. Hence, if you're on Windows or you want to work from a different path, you will have to adjust the paths in [`R/main.R`](/R/main.R) (and in [`Rmd/analyses`](Rmd/analyses) manually. 

- The simulation study can be conducted by sourcing or running [`R/main.R`](/R/main.R). Note that all study-parameters, including the MCMC sampling parameters, and the number of clusters used in the parallelization are specified in [`R/parameters.R`](R/parameters.R).  [`R/functions.R`](R/functions.R) contains all functions that are used in [`R/main.R`](/R/main.R). If you want to re-run the simulation, please first uncomment line 28 & 29 in [`R/main.R`](/R/main.R). This ensures that the output is removed and newly saved. Otherwise the new results will be appended to the old ones. 

- Packages should be installed automatically, if they are not yet. However, this may not work on all systems/ versions of R. Hence, if the script does not run checking if the packages are installed correctly may be a sensible first step in the debugging process. An overview of the required packages can be found at the top (line 7-13) of [`R/parameters.R`](R/parameters.R). 

- In order for `cmdstanr` to work, it is required to run `cmdstanr::install_cmdstan()` a single time. 

- Note that if the model is adjusted, the code in [`stan`](stan) needs to be adjusted accordingly as well. 

- [`data`](data) contains the raw datasets that were simulated based on the population conditions. It will be simulated and saved again when running [`R/main.R`](R/main.R).


(c) J.M.B. Koch, 2022
