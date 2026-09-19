# Grouped Survey Questions -----------------------------------------------------

## Class -----------------------------------------------------------------------

#' A group of `survey_var` objects sharing one question
#'
#' `survey_var_group` bundles several [survey_var] objects that ask
#' conceptually the same question but were answered *separately*, once per
#' level of some dimension. This covers matrix/grid questions, where the
#' dimension is the row item, and looped questions, where it is the loop
#' level -- structurally these are the same thing.
#'
#' Contrast a multi-select [survey_var], whose columns are options within a
#' single answer. Here each member is its own complete, independently valid
#' `survey_var`, because each corresponds to a separate answer the
#' respondent gave.
#'
#' @param stem A single string: the group's conceptual name, e.g.
#'   `"S_SPORTS_FREQ"`.
#' @param group_var A single string naming the dimension the question varies
#'   over, e.g. `"sport"` for a matrix or `"device"` for a loop.
#' @param group_options A character vector of that dimension's levels, e.g.
#'   `c("Basketball", "Soccer")`. Must not contain duplicates.
#' @param members A named list of [survey_var] objects, one per entry in
#'   `group_options`, named to match. All members must share the same `type`.
#' @param question_text A single string with the shared question as asked,
#'   or `NA` if not (yet) known.
#'
#' @return A `survey_var_group` object.
#' @examples
#' freq <- list(`1` = "Never", `2` = "Rarely", `3` = "Often")
#' survey_var_group(
#'   stem = "S_SPORTS_FREQ",
#'   group_var = "sport",
#'   group_options = c("Basketball", "Soccer"),
#'   question_text = "How often do you play each of the following sports?",
#'   members = list(
#'     Basketball = survey_var(
#'       stem = "S_SPORTS_FREQ_1",
#'       cols = "S_SPORTS_FREQ_1",
#'       type = "single",
#'       response_options = freq
#'     ),
#'     Soccer = survey_var(
#'       stem = "S_SPORTS_FREQ_2",
#'       cols = "S_SPORTS_FREQ_2",
#'       type = "single",
#'       response_options = freq
#'     )
#'   )
#' )
#' @export
survey_var_group <- S7::new_class(
  "survey_var_group",
  properties = list(
    stem = S7::class_character,
    group_var = S7::class_character,
    group_options = S7::class_character,
    members = S7::class_list,
    question_text = S7::new_property(
      S7::class_character,
      default = NA_character_
    )
  ),
  validator = function(self) {
    if (length(self@stem) != 1 || is.na(self@stem) || !nzchar(self@stem)) {
      return("@stem must be a single non-empty string")
    }
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
    if (
      !all(vapply(
        self@members,
        S7::S7_inherits,
        logical(1),
        class = survey_var
      ))
    ) {
      return("@members must all be survey_var objects")
    }
    types <- vapply(self@members, function(m) m@type, character(1))
    if (length(unique(types)) > 1) {
      return("all @members must share the same @type")
    }
    NULL
  }
)
## Print -----------------------------------------------------------------------

format_survey_var_group <- function(g, n = 5) {
  width <- nchar("Group Var:")
  tr <- truncate_items(g@group_options, n)
  option_width <- nchar(as.character(length(g@group_options))) + 1L
  cli::cli_fmt({
    cli::cli_text("{.cls survey_var_group} {fmt_object_name(g@stem)}")
    cli_field_block(width)
    cli_question_line(g@question_text, width)
    cli::cli_text("{fmt_field('Group Var', width)} {fmt_level(g@group_var)}")
    cli::cli_text(
      "{fmt_field('Type', width)} {fmt_level(survey_var_types[[g@members[[1]]@type]])}"
    )
    cli::cli_text(
      "{fmt_field('Members', width)} {fmt_level(length(g@members))}"
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

S7::method(format, survey_var_group) <- function(x, ..., n = 5) {
  format_survey_var_group(x, n = n)
}

S7::method(print, survey_var_group) <- function(x, ..., n = 5) {
  cat(format(x, n = n), sep = "\n")
  invisible(x)
}
