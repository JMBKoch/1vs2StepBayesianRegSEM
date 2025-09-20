// 2-Factor CFA with Wishart likelihood and LASSO prior on cross-loadings

data{
  int<lower=0> N;               // sample size used to compute S
  int<lower=1> P;               // number of items
  int<lower=1> Q;               // number of factors (=2)
  matrix[P, P] S;               // sample covariance matrix
  real<lower=0> lambda_scale;   // lasso scale (smaller -> stronger shrinkage)
}

parameters{
  vector<lower=0>[P] theta;     // unique variances (diagonal of Theta)
  vector[P] lambdaMain;         // primary loadings
  vector[P] lambdaCross;        // cross-loadings (lasso prior)
  real<lower=-1,upper=1> factCor;  // factor correlation
}

transformed parameters{
  matrix[P, Q] LambdaUnc;
  matrix[P, P] Theta;
  corr_matrix[Q] Psi;
  matrix[P, P] Sigma;

  Theta = diag_matrix(theta);

  // Loading structure (manual; matches your original)
  LambdaUnc[1:3, 1] = lambdaMain[1:3];
  LambdaUnc[4:6, 2] = lambdaMain[4:6];
  LambdaUnc[4:6, 1] = lambdaCross[1:3];
  LambdaUnc[1:3, 2] = lambdaCross[4:6];

  // Factor correlation matrix
  Psi[1,1] = 1;
  Psi[2,2] = 1;
  Psi[1,2] = factCor;
  Psi[2,1] = factCor;

  // Model-implied covariance
  Sigma = LambdaUnc * Psi * LambdaUnc' + Theta; 
}

model{
  // Priors
  lambdaMain ~ normal(0, 5);

  // LASSO prior (Laplace) for cross-loadings:
  // log p(lambdaCross | lambda_scale) = -|lambda|/lambda_scale + const
  // (normalizing constant omitted since lambda_scale is fixed data)
  target += -sum(fabs(lambdaCross)) / lambda_scale;

  theta ~ cauchy(0, 5);
  // factCor: implicit uniform(-1,1)

  // Wishart likelihood for (N-1)S ~ Wishart(N-1, Sigma)
  target += wishart_lpdf( (N - 1) * S | (N - 1), Sigma );
}

generated quantities{
  // Sign-switching correction
  vector[P] lambdaMainC = lambdaMain;
  vector[P] lambdaCrossC = lambdaCross;
  corr_matrix[Q] PsiC = Psi;

  // Factor 1 (marker: item 1)
  if (lambdaMain[1] < 0){
    lambdaMainC[1:3] = -1 * lambdaMain[1:3];
    lambdaCrossC[1:3] = -1 * lambdaCross[1:3];

    if (lambdaMainC[4] > 0){
      PsiC[1,2] = -1 * Psi[1,2];
      PsiC[2,1] = -1 * Psi[1,2];
    }
  }

  // Factor 2 (marker: item 4)
  if (lambdaMain[4] < 0){
    lambdaMainC[4:6] = -1 * lambdaMain[4:6];
    lambdaCrossC[4:6] = -1 * lambdaCross[4:6];

    if (lambdaMain[1] > 0){
      PsiC[1,2] = -1 * Psi[1,2];
      PsiC[2,1] = -1 * Psi[1,2];
    }
  }
}
