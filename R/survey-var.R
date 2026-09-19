# Survey Question as a Single S7 Object ----------------------------------------

## Types -----------------------------------------------------------------------

survey_var_types <- c(
  single = "Single-Select",
  multi = "Multi-Select",
  open_end = "Open-End",
  other = "Other"
)


## Class -----------------------------------------------------------------------

#' A single survey question
#'
#' `survey_var` represents one survey question as a single object, whether
#' it's backed by one raw column (a single-select or open-end) or several
#' sharing a stem (a multi-select, dummy-coded one column per option).
#' Objects are built by hand; no field is inferred from data.
#'
#' A question whose parts are answered *separately* -- a matrix/grid, or a
#' question looped over some dimension -- is a [survey_var_group], not a
#' `survey_var`. The distinction is how many answers the respondent gives:
#' a multi-select is one answer that happens to be a set, while a matrix is
#' several answers that happen to share a scale.
#'
#' @param stem A single string: the question's conceptual name, e.g.
#'   `"M_SPORTS"`.
#' @param cols A character vector of one or more raw column names backing
#'   the question, e.g. `c("M_SPORTS_1", "M_SPORTS_2")`. Must not contain
#'   duplicates, `NA`, or empty strings.
#' @param type A single string describing the question's shape: one of
#'   `"single"`, `"multi"`, `"open_end"`, or `"other"`. `"single"` and
#'   `"open_end"` require exactly one column in `cols`.
#' @param question_text A single string with the question as asked, or `NA`
#'   if not (yet) known.
#' @param response_options A named list mapping each possible answer to its
#'   label text, or an empty list if not (yet) known. What the names mean
#'   depends on `type`: for `"single"` they are the value codes stored in the
#'   column (e.g. `` `1` = "Male" ``); for `"multi"` they are entries in
#'   `cols`, one per selectable option (e.g. `M_SPORTS_1 = "Basketball"`),
#'   because a multi-select's options are dummy-coded one per column. In both
#'   cases the name is the key you look up to find that option in the data.
#'
#' @return A `survey_var` object.
#' @examples
#' survey_var(
#'   stem = "S_GENDER",
#'   cols = "S_GENDER",
#'   type = "single",
#'   question_text = "What is your gender?",
#'   response_options = list(`1` = "Male", `2` = "Female")
#' )
#'
#' survey_var(
#'   stem = "M_SPORTS",
#'   cols = c("M_SPORTS_1", "M_SPORTS_2", "M_SPORTS_3", "M_SPORTS_4"),
#'   type = "multi",
#'   question_text = "Which of the following sports do you play?",
#'   response_options = list(
#'     M_SPORTS_1 = "Basketball",
#'     M_SPORTS_2 = "Soccer",
#'     M_SPORTS_3 = "Tennis",
#'     M_SPORTS_4 = "Swimming"
#'   )
#' )
#' @export
survey_var <- S7::new_class(
  "survey_var",
  properties = list(
    stem = S7::class_character,
    cols = S7::class_character,
    type = S7::class_character,
    question_text = S7::new_property(
      S7::class_character,
      default = NA_character_
    ),
    response_options = S7::new_property(S7::class_list, default = quote(list()))
  ),
  validator = function(self) {
    if (length(self@stem) != 1 || is.na(self@stem) || !nzchar(self@stem)) {
      return("@stem must be a single non-empty string")
    }
    if (length(self@cols) == 0) {
      return("@cols must contain at least one column name")
    }
    if (anyNA(self@cols) || !all(nzchar(self@cols))) {
      return("@cols must not contain NA or empty strings")
    }
    if (anyDuplicated(self@cols) > 0) {
      return("@cols must not contain duplicates")
    }
    if (length(self@type) != 1 || !self@type %in% names(survey_var_types)) {
      return(paste0(
        "@type must be one of ",
        paste(names(survey_var_types), collapse = ", ")
      ))
    }
    if (self@type %in% c("single", "open_end") && length(self@cols) != 1) {
      return(paste0(
        "@type = \"",
        self@type,
        "\" requires exactly one column in @cols"
      ))
    }
    if (
      self@type == "multi" &&
        length(self@response_options) > 0 &&
        !all(names(self@response_options) %in% self@cols)
    ) {
      return(
        "names(@response_options) must all be entries in @cols when @type = \"multi\""
      )
    }
    NULL
  }
)
## Print -----------------------------------------------------------------------

format_survey_var <- function(v, n = 5) {
  width <- nchar("Question:")
  cli::cli_fmt({
    cli::cli_text("{.cls survey_var} {fmt_object_name(v@stem)}")
    cli_field_block(width)
    cli::cli_text(
      "{fmt_field('Type', width)} {fmt_level(survey_var_types[[v@type]])}"
    )
    cli::cli_text("{fmt_field('Columns', width)} {fmt_level(length(v@cols))}")
    cli_question_line(v@question_text, width)
    cli::cli_end()
    cli_named_list_section("Response Options:", v@response_options, n)
  })
}

S7::method(format, survey_var) <- function(x, ..., n = 5) {
  format_survey_var(x, n = n)
}

S7::method(print, survey_var) <- function(x, ..., n = 5) {
  cat(format(x, n = n), sep = "\n")
  invisible(x)
}
