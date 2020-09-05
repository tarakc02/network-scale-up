# vim: set ts=4 softtabstop=0 sw=4 si fileencoding=utf-8:
#
# Authors:     TS
# Maintainers: TS
# Copyright:   2020, HRDAG, GPL v2 or later
# =========================================
# /Users/tshah/git/network-scale-up/fit-model/src/fit.R

library(pacman)
pacman::p_load(argparse, rstan)


parser <- ArgumentParser()
parser$add_argument("--data", default = "input/bfx-25.rds")
parser$add_argument("--model", default = "src/bfx.stan")
parser$add_argument("--output")
args <- parser$parse_args()

model <- stan_model(args$model, save_dso = FALSE)
input <- readRDS(args$data)

fit <- sampling(model, data = input,
                chains = 4, iter = 5000, cores = 4,
                pars = c("degree", "mu", "sigma", "subpop_size",
                         "expected_responses", "rep_data"))


saveRDS(fit, args$output)

# done.
