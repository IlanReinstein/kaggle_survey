// generated with brms 2.10.0
functions {
  /* cumulative-logit log-PDF for a single response
   * Args:
   *   y: response category
   *   mu: linear predictor
   *   thres: ordinal thresholds
   *   disc: discrimination parameter
   * Returns:
   *   a scalar to be added to the log posterior
   */
   real cumulative_logit_lpmf(int y, real mu, vector thres, real disc) {
     int ncat = num_elements(thres) + 1;
     real p;
     if (y == 1) {
       p = inv_logit(disc * (thres[1] - mu));
     } else if (y == ncat) {
       p = 1 - inv_logit(disc * (thres[ncat - 1] - mu));
     } else {
       p = inv_logit(disc * (thres[y] - mu)) -
           inv_logit(disc * (thres[y - 1] - mu));
     }
     return log(p);
   }
}
data {
  int<lower=1> N;  // number of observations
  int<lower=2> ncat;  // number of categories
  int Y[N];  // response variable
  int<lower=1> K;  // number of population-level effects
  matrix[N, K] X;  // population-level design matrix
  real<lower=0> disc;  // discrimination parameters
  int prior_only;  // should the likelihood be ignored?
}
transformed data {
  int Kc = K;
  matrix[N, Kc] Xc;  // centered version of X
  vector[Kc] means_X;  // column means of X before centering
  for (i in 1:K) {
    means_X[i] = mean(X[, i]);
    Xc[, i] = X[, i] - means_X[i];
  }
}
parameters {
  vector[Kc] b;  // population-level effects
  // temporary thresholds for centered predictors
  ordered[ncat - 1] Intercept;
}
transformed parameters {
}
model {
  // initialize linear predictor term
  vector[N] mu = Xc * b;
  // priors including all constants
  target += normal_lpdf(b | 0, 0.5);
  target += normal_lpdf(Intercept[1] | -2, 0.5);
  target += normal_lpdf(Intercept[2] | -1, 0.5);
  target += normal_lpdf(Intercept[3] | -0.5, 0.5);
  target += normal_lpdf(Intercept[4] | 0, 0.5);
  target += normal_lpdf(Intercept[5] | 1, 0.5);
  target += normal_lpdf(Intercept[6] | 1.5, 0.5);
  target += normal_lpdf(Intercept[7] | 2, 0.5);
  // likelihood including all constants
  if (!prior_only) {
    for (n in 1:N) {
      target += ordered_logistic_lpmf(Y[n] | mu[n], Intercept);
    }
  }
}
generated quantities {
  // compute actual thresholds
  vector[ncat - 1] b_Intercept = Intercept + dot_product(means_X, b);
}
