# A Grouped Set of survey_var Objects -----------------------------------------

# A `survey_var_group` bundles several *separately-asked* survey_var objects
# that share the same conceptual question but differ by some looping
# dimension (e.g. the same interest question asked once per device). This is
# distinct from a single survey_var's `cols`/`subquestion_labels`, which
# represent *parts of one asking* (e.g. one column per sport in a
# multi-select) -- here, each member is its own complete, independently valid
# survey_var, because each one corresponds to a separate respondent-facing
# question instance, not a sub-item of one question.

#' A group of `survey_var` objects sharing a loop dimension
#'
#' `survey_var_group` bundles several [survey_var] objects that ask
#' conceptually the same question but were asked separately across some
#' looping dimension (e.g. the same question repeated once per device).
#'
#' @param group_var A single string naming the looping dimension, e.g.
#'   `"device"`.
#' @param group_options A character vector of the loop's possible values,
#'   e.g. `c("iPhone", "Android")`.
#' @param members A named list of [survey_var] objects, one per entry in
#'   `group_options`, named to match.
#'
#' @return A `survey_var_group` object.
#' @examples
#' iphone <- survey_var(
#'   stem = "M_INTERESTED_IPHONE",
#'   cols = c("M_INTERESTED_IPHONE_1", "M_INTERESTED_IPHONE_2"),
#'   type = "multi",
#'   option_labels = list(
#'     M_INTERESTED_IPHONE_1 = "Camera",
#'     M_INTERESTED_IPHONE_2 = "Battery Life"
#'   )
#' )
#' android <- survey_var(
#'   stem = "M_INTERESTED_ANDROID",
#'   cols = c("M_INTERESTED_ANDROID_1", "M_INTERESTED_ANDROID_2"),
#'   type = "multi",
#'   option_labels = list(
#'     M_INTERESTED_ANDROID_1 = "Camera",
#'     M_INTERESTED_ANDROID_2 = "Battery Life"
#'   )
#' )
#' survey_var_group(
#'   group_var = "device",
#'   group_options = c("iPhone", "Android"),
#'   members = list(iPhone = iphone, Android = android)
#' )
#' @export
survey_var_group <- S7::new_class(
  "survey_var_group",
  properties = list(
    group_var = S7::class_character,
    group_options = S7::class_character,
    members = S7::class_list
  ),
  validator = function(self) {
    validate_survey_var_group_fields(
      self@group_var,
      self@group_options,
      self@members
    )
  }
)

# Structural invariants only, mirroring validate_survey_var_fields(): returns
# NULL when valid, or a description of the problem (S7 validator convention).
validate_survey_var_group_fields <- function(
  group_var,
  group_options,
  members
) {
  if (length(group_var) != 1 || is.na(group_var) || !nzchar(group_var)) {
    return("@group_var must be a single non-empty string")
  }
  if (length(group_options) == 0) {
    return("@group_options must contain at least one value")
  }
  if (anyDuplicated(group_options) > 0) {
    return("@group_options must not contain duplicates")
  }
  if (length(group_options) != length(members)) {
    return("@group_options must have exactly one entry per @members")
  }
  if (!setequal(names(members), group_options)) {
    return("names(@members) must match @group_options exactly")
  }
  if (!all(vapply(members, S7::S7_inherits, logical(1), class = survey_var))) {
    return("@members must all be survey_var objects")
  }
  types <- vapply(members, get_type, character(1))
  if (length(unique(types)) > 1) {
    return("all @members must share the same @type")
  }
  NULL
}

## Accessors ------------------------------------------------------------

#' Access `survey_var_group` fields
#'
#' @param g A [survey_var_group] object.
#' @return The requested field.
#' @name survey_var_group-accessors
#' @export
get_group_var <- function(g) g@group_var

#' @rdname survey_var_group-accessors
#' @export
get_group_options <- function(g) g@group_options

#' @rdname survey_var_group-accessors
#' @export
get_members <- function(g) g@members

#' Access a single member of a `survey_var_group`
#'
#' @param g A [survey_var_group] object.
#' @param option A single string, one of `get_group_options(g)`.
#' @return The [survey_var] for that option.
#' @export
get_member <- function(g, option) g@members[[option]]

## Print method -----------------------------------------------------------

# Reusable formatter -- kept separate from the print method itself, matching
# format_survey_var()'s split, so it can be unit-tested independent of cat().
format_survey_var_group <- function(g, n = 5) {
  gvar <- get_group_var(g)
  gopts <- get_group_options(g)
  mem <- get_members(g)
  member_type <- if (length(mem) > 0) get_type(mem[[1]]) else NA_character_

  label_w <- nchar("Group Var:")

  lines <- c(
    paste0(fmt_tag("survey_var_group"), " ", fmt_object_name(gvar)),
    wrap_field("Group Var", gvar, label_w),
    wrap_field(
      "Type",
      if (member_type %in% names(type_display_names)) {
        type_display_names[[member_type]]
      } else {
        member_type
      },
      label_w
    ),
    wrap_field("Members", length(mem), label_w)
  )

  lines <- c(lines, paste0("  ", fmt_collection("Group Options:")))
  tr <- truncate_items(gopts, n)
  for (i in seq_along(tr$shown)) {
    lines <- c(
      lines,
      wrap_field(as.character(i), tr$shown[[i]], label_w = 2, indent = "  ")
    )
  }
  if (tr$more > 0) {
    lines <- c(lines, truncation_note(tr$more, ""))
  }

  lines
}

# `n` caps how many group options are printed before truncating; pass
# `n = Inf` to always print in full.
S7::method(print, survey_var_group) <- function(x, ..., n = 5) {
  cat(format_survey_var_group(x, n = n), sep = "\n")
  invisible(x)
}
