# Package Data -----------------------------------------------------------------

#' A synthetic survey dataset for examples and tests
#'
#' `example_survey` is an entirely fictional dataset with the same messy
#' shape as a real survey export: single-select demographics, a multi-select
#' question spread across one dummy column per option, a matrix question
#' spread across one column per row, and an open-end. See
#' `data-raw/example_survey.R` for how it's generated.
#'
#' Each column carries the same `"label"` (variable label) and `"labels"`
#' (named value -> code vector) attributes a real haven-imported `.sav` file
#' would have, without requiring the \pkg{haven} package.
#'
#' @format A data frame with 40 rows and 10 columns:
#' \describe{
#'   \item{resp_id}{Respondent ID.}
#'   \item{S_GENDER}{Single-select: gender.}
#'   \item{S_AGE}{Single-select: age group.}
#'   \item{M_SPORTS_1, M_SPORTS_2, M_SPORTS_3, M_SPORTS_4}{Multi-select dummy
#'     columns (0/1) for whether the respondent plays Basketball, Soccer,
#'     Tennis, and Swimming, respectively.}
#'   \item{S_SPORTS_FREQ_1, S_SPORTS_FREQ_2, S_SPORTS_FREQ_3}{Matrix columns:
#'     how often the respondent plays Basketball, Soccer, and Tennis, on a
#'     shared Never/Rarely/Sometimes/Often scale.}
#'   \item{comments_oe}{Open-end: free-text comments (may be `NA`).}
#' }
#' @examples
#' example_survey
"example_survey"
