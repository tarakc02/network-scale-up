# vim: set ts=4 softtabstop=0 sw=4 si fileencoding=utf-8:
#
# Authors:     TS
# Maintainers: TS
# Copyright:   2020, HRDAG, GPL v2 or later
# =========================================
# /Users/tshah/git/network-scale-up/fit-model/src/fit.R

library(pacman)
# pacman::p_load(argparse, rstan, tidybayes, dplyr, rlang, tidyr)
pacman::p_load(argparse, rstan)


parser <- ArgumentParser()
parser$add_argument("--data", default = "input/barrier-fx-100-resp.rds")
parser$add_argument("--model", default = "src/random-degree.stan")
parser$add_argument("--output")
args <- parser$parse_args()

model <- stan_model(args$model, save_dso = FALSE)
input <- readRDS(args$data)

fit <- sampling(model, data = input,
                chains = 4, iter = 5000, cores = 4,
                pars = c("degree", "mu", "sigma", "subpop_size"))


saveRDS(fit, args$output)

# gather_draws(fit, subpop_size[k]) %>% median_hdi
# gather_draws(mod2fit, subpop_size[k]) %>% median_hdi
# gather_draws(mod2fit, m[k], rho[k]) %>% median_hdi
# gather_draws(fit, degree[respondent]) %>% ungroup
# gather_draws(fit, mu, sigma) %>% median_hdi
# 
# observed <- input$unk_resp %>%
#     data.frame %>%
#     set_names(1:3) %>%
#     as_tibble %>%
#     mutate(respondent = seq_len(nrow(.))) %>%
#     pivot_longer(cols = -respondent,
#                  names_to = "question",
#                  values_to = "cnt") %>%
#     mutate(source = "truth", question = as.integer(question))
# 
# gather_draws(fit, expected_responses[respondent, question], n = 500) %>%
#     ungroup %>%
#     transmute(respondent, question, simulated = .value) %>%
#     inner_join(observed, by = c("respondent", "question")) %>%
#     rename(actual = cnt) %>%
#     mutate(bloop = actual - simulated) %>%
#     ggplot(aes(x = bloop)) + geom_histogram()
#     ggplot(aes(x = actual, y = simulated)) +
#     facet_wrap(~question) +
    #     geom_point(size = .6, alpha = .3) +
    #     coord_fixed() +
    #     geom_abline(intercept = 0, slope = 1)
    # 
    # observed_smry <- observed %>%
    #     group_by(question) %>%
    #     summarise(max = max(cnt),
    #               percentile20 = quantile(cnt, .2),
    #               percentile80 = quantile(cnt, .8),
    #               sd = sd(cnt), .groups = "drop") %>%
    #     pivot_longer(cols = -question,
    #                  names_to = "statistic", values_to = "truth")
    # 
    # sim_summary <- gather_draws(mod2fit,
    #                             expected_responses[respondent, question],
    #                             n = 1000) %>%
    #     group_by(.draw, question) %>%
    #     summarise(max = max(.value),
    #               percentile20 = quantile(.value, .2),
    #               percentile80 = quantile(.value, .8),
    #               sd = sd(.value),
    #               .groups = "drop") %>%
    #     pivot_longer(cols = c(-.draw, -question),
    #                  names_to = "statistic", values_to = "value")
    # 
    # sim_p_vals <- sim_summary %>%
    #     inner_join(observed_smry, by = c("question", "statistic")) %>%
    #     group_by(question, statistic) %>%
    #     summarise(pval = sum(value <= truth) / n(),
    #               truth = unique(truth),
    #               .groups = "drop")
    # 
    # ggplot(sim_summary, aes(x = value)) + geom_histogram(bins = 25) +
    #     facet_grid(question ~ statistic, scales = "free",
    #                labeller = labeller(question = function(x) paste0("Question #", x))) +
    #     geom_vline(data = observed_smry, aes(xintercept = truth), colour = "red") +
    #     geom_label(data = sim_p_vals, colour = "red", size = 2.5,
    #                label.size = 0,
    #                label.padding = unit(0.1, "lines"),
    #                aes(x = truth, y = Inf,
    #                    label = paste0("p = ", round(pval, 3))), 
    #                hjust = "inward",
    #                vjust = "inward") +
    #     ggtitle("Model fit by subpopulation",
    #             "comparing summaries of simulated and observed data")
    # 
    # 
    # gather_draws(mod2fit, degree[respondent], n = 500) %>%
    #     median_hdi %>%
    #     ungroup %>% print(n = Inf)
