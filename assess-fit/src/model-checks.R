# vim: set ts=4 softtabstop=0 sw=4 si fileencoding=utf-8:
#
# Authors:     TS
# Maintainers: TS
# Copyright:   2020, HRDAG, GPL v2 or later
# =========================================
# network-scale-up/assess-fit/src/model-checks.R

library(pacman)
pacman::p_load(argparse, rstan, tidybayes, yaml,
               dplyr, ggplot2, rlang, tidyr, tools)

parser <- ArgumentParser()
parser$add_argument("--data")
parser$add_argument("--fit")
parser$add_argument("--outdir", default = "output")
args <- parser$parse_args()

fit <- readRDS(args$fit)
input <- readRDS(args$data)

model_name <- fit@model_name
data_name <- tools::file_path_sans_ext(basename(args$data))

stub <- paste0(data_name, "-", model_name)
correct_modelfile <- paste0("input/fit-", stub, ".rds")
stopifnot(args$fit == correct_modelfile)

observed <- input$unk_resp %>%
    data.frame %>%
    set_names(1:3) %>%
    as_tibble %>%
    mutate(respondent = seq_len(nrow(.))) %>%
    pivot_longer(cols = -respondent,
                 names_to = "question",
                 values_to = "observed") %>%
    mutate(question = as.integer(question))

observed_smry <- observed %>%
    group_by(question) %>%
    summarise(mean = mean(observed),
              percentile95 = quantile(observed, .95),
              sd = sd(observed), .groups = "drop") %>%
    pivot_longer(cols = -question,
                 names_to = "statistic", values_to = "truth")

sim_summary <- gather_draws(fit,
                            expected_responses[respondent, question],
                            ndraws = 1000) %>%
    group_by(.draw, question) %>%
    summarise(mean = mean(.value),
              percentile95 = quantile(.value, .95),
              sd = sd(.value),
              .groups = "drop") %>%
    pivot_longer(cols = c(-.draw, -question),
                 names_to = "statistic", values_to = "value")

sim_p_vals <- sim_summary %>%
    inner_join(observed_smry, by = c("question", "statistic")) %>%
    group_by(question, statistic) %>%
    summarise(pval = sum(value <= truth) / n(),
              truth = unique(truth),
              .groups = "drop")

out <- ggplot(sim_summary, aes(x = value)) +
    geom_histogram(bins = 25) +
    scale_y_continuous(name = NULL) +
    facet_grid(statistic ~ question, scales = "free",
               labeller = labeller(question = function(x) paste0("Question #", x))) +
    geom_vline(data = observed_smry, aes(xintercept = truth), colour = "red") +
    geom_label(data = sim_p_vals, colour = "red", size = 1,
               label.size = 0,
               label.padding = unit(0.1, "lines"),
               aes(x = truth, y = Inf,
                   label = paste0("p = ", round(pval, 3))), 
               hjust = "inward",
               vjust = "inward") +
    ggtitle("Summaries of observed and model-simulated data",
            paste0("model: ", model_name, "; data: ", data_name)) +
    theme_minimal(base_size = 4)


ggsave(out, height = 450, width = 500, units = "px", bg = "white",
       filename = paste0(args$outdir, "/checkfit-", stub, ".png"))

# done.
