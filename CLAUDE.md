# s7urvey

An R package that gives public opinion survey data a home in R using the new S7 object structure.

R has no good way to carry the information a survey question needs. Value labels are awkward to work with, and every source encodes them differently, so there is always a workaround. The goal is that a survey question is an object holding everything needed to use it: the variable name, the question text, the response options, and the columns it occupies. A person or an AI agent looking at a variable should be able to see what it is and how it fits in the survey.

The distinguishing problem: a survey's unit of meaning is the **question**, but a data frame's unit is the **column**, and the two do not line up. A multi-select is one question spread across many columns. A matrix is many questions sharing one stem. Resolving that mismatch is what this package is for.

The intended downstream consumer is a crosstab function, which should be able to ask a question object for everything it needs without looking elsewhere. Another future planned functionality is exporting to Posit's `data-dict.`

## The model

Each kind of question is its own class under the abstract parent `question`, and functions are S7 generics with one method per kind, never `if` checks on a kind word.

- `single_select`, `multi_select`, `open_end` — one question the respondent answered once.
- `battery` — one question answered separately, once per level of some dimension. Covers both matrix/grid questions and looped questions.

All descriptive metadata is optional. A question is classified from structure alone (its class, `stem`, `cols`), because not every source has usable labels.

`example_survey` is synthetic data shipped for examples and tests.

## Working in this repo

- Develop on R 4.6.1.
- `devtools::check()`, `devtools::test()`, `air format .`, and `jarl check .` must all pass.
- `source("dev/preview.R")` prints one of every object type, for checking console colors.

## Rules

**Section heading comments only.** Headings that divide a file into sections are wanted, in the `# Name ----` form that Positron folds and lists in the outline, as well as ## and ### for subheadings. Every other comment is not allowed: no explanatory comments, no inline notes, no commented-out code. Roxygen (`#'`) is documentation and stays. The author writes their own comments sometimes — leave those alone, do not add to them.

**Only write tests that are absolutely necessary.** A test earns its place by failing when real behavior breaks.