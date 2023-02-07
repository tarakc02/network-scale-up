Network Scale Up for estimating the size of hard-to-reach subpopulations
================
[Tarak Shah](https://tarakc02.github.io/)

- [Background](#background)
- [Simulation](#simulation)
- [Models](#models)
- [Assessing fit without access to ground
  truth](#assessing-fit-without-access-to-ground-truth)
- [Comparing to ground truth](#comparing-to-ground-truth)

## Background

I learned about [the network scale up
method](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4777323/) at the
2020 KDD humanitarian mapping workshop, in a presentation on the paper
[CoronaSurveys: Using Surveys with Indirect Reporting to Estimate the
Incidence and Evolution of Epidemics](https://arxiv.org/abs/2005.12783).

The idea is that to estimate the size of a hard-to-count population, you
randomly survey a handful of people and ask them:

1.  how many people do you know in all (the person’s *degree*), and

2.  how many people do you know in the subpopulation of interest? We use
    the results to estimate the proportion of the overall population who
    are in the subpopulation of interest.

Unfortunately, it turns out most people can’t answer question 1 very
well. But, we can estimate how many people someone knows by asking them
a series of questions about members of subpopulations of known size
(“how many people do you know named Michael?”, “how many people do you
know with a graduate degree?”, etc.).

So putting things together, our method is to ask randomly selected
people a battery of questions, some of them about known-size
subpopulations, and some about subpopulations whose size we want to
estimate. Then we jointly estimate each respondent’s degree (the number
of people they know) as well as the sizes of the unknown subpopulations.
The linked paper starts with a simple model and builds it up by first
allowing partial pooling of degree estimates, then allowing the
likelihood of knowing someone in a given subpopulation to vary by
individual and subpopulation, then adding further parameters for various
types of reporting bias (e.g. transmission error, where someone doesn’t
know that an acquaintance belongs to a given group, or recall bias,
where someone forgets to count people when asked to quickly report on
their contacts).

## Simulation

To get a better understanding of the method, I coded up [some
simulations](https://github.com/tarakc02/network-scale-up). I simulated
from two different models, the **random degree** model, which allows
each respondent’s degree (the total number of people they know) to vary,
and the **barrier effects** model, which also allows the probability of
knowing someone in the subpopulations of interest to vary. From each
model, I simulated a survey of 25 people, and one of 100 people, so 4
simulated datasets in all. Below is the distribution of degree for the
simulated respondents in each simulation:

    ## # A tibble: 4 × 8
    ##   model    `0%` `10%` `30%` `50%` `70%` `90%` `100%`
    ##   <chr>   <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>  <dbl>
    ## 1 bfx-100    14  49.9  168.  292   588  1147.   3402
    ## 2 bfx-25     28  58.4  119.  300   378.  821.   5067
    ## 3 rd-100     10  53.9  130.  246.  491. 1331.   6764
    ## 4 rd-25      18  83.4  200   260   554. 1828    3536

And summaries of other aspects of the simulations, including the
(unobserved) subpopulation sizes, which will be our main target for
inference:

    ## 
    ## ########
    ## sim_name                      :  bfx-100 
    ## population                    : 1000000
    ## respondents                   : 100
    ## size of unknown subpopulations: 97573  95487  10779
    ## 
    ## ########
    ## sim_name                      :  bfx-25 
    ## population                    : 1000000
    ## respondents                   : 25
    ## size of unknown subpopulations: 142918  18991  31736
    ## 
    ## ########
    ## sim_name                      :  rd-100 
    ## population                    : 1000000
    ## respondents                   : 100
    ## size of unknown subpopulations: 53811  168157  43734
    ## 
    ## ########
    ## sim_name                      :  rd-25 
    ## population                    : 1000000
    ## respondents                   : 25
    ## size of unknown subpopulations: 167918  184601  100708

## Models

Find the stan models used to fit the random degree and barrier effects
models in the [`fit-model`](../fit-model) directory.

## Assessing fit without access to ground truth

The data, in these examples, looks like a vector of integers, responses
to the question “how many people do you know in group X?” The main goal
for doing inference is estimating the size of the subpopulation of
interest. The probability model connects that value to the observed data
(the vector of responses). In real life, I wouldn’t have access to the
true size of the subpopulation to compare model predictions to (if I
did, I wouldn’t have to make a model or collect data in the first
place), but I can use the fitted model to simulate new data sets. If
things have fit well, then the actual data set should look like the
simulated data sets. So, for instance, the mean in the actual data
should fall within the range of means seen in the simulated datasets.

In most situations, we’ll have a model that fits some aspects of the
data, and not others, and deciding whether a model is useful will depend
on whether the comparisons (between data and model posterior) that we
make are relevant to our ultimate questions of interest. Since I’m
ultimately interested in estimating the sizes of the unknown
subpopulations, I decided to focus on the vectors of responses to the
three questions about the unknown subpopulations. For specific
statistical tests, I chose three summary statistics: the mean, the
standard deviation, and the 95th percentile. I calculate all three
summary statistics on the observed data, and on simulated replicates of
the data, and then I see where the summary of the observed data fits in
the distribution of summaries over the replicate datasets.

See the [`assess-fit/output`](../assess-fit/output) directory for all of
the resulting comparisons. Below are a couple of representative
examples. First, we see how each model looked on the random degree
simulated data with 100 respondents:

| ![](../assess-fit/output/checkfit-rd-100-rd.png?raw=true) | ![](../assess-fit/output/checkfit-rd-100-bfx.png?raw=true) |
|-----------------------------------------------------------|------------------------------------------------------------|

Both models fit the model well, at least according to this test.

Now the two models on the barrier effects simulated data with 100
respondents:

| ![](../assess-fit/output/checkfit-bfx-100-rd.png?raw=true) | ![](../assess-fit/output/checkfit-bfx-100-bfx.png?raw=true) |
|------------------------------------------------------------|-------------------------------------------------------------|

Since the random degree model doesn’t account for variation in exposure
to the subpopulation, the fitted model cannot account for the amount of
variation, or the more extreme values that arise due to that variation.

## Comparing to ground truth

Since in this example I am modeling simulated data, I can compare
inferred values from my model to the ground truth values. The following
table summarizes, for each subpopulation within each dataset and for
each model, the point estimate along with associated 95% credible
interval, alongside the ground truth:

| model | data    | subpop | truth   | estimate and 95% interval   | in_interval | p-value (truth) |
|:------|:--------|-------:|:--------|:----------------------------|:------------|----------------:|
| rd    | rd-100  |      1 | 53,811  | 53,390 (51,412 - 55,469)    | TRUE        |           0.635 |
| rd    | rd-100  |      2 | 168,157 | 170,145 (166,284 - 173,732) | TRUE        |           0.165 |
| rd    | rd-100  |      3 | 43,734  | 43,353 (41,581 - 45,183)    | TRUE        |           0.635 |
| rd    | bfx-100 |      1 | 97,573  | 86,173 (83,541 - 88,481)    | FALSE       |           1.000 |
| rd    | bfx-100 |      2 | 95,487  | 92,469 (89,733 - 95,095)    | FALSE       |           0.987 |
| rd    | bfx-100 |      3 | 10,779  | 8,231 (7,470 - 9,095)       | FALSE       |           1.000 |
| bfx   | rd-100  |      1 | 53,811  | 53,626 (51,305 - 56,036)    | TRUE        |           0.563 |
| bfx   | rd-100  |      2 | 168,157 | 169,703 (165,413 - 173,862) | TRUE        |           0.252 |
| bfx   | rd-100  |      3 | 43,734  | 43,691 (41,644 - 45,845)    | TRUE        |           0.516 |
| bfx   | bfx-100 |      1 | 97,573  | 93,877 (76,596 - 118,349)   | TRUE        |           0.636 |
| bfx   | bfx-100 |      2 | 95,487  | 111,192 (88,543 - 138,015)  | TRUE        |           0.113 |
| bfx   | bfx-100 |      3 | 10,779  | 9,919 (7,825 - 12,561)      | TRUE        |           0.781 |

The `rd` model fails to recover the unknown population sizes when the
true data generating process allows for individual variation in
likelihood of knowing someone in the unknown subpopulation.

To get a sense of how the number of respondents affects the uncertainty
in our estimates, here’s the same summary on the datasets with 25,
instead of 100, respondents:

``` r
posteriors %>%
    filter(data %in% c("bfx-25", "rd-25")) %>%
    group_by(model, data, subpop) %>%
    summarise(lo = quantile(.value, .025),
              mid = median(.value),
              hi = quantile(.value, .975),
              ecdf = list(ecdf(.value)),
              .groups = "drop") %>%
    inner_join(true_subpop_sizes, by = c("data", "subpop")) %>%
    mutate(in_interval = truth >= lo & truth <= hi) %>%
    mutate(across(c(lo, mid, hi),
                  ~str_trim(format(round(.),
                                   big.mark = ","))),
           truth_pvalue = map2_dbl(ecdf, truth, ~.x(.y))) %>%
    transmute(model, data, subpop,
              truth = format(round(truth), big.mark = ","),
              "estimate and 95% interval" = str_glue("{mid} ({lo} - {hi})"),
              in_interval, "p-value (truth)" = truth_pvalue) %>%
    arrange(desc(model), desc(data)) %>%
    knitr::kable()
```

| model | data   | subpop | truth   | estimate and 95% interval   | in_interval | p-value (truth) |
|:------|:-------|-------:|:--------|:----------------------------|:------------|----------------:|
| rd    | rd-25  |      1 | 167,918 | 171,904 (165,228 - 178,822) | TRUE        |           0.124 |
| rd    | rd-25  |      2 | 184,601 | 181,518 (174,880 - 188,726) | TRUE        |           0.792 |
| rd    | rd-25  |      3 | 100,708 | 105,834 (101,340 - 110,962) | FALSE       |           0.016 |
| rd    | bfx-25 |      1 | 142,918 | 116,365 (110,430 - 122,006) | FALSE       |           1.000 |
| rd    | bfx-25 |      2 | 18,991  | 16,990 (14,894 - 18,996)    | TRUE        |           0.974 |
| rd    | bfx-25 |      3 | 31,736  | 20,220 (18,103 - 22,390)    | FALSE       |           1.000 |
| bfx   | rd-25  |      1 | 167,918 | 172,383 (163,692 - 182,500) | TRUE        |           0.159 |
| bfx   | rd-25  |      2 | 184,601 | 183,472 (173,605 - 194,337) | TRUE        |           0.598 |
| bfx   | rd-25  |      3 | 100,708 | 106,062 (99,257 - 113,708)  | TRUE        |           0.068 |
| bfx   | bfx-25 |      1 | 142,918 | 164,101 (117,252 - 242,677) | TRUE        |           0.208 |
| bfx   | bfx-25 |      2 | 18,991  | 16,218 (11,719 - 24,468)    | TRUE        |           0.784 |
| bfx   | bfx-25 |      3 | 31,736  | 32,246 (22,871 - 49,300)    | TRUE        |           0.477 |
