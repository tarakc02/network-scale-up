# vim: set ts=4 softtabstop=0 sw=4 si fileencoding=utf-8:
#
# Authors:     TS
# Maintainers: TS
# Copyright:   2020, HRDAG, GPL v2 or later
# =========================================
# /Users/tshah/git/network-scale-up/fit-model/src/fit.R

library(pacman)
pacman::p_load(argparse, rstan, tidybayes, dplyr)


parser <- ArgumentParser()
parser$add_argument("--data", default = "input/random-degree-25-resp.rds")
parser$add_argument("--model", default = "src/random-degree.stan")
args <- parser$parse_args()

model <- stan_model(args$model)
input <- readRDS(args$data)

fit <- sampling(model, data = input,
                chains = 4, iter = 5000, cores = 4)

gather_draws(fit, subpop_size[k]) %>%
    summarise(med = median(.value),
              lo = quantile(.value, .05),
              hi = quantile(.value, .95),
              .groups = "drop")

gather_draws(fit, mu, sigma) %>% median_hdi
