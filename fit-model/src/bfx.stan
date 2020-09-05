data {
    int population;
    int n_respondents;
    int n_known;
    int n_unk;
    int known_resp[n_respondents, n_known];
    int unk_resp[n_respondents, n_unk];
    vector[n_known] known_pct;
}

parameters {
    real mu_raw;
    real<lower=0> sigma;
    vector[n_respondents] log_degree_raw;
    vector<lower=0,upper=1>[n_unk] q[n_respondents];
    vector<lower=0,upper=1>[n_unk] phi;
    vector<lower=0.1>[n_unk] lambda;
}

transformed parameters {
    vector[n_respondents] degree;
    real mu;
    vector<lower=0>[n_unk] alpha;
    vector<lower=0>[n_unk] beta;
    mu = 5.5 + (4 * mu_raw);
    degree = exp(mu + (sigma * log_degree_raw));
    for (k in 1:n_unk) {
        alpha[k] = lambda[k] * phi[k];
        beta[k] = lambda[k] * (1 - phi[k]);
    }
}

model {
    mu_raw ~ std_normal();
    sigma ~ normal(0, 2);
    log_degree_raw ~ std_normal();
    phi ~ beta(1, 1);
    lambda ~ pareto(.1, 1.5);
    for (i in 1:n_respondents) {
        q[i] ~ beta(alpha, beta);
        known_resp[i] ~ poisson(degree[i] * known_pct);
        unk_resp[i] ~ poisson(degree[i] * q[i]);
    }
}

generated quantities {
    vector[n_unk] subpop_size;
    int expected_responses[n_respondents, n_unk];
    int rep_data[n_respondents, n_unk];
    real dl[n_respondents] = normal_rng(rep_vector(mu, n_respondents), sigma);
    real rep_degree[n_respondents] = exp(dl);
    real rep_q[n_respondents, n_unk];

    for (k in 1:n_unk) {
        subpop_size[k] = (alpha[k] / (alpha[k] + beta[k])) * population;
    }
    for (i in 1:n_respondents) {
        rep_q[i] = beta_rng(alpha, beta);
        expected_responses[i] = poisson_rng(degree[i] * q[i]);
        for (k in 1:n_unk) {
            rep_data[i,k] = poisson_rng(rep_degree[i] * rep_q[i,k]);
        }
    }
}

