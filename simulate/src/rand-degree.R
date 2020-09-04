# vim: set ts=4 softtabstop=0 sw=4 si fileencoding=utf-8:
#
# Authors:     TS
# Maintainers: TS
# Copyright:   2020, HRDAG, GPL v2 or later
# =========================================
# simulate/src/sim.R

library(pacman)
pacman::p_load(argparse, purrr, yaml)

parser <- ArgumentParser()
parser$add_argument("--population_size", default = "1000000", type = "integer")
parser$add_argument("--n_respondents", default = "100", type = "integer")
parser$add_argument("--n_known", default = "10", type = "integer")
parser$add_argument("--n_unknown", default = "3", type = "integer")
parser$add_argument("--mu", type = "double")
parser$add_argument("--sigma", type = "double")
parser$add_argument("--output")
args <- parser$parse_args()

###

population <- args$population_size
sim_n <- args$n_respondents
n_known_pops <- args$n_known
n_unknown_pops <- args$n_unknown

# need randomness here b/c i'm running the script multiple times,
# but want to be able to reproduce if necessary
seed <- sample(.Machine$integer.max, size = 1)
set.seed(seed)


# distribution of degree (num of connections) in the population
# on the log scale
mu <- args$mu

# 70% of individual degrees are within
# sigma=.25 => +/- 1.2 times the pop mean
# sigma=2   => +/- 7.4 times the pop mean
sigma <- args$sigma
###


log_d <- rnorm(sim_n, mu, sigma)
degree <- round(exp(log_d))

known_pct <- runif(n_known_pops, min = .04, max = .2)
unk_pops <- round(population * runif(n_unknown_pops, min = .04, max = .2))
known_resp <- map(known_pct,
                  ~rbinom(sim_n, size = degree, prob = .)) %>%
    unlist %>% matrix(nrow = sim_n, ncol = n_known_pops,
                      byrow = FALSE)

unk_resp <- map(unk_pops / population,
                ~rbinom(sim_n, size = degree, prob = .)) %>%
    unlist %>% matrix(nrow = sim_n, ncol = n_unknown_pops,
                      byrow = FALSE)

output <- list(population    = population,
               n_respondents = sim_n,
               n_known       = n_known_pops,
               n_unk         = n_unknown_pops,
               known_resp    = known_resp,
               unk_resp      = unk_resp,
               known_pct     = known_pct)

saveRDS(output, args$output)

smry <- output[c("population", "n_respondents", "n_known", "n_unk", "known_pct")]
smry$unknown_populations <- unk_pops
smry$mu <- mu
smry$sigma <- sigma
smry$degrees <- degree
smry$seed <- seed

write_yaml(smry, paste0(args$output, "-log.yaml"))

# done.
