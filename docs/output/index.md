Network Scale Up for estimating the size of hard-to-reach subpopulations
================
[Tarak Shah](https://hrdag.org/people/tarak-shah/)

-   <a href="#background" id="toc-background">Background</a>
-   <a href="#simulation" id="toc-simulation">Simulation</a>
-   <a href="#models" id="toc-models">Models</a>
-   <a href="#assessing-fit-without-access-to-ground-truth"
    id="toc-assessing-fit-without-access-to-ground-truth">Assessing fit
    without access to ground truth</a>
-   <a href="#comparing-to-ground-truth"
    id="toc-comparing-to-ground-truth">Comparing to ground truth</a>

## Background

I learned about [the network scale up
method](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4777323/) at the
2020 KDD humanitarian mapping workshop, in a presentation on the paper
[CoronaSurveys: Using Surveys with Indirect Reporting to Estimate the
Incidence and Evolution of Epidemics](https://arxiv.org/abs/2005.12783).

The idea is that to estimate the size of a hard-to-count population, you
randomly survey a handful of people and ask them:

1)  how many people do you know in all (the person’s *degree*), and

2)  how many people do you know in the subpopulation of interest? We use
    the results to estimate the proportion of the overall population who
    are in the subpopulation of interest. Unfortunately, it turns out
    most people can’t answer
    ![a](https://latex.codecogs.com/png.image?%5Cdpi%7B110%7D&space;%5Cbg_white&space;a "a")
    very well. But, we can estimate how many people someone knows by
    asking them a series of questions about members of subpopulations of
    known size (“how many people do you know named Michael?”, “how many
    people do you know with a graduate degree?”, etc.).

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
simulations](%60r%20here::here(%22simulate%22)%60). I simulated from two
different models, the [**random
degree**](/Users/tshah/git/network-scale-up/simulate/src/rand-degree.R)
model, which allows each respondent’s degree (the total number of people
they know) to vary, and the [**barrier
effects**](/Users/tshah/git/network-scale-up/simulate/src/barrier-fx.R)
model, which also allows the probability of knowing someone in the
subpopulations of interest to vary. From each model, I simulated a
survey of 25 people, and one of 100 people, so 4 simulated datasets in
all. Below is the distribution of degree for the simulated respondents
in each simulation:

    ## # A tibble: 4 × 8
    ##   model    `0%` `10%` `30%` `50%` `70%` `90%` `100%`
    ##   <chr>   <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>  <dbl>
    ## 1 bfx-100    14  49.9  168.  292   588  1147.   3402
    ## 2 bfx-25     28  58.4  119.  300   378.  821.   5067
    ## 3 rd-100     10  53.9  130.  246.  491. 1331.   6764
    ## 4 rd-25      18  83.4  200   260   554. 1828    3536

And summaries of the remaining

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
models in [`fit-models/src`](%60here::here(%22fit-models/src%22)%60).

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

See
[assess-fit/output](/Users/tshah/git/network-scale-up/assess-fit/output)
for all of the resulting comparisons. Below are a couple of
representative examples. First, we see how each model looked on the
random degree simulated data with 100 respondents:

| ![](/Users/tshah/git/network-scale-up/assess-fit/output/checkfit-rd-100-rd.png) | ![](/Users/tshah/git/network-scale-up/assess-fit/output/checkfit-rd-100-bfx.png) |
|---------------------------------------------------------------------------------|----------------------------------------------------------------------------------|

Now the two models on the barrier effects simulated data with 100
respondents:

| ![](/Users/tshah/git/network-scale-up/assess-fit/output/checkfit-bfx-100-rd.png) | ![](/Users/tshah/git/network-scale-up/assess-fit/output/checkfit-bfx-100-bfx.png) |
|----------------------------------------------------------------------------------|-----------------------------------------------------------------------------------|

Since the random degree model doesn’t account for variation in exposure
to the subpopulation, the fitted model cannot account for the amount of
variation, or the more extreme values that arise due to that variation.
In most situations, we’ll have a model that fits some aspects of the
data, and not others, and deciding whether a model is useful will depend
on whether the comparisons (between data and model posterior) that we
make are relevant to our ultimate questions of interest.

## Comparing to ground truth

Since in this example I am modeling simulated data, I can compare
inferred values from my model to the ground truth values. The following
table summarizes, for each subpopulation within each dataset and for
each model, the point estimate along with associated 95% credible
interval, alongside the ground truth:

| model | data    | subpop | truth   | estimate and 95% interval   | in_range | p-value (truth) |
|:------|:--------|-------:|:--------|:----------------------------|:---------|----------------:|
| rd    | rd-100  |      1 | 53,811  | 53,482 (51,477 - 55,603)    | TRUE     |           0.625 |
| rd    | rd-100  |      2 | 168,157 | 170,171 (166,262 - 173,872) | TRUE     |           0.145 |
| rd    | rd-100  |      3 | 43,734  | 43,347 (41,577 - 45,159)    | TRUE     |           0.663 |
| rd    | bfx-100 |      1 | 97,573  | 86,098 (83,521 - 88,714)    | FALSE    |           1.000 |
| rd    | bfx-100 |      2 | 95,487  | 92,338 (89,684 - 95,080)    | FALSE    |           0.987 |
| rd    | bfx-100 |      3 | 10,779  | 8,239 (7,466 - 9,040)       | FALSE    |           1.000 |
| bfx   | rd-100  |      1 | 53,811  | 53,615 (51,274 - 55,975)    | TRUE     |           0.565 |
| bfx   | rd-100  |      2 | 168,157 | 169,579 (165,234 - 173,764) | TRUE     |           0.268 |
| bfx   | rd-100  |      3 | 43,734  | 43,634 (41,664 - 45,918)    | TRUE     |           0.537 |
| bfx   | bfx-100 |      1 | 97,573  | 93,716 (76,167 - 116,045)   | TRUE     |           0.655 |
| bfx   | bfx-100 |      2 | 95,487  | 111,691 (88,859 - 141,126)  | TRUE     |           0.111 |
| bfx   | bfx-100 |      3 | 10,779  | 9,813 (7,982 - 12,470)      | TRUE     |           0.797 |

The `rd` model fails to recover the unknown population sizes when the
true data generating process allows for individual variation in
likelihood of knowing someone in the unknown subpopulation.