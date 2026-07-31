# Survey Question as a Single S7 Object -------------------------------------

# A single survey question: one or more raw columns sharing a stem
# (e.g. `M_SPORTS_1`, `M_SPORTS_2`, ...), represented as one object with
# metadata a human/AI can reason about (question text, response options,
# subquestion/option text) rather than a scatter of separate columns.
#
# This is a deliberately minimal, fully manual class: nothing auto-detects
# or parses these fields from raw data yet. The validator enforces
# structural invariants that are true by definition of a type -- e.g. a
# `multi` fundamentally has more than one column -- but does not require any
# type's *descriptive* fields (question_text/subquestion_labels/
# option_labels/response_options) to be filled in. That keeps a `survey_var`
# buildable incrementally -- stem/cols/type first, descriptive text whenever
# it's ready -- while still catching structural mistakes immediately.
#
# `subquestion_labels` and `option_labels` look similar (both map a column
# name to text) but mean different things:
#   - `subquestion_labels` (matrix): each column is a genuinely separate
#     sub-question, sharing a common response scale (`response_options`).
#   - `option_labels` (multi): each column is one *response option* of a
#     single question, dummy-coded into its own column so more than one can
#     be selected -- the "question" is singular, the columns are choices.

#' A single survey question
#'
#' `survey_var` represents one survey question as a single object, whether
#' it's backed by one raw column (e.g. a single-select) or several sharing a
#' stem (e.g. a multi-select or matrix). Objects are built by hand; no field
#' is inferred from data.
#'
#' @param stem A single string: the question's conceptual name, e.g.
#'   `"M_SPORTS"`.
#' @param cols A character vector of one or more raw column names backing
#'   the question, e.g. `c("M_SPORTS_1", "M_SPORTS_2")`.
#' @param type A single string describing the question's shape: one of
#'   `"single"`, `"multi"`, `"matrix"`, `"open_end"`, or `"other"`. Column
#'   count is validated against `type`: `single`/`open_end` require exactly
#'   one column in `cols`; `multi`/`matrix` require more than one.
#' @param question_text A single string with the question as asked, or `NA`
#'   if not (yet) known.
#' @param subquestion_labels A named list mapping each column in `cols` to
#'   the sub-question it represents. Relevant for `matrix` questions, where
#'   each column is a separate item sharing a common response scale; an
#'   empty list otherwise. Any names present must match entries in `cols`.
#' @param option_labels A named list mapping each column in `cols` to the
#'   response option it represents. Relevant for `multi` questions, where
#'   each column is a dummy-coded choice within one question (not a separate
#'   sub-question); an empty list otherwise. Any names present must match
#'   entries in `cols`.
#' @param response_options A named list mapping response value codes to
#'   their label text. Relevant for `single`/`matrix` questions; an empty
#'   list otherwise.
#'
#' @return A `survey_var` object.
#' @examples
#' # `example_survey` stores M_SPORTS as one dummy column per sport; here
#' # it's represented as a single multi-select survey_var instead. Each
#' # column is a response *option* (a sport you can pick), not a
#' # subquestion, since the question itself ("which sports do you play?")
#' # is singular.
#' survey_var(
#'   stem = "M_SPORTS",
#'   cols = c("M_SPORTS_1", "M_SPORTS_2", "M_SPORTS_3", "M_SPORTS_4"),
#'   type = "multi",
#'   question_text = "Which of the following sports do you play?",
#'   option_labels = list(
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
    subquestion_labels = S7::new_property(
      S7::class_list,
      default = quote(list())
    ),
    option_labels = S7::new_property(S7::class_list, default = quote(list())),
    response_options = S7::new_property(S7::class_list, default = quote(list()))
  ),
  validator = function(self) {
    validate_survey_var_fields(
      self@stem,
      self@cols,
      self@type,
      self@subquestion_labels,
      self@option_labels
    )
  }
)

# Valid `type` values. Kept as a plain descriptive tag for now -- no
# per-type *descriptive-field* requirements are enforced (see NOTE above);
# only column-count, which is structural.
valid_survey_var_types <- c("single", "multi", "matrix", "open_end", "other")

# Column-count invariants per @type: a structural fact about what each type
# *means*, not a completeness concern -- so these are enforced from
# construction, unlike question_text/subquestion_labels/option_labels/
# response_options being *filled in*.
survey_var_col_requirements <- list(
  single = function(n) n == 1,
  multi = function(n) n > 1,
  matrix = function(n) n > 1,
  open_end = function(n) n == 1,
  other = function(n) n >= 1
)

survey_var_col_requirement_msg <- c(
  single = "@type = \"single\" requires exactly one column in @cols",
  multi = "@type = \"multi\" requires more than one column in @cols",
  matrix = "@type = \"matrix\" requires more than one column in @cols",
  open_end = "@type = \"open_end\" requires exactly one column in @cols",
  other = "@cols must contain at least one column name"
)

# Structural invariants only -- returns NULL when valid, or a description of
# the problem (S7 validator convention).
validate_survey_var_fields <- function(
  stem,
  cols,
  type,
  subquestion_labels,
  option_labels
) {
  if (length(stem) != 1 || is.na(stem) || !nzchar(stem)) {
    return("@stem must be a single non-empty string")
  }
  if (length(cols) == 0) {
    return("@cols must contain at least one column name")
  }
  if (length(type) != 1 || !type %in% valid_survey_var_types) {
    return(paste0(
      "@type must be one of ",
      paste(valid_survey_var_types, collapse = ", ")
    ))
  }
  if (!survey_var_col_requirements[[type]](length(cols))) {
    return(survey_var_col_requirement_msg[[type]])
  }
  if (
    length(subquestion_labels) > 0 &&
      !all(names(subquestion_labels) %in% cols)
  ) {
    return("names(@subquestion_labels) must all be entries in @cols")
  }
  if (length(option_labels) > 0 && !all(names(option_labels) %in% cols)) {
    return("names(@option_labels) must all be entries in @cols")
  }
  NULL
}

## Accessors ------------------------------------------------------------

# User-facing reads of survey_var properties go through these functions
# rather than `@`, so the underlying property names are free to change
# without breaking calling code.

#' Access `survey_var` fields
#'
#' @param v A [survey_var] object.
#' @return The requested field.
#' @name survey_var-accessors
#' @export
get_stem <- function(v) v@stem

#' @rdname survey_var-accessors
#' @export
get_cols <- function(v) v@cols

#' @rdname survey_var-accessors
#' @export
get_type <- function(v) v@type

#' @rdname survey_var-accessors
#' @export
get_question_text <- function(v) v@question_text

#' @rdname survey_var-accessors
#' @export
get_subquestions <- function(v) v@subquestion_labels

#' @rdname survey_var-accessors
#' @export
get_option_labels <- function(v) v@option_labels

#' @rdname survey_var-accessors
#' @export
get_response_options <- function(v) v@response_options

## Print method -----------------------------------------------------------

# Friendly display names for each type.
type_display_names <- c(
  single = "Single-Select",
  multi = "Multi-Select",
  matrix = "Matrix",
  open_end = "Open-End",
  other = "Other"
)

# Renders a named list (subquestion_labels/option_labels/response_options)
# as truncated "code: label" lines under a section header. Shared by
# format_survey_var() so the three sections stay visually consistent.
format_named_list_section <- function(header, items, n, label_w = NULL) {
  if (length(items) == 0) {
    return(character())
  }
  if (is.null(label_w)) {
    label_w <- max(nchar(names(items)))
  }
  lines <- paste0("  ", fmt_collection(header))
  tr <- truncate_items(items, n)
  for (code in names(tr$shown)) {
    lines <- c(
      lines,
      wrap_field(
        code,
        unlist(tr$shown[[code]]),
        label_w = label_w,
        indent = "  "
      )
    )
  }
  if (tr$more > 0) lines <- c(lines, truncation_note(tr$more, ""))
  lines
}

# Reusable formatter -- kept separate from the print method itself so it can
# be unit-tested / reused independent of `cat()`.
format_survey_var <- function(v, n = 5) {
  type_i <- get_type(v)
  qtext <- get_question_text(v)
  subq <- get_subquestions(v)
  opts <- get_option_labels(v)
  resp <- get_response_options(v)

  label_w <- nchar("Question:") # widest of Type/Columns/Question, for alignment

  lines <- c(
    paste0(fmt_tag("survey_var"), " ", fmt_object_name(get_stem(v))),
    wrap_field(
      "Type",
      if (type_i %in% names(type_display_names)) {
        type_display_names[[type_i]]
      } else {
        type_i
      },
      label_w
    ),
    wrap_field("Columns", length(get_cols(v)), label_w),
    wrap_field(
      "Question",
      if (length(qtext) == 0 || is.na(qtext)) "(none)" else qtext,
      label_w,
      value_fmt = if (length(qtext) == 0 || is.na(qtext)) {
        fmt_annotation
      } else {
        fmt_level
      }
    )
  )

  lines <- c(
    lines,
    format_named_list_section("Subquestions:", subq, n, label_w = 2),
    format_named_list_section("Options:", opts, n, label_w = 2),
    format_named_list_section("Response Options:", resp, n)
  )

  lines
}

# `n` caps how many subquestions/options/response options are printed
# before truncating (see `truncate_items()`); pass `n = Inf` to always
# print in full.
S7::method(print, survey_var) <- function(x, ..., n = 5) {
  cat(format_survey_var(x, n = n), sep = "\n")
  invisible(x)
}
