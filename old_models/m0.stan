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
  real<lower=0> disc;  // discrimination parameters
  int prior_only;  // should the likelihood be ignored?
}
transformed data {
}
parameters {
  // temporary thresholds for centered predictors
  ordered[ncat - 1] Intercept;
}
transformed parameters {
}
model {
  // initialize linear predictor term
  vector[N] mu = rep_vector(0, N);
  // priors including all constants
  target += normal_lpdf(Intercept[1] | -2, 0.5);
  target += normal_lpdf(Intercept[2] | -1, 0.5);
  target += normal_lpdf(Intercept[3] | -0.5, 0.5);
  target += normal_lpdf(Intercept[4] | 0, 0.5);
  target += normal_lpdf(Intercept[5] | 1, 0.5);
  target += normal_lpdf(Intercept[6] | 1.8, 0.5);
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
  vector[ncat - 1] b_Intercept = Intercept;
}
