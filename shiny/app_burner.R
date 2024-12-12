# Load necessary libraries
library(LaplacesDemon)
library(TeachingDemos)

# Parameters
ndraws <- 1e+04 # Sample size
sigma_squ <- c(0.1, 0.01, 0.001)
scaleGlobals <- c(0.1, 1)
scaleLocals <- c(0.1, 1)
dfGlobals <- c(1, 3)
dfLocals <- c(1, 3)
nus <- c(1, 3)
scaleSlabs <- c(0.1, 1, 5)

# Function to generate RHSP samples
sample_rhsp <- function(ndraws, nu, scaleGlobal, scaleLocal, dfGlobal, dfLocal, scaleSlab) {
  regHs <- numeric(ndraws)
  for (i in 1:ndraws) {
    c2 <- rinvgamma(1, shape = nu, scale = scaleSlab)
    lambda <- rhalfcauchy(dfGlobal, scale = scaleGlobal)
    tau <- rhalfcauchy(dfLocal, scale = scaleLocal)
    lambda2_tilde <- c2 * lambda^2 / (c2 + tau^2 * lambda^2)
    regHs[i] <- rnorm(1, mean = 0, sd = sqrt(tau^2 * lambda2_tilde))
  }
  regHs
}

# Pre-draw samples for SVNP
svnp_samples <- lapply(sigma_squ, function(sigma_squ) {
  rnorm(ndraws, mean = 0, sd = sqrt(sigma_squ))
})
names(svnp_samples) <- paste0("SVNP_sigma_", sigma_squ)

# Pre-draw samples for RHSP
rhsp_samples <- list()
for (nu in nus) {
  for (scaleGlobal in scaleGlobals) {
    for (scaleLocal in scaleLocals) {
      for (dfGlobal in dfGlobals) {
        for (dfLocal in dfLocals) {
          for (scaleSlab in scaleSlabs) {
            key <- paste0("RHSP_nu_", nu, "_scaleGlobal_", scaleGlobal, "_scaleLocal_", scaleLocal,
                          "_dfGlobal_", dfGlobal, "_dfLocal_", dfLocal, "_scaleSlab_", scaleSlab)
            rhsp_samples[[key]] <- sample_rhsp(ndraws, nu, scaleGlobal, scaleLocal, dfGlobal, dfLocal, scaleSlab)
          }
        }
      }
    }
  }
}

# Save pre-drawn samples
saveRDS(svnp_samples, "svnp_samples.Rds")
saveRDS(rhsp_samples, "rhsp_samples.Rds")
