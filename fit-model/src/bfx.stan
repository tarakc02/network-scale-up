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
    vector<lower=0,upper=1>[n_unk] m;
    vector<lower=0>[n_unk] rho;
}

transformed parameters {
    vector[n_respondents] degree;
    real mu;
    mu = 5.5 + (4 * mu_raw);
    degree = exp(mu + (sigma * log_degree_raw));
}

model {
    mu_raw ~ std_normal();
    sigma ~ normal(0, 2);
    log_degree_raw ~ std_normal();
    m ~ uniform(0, 1);
    rho ~ normal(0, 2);
    for (i in 1:n_respondents) {
        q[i] ~ beta_proportion(m, rho);
        known_resp[i] ~ poisson(degree[i] * known_pct);
        unk_resp[i] ~ poisson(degree[i] * q[i]);
    }
}

generated quantities {
    vector[n_unk] subpop_size;
    int expected_responses[n_respondents, n_unk];
    subpop_size = m * population;
    for (i in 1:n_respondents) {
        expected_responses[i] = poisson_rng(degree[i] * q[i]);
    }
}

