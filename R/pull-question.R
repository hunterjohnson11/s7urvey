# Question Values --------------------------------------------------------------

## Helpers ---------------------------------------------------------------------

answer_frame <- function(row, group, item, value) {
  data.frame(
    .row = row,
    group = group,
    item = item,
    value = value,
    stringsAsFactors = FALSE
  )
}

apply_response_labels <- function(values, response_options) {
  if (length(response_options) == 0) {
    return(values)
  }
  factor(
    as.character(values),
    levels = names(response_options),
    labels = unlist(response_options, use.names = FALSE)
  )
}

option_label <- function(response_options, col) {
  label <- response_options[[col]]
  if (is.null(label)) col else as.character(label)
}

check_question_cols <- function(data, cols, call = parent.frame()) {
  absent <- setdiff(cols, names(data))
  if (length(absent) > 0) {
    cli::cli_abort(
      c(
        "{.arg data} does not have every column this question needs.",
        x = "Not found: {.val {absent}}.",
        i = "The question names {length(cols)} column{?s} in {.code @cols}."
      ),
      call = call
    )
  }
}

check_dummy_cols <- function(data, cols, call = parent.frame()) {
  usable <- vapply(
    cols,
    function(col) is.numeric(data[[col]]) || is.logical(data[[col]]),
    logical(1)
  )
  if (!all(usable)) {
    cli::cli_abort(
      c(
        "A multi-select needs dummy-coded columns.",
        x = "{.val {cols[!usable]}} {?is/are} neither numeric nor logical.",
        i = "Each column should hold 0 or 1 for whether that option was selected."
      ),
      call = call
    )
  }
}

stack_answers <- function(parts, groups) {
  first <- parts[[1]]$value
  flat <- unlist(
    lapply(parts, function(p) as.character(p$value)),
    use.names = FALSE
  )
  if (is.factor(first)) {
    flat <- factor(flat, levels = levels(first))
  } else if (is.logical(first)) {
    flat <- as.logical(flat)
  } else if (is.numeric(first)) {
    flat <- as.numeric(flat)
  }
  answer_frame(
    row = unlist(lapply(parts, function(p) p$.row), use.names = FALSE),
    group = rep(groups, times = vapply(parts, nrow, integer(1))),
    item = unlist(lapply(parts, function(p) p$item), use.names = FALSE),
    value = flat
  )
}

pull_survey_var <- function(data, question) {
  check_question_cols(data, question@cols)
  rows <- seq_len(nrow(data))
  options <- question@response_options

  if (question@type %in% c("single", "open_end")) {
    values <- data[[question@cols]]
    if (question@type == "single") {
      values <- apply_response_labels(values, options)
    }
    return(answer_frame(rows, NA_character_, NA_character_, values))
  }

  if (question@type == "multi") {
    check_dummy_cols(data, question@cols)
    return(answer_frame(
      row = rep(rows, times = length(question@cols)),
      group = NA_character_,
      item = rep(
        vapply(
          question@cols,
          function(col) option_label(options, col),
          character(1)
        ),
        each = length(rows)
      ),
      value = unlist(
        lapply(question@cols, function(col) as.logical(data[[col]])),
        use.names = FALSE
      )
    ))
  }

  answer_frame(
    row = rep(rows, times = length(question@cols)),
    group = NA_character_,
    item = rep(question@cols, each = length(rows)),
    value = unlist(
      lapply(question@cols, function(col) data[[col]]),
      use.names = FALSE
    )
  )
}

pull_survey_var_group <- function(data, question) {
  parts <- lapply(
    question@group_options,
    function(option) pull_question(data, question@members[[option]])
  )
  stack_answers(parts, question@group_options)
}

## Extraction ------------------------------------------------------------------

#' Pull a question's answers out of survey data
#'
#' `pull_question()` is the bridge between a question's description and the
#' answers behind it. Given the data and a [survey_var] or [survey_var_group],
#' it returns one long data frame of answers with value labels already applied.
#'
#' The result always has the same four columns, whatever the question's shape,
#' so a caller never has to reshape before counting:
#'
#' \describe{
#'   \item{`.row`}{The respondent's row number in `data`.}
#'   \item{`group`}{For a [survey_var_group], the group option this answer
#'     belongs to; `NA` for a plain [survey_var].}
#'   \item{`item`}{The sub-item within the question: the selected option for a
#'     `multi`, the column name for `other`, and `NA` for `single` and
#'     `open_end`, which have only one answer each.}
#'   \item{`value`}{The answer. A labelled factor for `single`, `TRUE`/`FALSE`
#'     for each option of a `multi`, and the raw column otherwise.}
#' }
#'
#' Every respondent appears for every option of a `multi`, selected or not, so
#' the base is preserved and counting selections is `sum(value)`.
#'
#' @param data A data frame holding the survey's raw columns.
#' @param question A [survey_var] or [survey_var_group].
#'
#' @return A data frame with columns `.row`, `group`, `item`, and `value`.
#' @examples
#' gender <- survey_var(
#'   stem = "S_GENDER",
#'   cols = "S_GENDER",
#'   type = "single",
#'   question_text = "What is your gender?",
#'   response_options = list(`1` = "Male", `2` = "Female", `3` = "Prefer not to say")
#' )
#' head(pull_question(example_survey, gender))
#'
#' sports <- survey_var(
#'   stem = "M_SPORTS",
#'   cols = paste0("M_SPORTS_", 1:4),
#'   type = "multi",
#'   question_text = "Which of the following sports do you play?",
#'   response_options = list(
#'     M_SPORTS_1 = "Basketball",
#'     M_SPORTS_2 = "Soccer",
#'     M_SPORTS_3 = "Tennis",
#'     M_SPORTS_4 = "Swimming"
#'   )
#' )
#' answers <- pull_question(example_survey, sports)
#' table(answers$item, answers$value)
#' @export
pull_question <- function(data, question) {
  if (!is.data.frame(data)) {
    cli::cli_abort(c(
      "{.arg data} must be a data frame.",
      x = "You supplied {.cls {class(data)}}."
    ))
  }
  if (S7::S7_inherits(question, survey_var)) {
    return(pull_survey_var(data, question))
  }
  if (S7::S7_inherits(question, survey_var_group)) {
    return(pull_survey_var_group(data, question))
  }
  cli::cli_abort(c(
    "{.arg question} must be a {.cls survey_var} or {.cls survey_var_group}.",
    x = "You supplied {.cls {class(question)}}."
  ))
}
