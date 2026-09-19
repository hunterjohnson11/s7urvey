# s7urvey

<!-- badges: start -->

[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)

<!-- badges: end -->

> **Work in progress — not ready for use.** This package is an early sketch. The API will change without notice, there is no way yet to get from a question object to the answers behind it, and nothing here should be relied on. It is public so the design can be discussed, not because it is usable.

s7urvey gives public opinion polling survey data a home in R, using [S7](https://rconsortium.github.io/S7/).

## The problem

R has no good way to carry the information a survey question needs. Value labels are awkward to work with, and every source encodes them differently, so there is always a workaround. The question text usually is not in the data at all, or it is glued to the variable name and the option text inside one label string that you have to pull apart by hand.

Underneath that is a mismatch that's structural. **A survey's unit of meaning is the question. A data frame's unit is the column.**

- A multi-select is *one* question spread across many columns, dummy-coded one per option.
- A matrix is *many* questions sharing one stem and one response scale.

The goal is a package that allows users to view survey data in R the way they would in any other context.

## The model

Two classes, split on how many answers the respondent gave.

`survey_var` is one question the respondent answered once, however many columns it occupies:

``` r
survey_var(
  stem = "M_SPORTS",
  cols = c("M_SPORTS_1", "M_SPORTS_2", "M_SPORTS_3", "M_SPORTS_4"),
  type = "multi",
  question_text = "Which of the following sports do you play?",
  response_options = list(
    M_SPORTS_1 = "Basketball",
    M_SPORTS_2 = "Soccer",
    M_SPORTS_3 = "Tennis",
    M_SPORTS_4 = "Swimming"
  )
)
#> <survey_var> M_SPORTS
#>   Type:     Multi-Select
#>   Columns:  4
#>   Question: Which of the following sports do you play?
#>   Response Options:
#>   M_SPORTS_1: Basketball
#>   M_SPORTS_2: Soccer
#>   M_SPORTS_3: Tennis
#>   M_SPORTS_4: Swimming
```

`survey_var_group` is one question answered *separately*, once per level of some dimension. A matrix and a looped question are the same shape, so both are groups:

``` r
#> <survey_var_group> S_SPORTS_FREQ
#>   Question:  How often do you play each of the following sports?
#>   Group Var: sport
#>   Type:      Single-Select
#>   Members:   2
#>   Group Options:
#>   1: Basketball
#>   2: Soccer
```

The overarching question lives on the group; each row item is its own `survey_var` with the shared response scale.

## Labels are optional

Not every file has usable question text, so classification never depends on it. A question is classified from its structure alone — `stem`, `cols`, and `type`:

``` r
survey_var(stem = "M_SPORTS", cols = paste0("M_SPORTS_", 1:4), type = "multi")
#> <survey_var> M_SPORTS
#>   Type:     Multi-Select
#>   Columns:  4
#>   Question: (none)
```

Metadata enriches a question. It is never a prerequisite for having one.

## Why

Once a viable framework for survey data in R exists, functions for evaluating survey data can be built on top of it. I also see this as important in the age of AI as this will allow AI agents to easily access necessary context.

Down the road, I'm also very interested in building functionality for toplines and crosstabs, which would be easy to build when s7urvey's object fields are filled. +

## Installation

``` r
# install.packages("pak")
pak::pak("hunterjohnson11/s7urvey")
```

## Status

Working: the two classes, structural validation, and printing.

Not built yet: any way to get from a question to the values behind it, a base or eligibility field, and anything that reads a survey file automatically.