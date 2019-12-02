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

  /* compute monotonic effects
   * Args:
   *   scale: a simplex parameter
   *   i: index to sum over the simplex
   * Returns:
   *   a scalar between 0 and 1
   */
  real mo(vector scale, int i) {
    if (i == 0) {
      return 0;
    } else {
      return rows(scale) * sum(scale[1:i]);
    }
  }
}
data {
  int<lower=1> N;  // number of observations
  int<lower=2> ncat;  // number of categories
  int Y[N];  // response variable
  int<lower=1> K;  // number of population-level effects
  matrix[N, K] X;  // population-level design matrix
  int<lower=1> Ksp;  // number of special effects terms
  int<lower=1> Imo;  // number of monotonic variables
  int<lower=2> Jmo[Imo];  // length of simplexes
  // monotonic variables
  int Xmo_1[N];
  int Xmo_2[N];
  // prior concentration of monotonic simplexes
  vector[Jmo[1]] con_simo_1;
  vector[Jmo[2]] con_simo_2;
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
  // special effects coefficients
  vector[Ksp] bsp;
  // simplexes of monotonic effects
  simplex[Jmo[1]] simo_1;
  simplex[Jmo[2]] simo_2;
}
transformed parameters {
}
model {
  // initialize linear predictor term
  vector[N] mu = Xc * b;
  for (n in 1:N) {
    // add more terms to the linear predictor
    mu[n] += (bsp[1]) * mo(simo_1, Xmo_1[n]) + (bsp[2]) * mo(simo_2, Xmo_2[n]);
  }
  // priors including all constants
  target += normal_lpdf(b | 0, 0.5);
  target += normal_lpdf(Intercept[1] | -2, 0.5);
  target += normal_lpdf(Intercept[2] | -1, 0.5);
  target += normal_lpdf(Intercept[3] | -0.5, 0.5);
  target += normal_lpdf(Intercept[4] | 0, 0.5);
  target += normal_lpdf(Intercept[5] | 1, 0.5);
  target += normal_lpdf(Intercept[6] | 1.5, 0.5);
  target += normal_lpdf(Intercept[7] | 2, 0.5);
  target += normal_lpdf(bsp[1] | 0.4, 0.5);
  target += normal_lpdf(bsp[2] | 0.4, 0.5);
  target += dirichlet_lpdf(simo_1 | con_simo_1);
  target += dirichlet_lpdf(simo_2 | con_simo_2);
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
