# Survey Questions -------------------------------------------------------------

## Properties ------------------------------------------------------------------

prop_col <- S7::new_property(
  S7::class_character,
  validator = function(value) {
    if (length(value) != 1 || is.na(value) || !nzchar(value)) {
      return("must be a single column name")
    }
    NULL
  }
)

prop_cols <- S7::new_property(
  S7::class_character,
  validator = function(value) {
    if (length(value) == 0) {
      return("must contain at least one column name")
    }
    if (anyNA(value) || !all(nzchar(value))) {
      return("must not contain NA or empty strings")
    }
    if (anyDuplicated(value) > 0) {
      return("must not contain duplicates")
    }
    NULL
  }
)

## Parent ----------------------------------------------------------------------

question <- S7::new_class(
  "question",
  abstract = TRUE,
  properties = list(
    stem = S7::class_character,
    question_text = S7::new_property(
      S7::class_character,
      default = NA_character_
    )
  ),
  validator = function(self) {
    if (length(self@stem) != 1 || is.na(self@stem) || !nzchar(self@stem)) {
      return("@stem must be a single non-empty string")
    }
    NULL
  }
)

## Questions Answered Once -----------------------------------------------------

#' Survey questions the respondent answered once
#'
#' Each kind of survey question is its own class. `single_select()`,
#' `multi_select()` and `open_end()` each build one question the respondent
#' answered once, whether it's backed by one raw column or several sharing a
#' stem. Objects are built by hand; no field is inferred from data.
#'
#' - `single_select()`: one column holding one value code per respondent.
#' - `multi_select()`: one dummy-coded column per option, so the respondent
#'   can pick several.
#' - `open_end()`: one column of free text.
#'
#' A question whose parts are answered *separately* -- a matrix/grid, or a
#' question looped over some dimension -- is a [battery]. The distinction is
#' how many answers the respondent gives: a multi-select is one answer that
#' happens to be a set, while a battery is several answers that happen to
#' share a scale.
#'
#' @param stem A single string: the question's conceptual name, e.g.
#'   `"M_SPORTS"`.
#' @param question_text A single string with the question as asked, or `NA`
#'   if not (yet) known.
#' @param cols The raw column names backing the question. Exactly one for
#'   `single_select()` and `open_end()`; one or more for `multi_select()`,
#'   e.g. `c("M_SPORTS_1", "M_SPORTS_2")`. Must not contain duplicates, `NA`,
#'   or empty strings.
#' @param response_options A named list mapping each possible answer to its
#'   label text, or an empty list if not (yet) known. For `single_select()`
#'   the names are the value codes stored in the column (e.g.
#'   `` `1` = "Male" ``); for `multi_select()` they are entries in `cols`, one
#'   per selectable option (e.g. `M_SPORTS_1 = "Basketball"`), because a
#'   multi-select's options are dummy-coded one per column. In both cases the
#'   name is the key you look up to find that option in the data.
#'
#' @return A `single_select`, `multi_select` or `open_end` object.
#' @examples
#' single_select(
#'   stem = "S_GENDER",
#'   cols = "S_GENDER",
#'   question_text = "What is your gender?",
#'   response_options = list(`1` = "Male", `2` = "Female")
#' )
#'
#' multi_select(
#'   stem = "M_SPORTS",
#'   cols = c("M_SPORTS_1", "M_SPORTS_2", "M_SPORTS_3", "M_SPORTS_4"),
#'   question_text = "Which of the following sports do you play?",
#'   response_options = list(
#'     M_SPORTS_1 = "Basketball",
#'     M_SPORTS_2 = "Soccer",
#'     M_SPORTS_3 = "Tennis",
#'     M_SPORTS_4 = "Swimming"
#'   )
#' )
#'
#' open_end(
#'   stem = "comments_oe",
#'   cols = "comments_oe",
#'   question_text = "Any other comments about your sports habits?"
#' )
#' @export
single_select <- S7::new_class(
  "single_select",
  parent = question,
  properties = list(
    cols = prop_col,
    response_options = S7::new_property(S7::class_list, default = quote(list()))
  )
)

#' @rdname single_select
#' @export
multi_select <- S7::new_class(
  "multi_select",
  parent = question,
  properties = list(
    cols = prop_cols,
    response_options = S7::new_property(S7::class_list, default = quote(list()))
  ),
  validator = function(self) {
    if (
      length(self@response_options) > 0 &&
        !all(names(self@response_options) %in% self@cols)
    ) {
      return("names(@response_options) must all be entries in @cols")
    }
    NULL
  }
)

#' @rdname single_select
#' @export
open_end <- S7::new_class(
  "open_end",
  parent = question,
  properties = list(cols = prop_col)
)

## Battery ---------------------------------------------------------------------

#' A battery of questions sharing one stem
#'
#' `battery` bundles several questions that ask conceptually the same thing
#' but were answered *separately*, once per level of some dimension. This
#' covers matrix/grid questions, where the dimension is the row item, and
#' looped questions, where it is the loop level -- structurally these are the
#' same thing.
#'
#' Contrast a [multi_select], whose columns are options within a single
#' answer. Here each member is its own complete, independently valid question,
#' because each corresponds to a separate answer the respondent gave.
#'
#' @inheritParams single_select
#' @param stem A single string: the battery's conceptual name, e.g.
#'   `"S_SPORTS_FREQ"`.
#' @param group_var A single string naming the dimension the question varies
#'   over, e.g. `"sport"` for a matrix or `"device"` for a loop.
#' @param group_options A character vector of that dimension's levels, e.g.
#'   `c("Basketball", "Soccer")`. Must not contain duplicates.
#' @param members A named list of questions, one per entry in
#'   `group_options`, named to match. Members must all be the same kind:
#'   [single_select], [multi_select] or [open_end].
#'
#' @return A `battery` object.
#' @examples
#' freq <- list(`1` = "Never", `2` = "Rarely", `3` = "Often")
#' battery(
#'   stem = "S_SPORTS_FREQ",
#'   group_var = "sport",
#'   group_options = c("Basketball", "Soccer"),
#'   question_text = "How often do you play each of the following sports?",
#'   members = list(
#'     Basketball = single_select(
#'       stem = "S_SPORTS_FREQ_1",
#'       cols = "S_SPORTS_FREQ_1",
#'       response_options = freq
#'     ),
#'     Soccer = single_select(
#'       stem = "S_SPORTS_FREQ_2",
#'       cols = "S_SPORTS_FREQ_2",
#'       response_options = freq
#'     )
#'   )
#' )
#' @export
battery <- S7::new_class(
  "battery",
  parent = question,
  properties = list(
    group_var = S7::class_character,
    group_options = S7::class_character,
    members = S7::class_list
  ),
  validator = function(self) {
    if (
      length(self@group_var) != 1 ||
        is.na(self@group_var) ||
        !nzchar(self@group_var)
    ) {
      return("@group_var must be a single non-empty string")
    }
    if (length(self@group_options) == 0) {
      return("@group_options must contain at least one value")
    }
    if (anyDuplicated(self@group_options) > 0) {
      return("@group_options must not contain duplicates")
    }
    if (!setequal(names(self@members), self@group_options)) {
      return("names(@members) must match @group_options exactly")
    }
    answered_once <- vapply(
      self@members,
      function(m) S7::S7_inherits(m, question) && !S7::S7_inherits(m, battery),
      logical(1)
    )
    if (!all(answered_once)) {
      return("@members must all be questions answered once, not batteries")
    }
    kinds <- vapply(self@members, function(m) class(m)[[1]], character(1))
    if (length(unique(kinds)) > 1) {
      return("all @members must be the same kind of question")
    }
    NULL
  }
)

## Print -----------------------------------------------------------------------

question_kind <- S7::new_generic("question_kind", "x")

S7::method(question_kind, single_select) <- function(x) "Single-Select"
S7::method(question_kind, multi_select) <- function(x) "Multi-Select"
S7::method(question_kind, open_end) <- function(x) "Open-End"

format_question <- function(q, n, response_options = list()) {
  width <- nchar("Question:")
  cli::cli_fmt({
    cli::cli_text("{.cls {S7::S7_class(q)@name}} {fmt_object_name(q@stem)}")
    cli_field_block(width)
    cli::cli_text("{fmt_field('Type', width)} {fmt_level(question_kind(q))}")
    cli::cli_text("{fmt_field('Columns', width)} {fmt_level(length(q@cols))}")
    cli_question_line(q@question_text, width)
    cli::cli_end()
    cli_named_list_section("Response Options:", response_options, n)
  })
}

S7::method(format, single_select) <- function(x, ..., n = 5) {
  format_question(x, n, x@response_options)
}

S7::method(format, multi_select) <- function(x, ..., n = 5) {
  format_question(x, n, x@response_options)
}

S7::method(format, open_end) <- function(x, ..., n = 5) {
  format_question(x, n)
}

S7::method(format, battery) <- function(x, ..., n = 5) {
  width <- nchar("Group Var:")
  tr <- truncate_items(x@group_options, n)
  option_width <- nchar(as.character(length(x@group_options))) + 1L
  cli::cli_fmt({
    cli::cli_text("{.cls battery} {fmt_object_name(x@stem)}")
    cli_field_block(width)
    cli_question_line(x@question_text, width)
    cli::cli_text("{fmt_field('Group Var', width)} {fmt_level(x@group_var)}")
    cli::cli_text(
      "{fmt_field('Type', width)} {fmt_level(question_kind(x@members[[1]]))}"
    )
    cli::cli_text(
      "{fmt_field('Members', width)} {fmt_level(length(x@members))}"
    )
    cli::cli_end()
    cli_field_block(option_width)
    cli::cli_text("{fmt_collection('Group Options:')}")
    for (i in seq_along(tr$shown)) {
      cli::cli_text(
        "{fmt_field(as.character(i), option_width)} {fmt_level(tr$shown[[i]])}"
      )
    }
    cli_truncation_note(tr$more)
    cli::cli_end()
  })
}

S7::method(print, question) <- function(x, ..., n = 5) {
  cat(format(x, n = n), sep = "\n")
  invisible(x)
}
