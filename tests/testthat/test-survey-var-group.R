## Fixtures --------------------------------------------------------------------

freq_options <- list(`1` = "Never", `2` = "Rarely", `3` = "Often")

single_member <- function(col) {
  survey_var(
    stem = col,
    cols = col,
    type = "single",
    response_options = freq_options
  )
}

sports_group <- function(...) {
  args <- list(
    stem = "S_SPORTS_FREQ",
    group_var = "sport",
    group_options = c("Basketball", "Soccer"),
    question_text = "How often do you play each of the following sports?",
    members = list(
      Basketball = single_member("S_SPORTS_FREQ_1"),
      Soccer = single_member("S_SPORTS_FREQ_2")
    )
  )
  do.call(survey_var_group, utils::modifyList(args, list(...)))
}

## Construction ----------------------------------------------------------------

test_that("survey_var_group stores fields and fills in defaults", {
  g <- sports_group()

  expect_equal(g@stem, "S_SPORTS_FREQ")
  expect_equal(g@group_var, "sport")
  expect_equal(g@group_options, c("Basketball", "Soccer"))
  expect_length(g@members, 2)
  expect_equal(g@members$Basketball@cols, "S_SPORTS_FREQ_1")
  expect_true(is.na(
    survey_var_group(
      stem = "X",
      group_var = "y",
      group_options = "a",
      members = list(a = single_member("A"))
    )@question_text
  ))
})

test_that("a matrix question is a group of single-selects", {
  g <- sports_group()

  expect_equal(
    unique(vapply(g@members, function(m) m@type, character(1))),
    "single"
  )
  expect_equal(g@members$Soccer@response_options, freq_options)
})

test_that("members are reachable by group option", {
  g <- sports_group()

  expect_equal(g@members[["Soccer"]]@cols, "S_SPORTS_FREQ_2")
})

## Validation ------------------------------------------------------------------

test_that("survey_var_group rejects an empty or missing stem", {
  expect_snapshot(error = TRUE, sports_group(stem = ""))
  expect_snapshot(error = TRUE, sports_group(stem = NA_character_))
})

test_that("survey_var_group rejects an empty or missing group_var", {
  expect_snapshot(error = TRUE, sports_group(group_var = ""))
})

test_that("survey_var_group rejects empty or duplicated group_options", {
  expect_snapshot(error = TRUE, sports_group(group_options = character(0)))
  expect_snapshot(
    error = TRUE,
    sports_group(
      group_options = c("Basketball", "Basketball"),
      members = list(
        Basketball = single_member("S_SPORTS_FREQ_1"),
        Soccer = single_member("S_SPORTS_FREQ_2")
      )
    )
  )
})

test_that("survey_var_group requires members to match group_options", {
  expect_snapshot(
    error = TRUE,
    sports_group(
      members = list(
        Basketball = single_member("S_SPORTS_FREQ_1"),
        Tennis = single_member("S_SPORTS_FREQ_2")
      )
    )
  )
})

test_that("survey_var_group rejects non-survey_var members", {
  expect_snapshot(
    error = TRUE,
    sports_group(
      members = list(
        Basketball = single_member("S_SPORTS_FREQ_1"),
        Soccer = "nope"
      )
    )
  )
})

test_that("survey_var_group rejects members of mixed type", {
  expect_snapshot(
    error = TRUE,
    sports_group(
      members = list(
        Basketball = single_member("S_SPORTS_FREQ_1"),
        Soccer = survey_var(
          stem = "S_SPORTS_FREQ_2",
          cols = "S_SPORTS_FREQ_2",
          type = "multi"
        )
      )
    )
  )
})

## Printing --------------------------------------------------------------------

test_that("survey_var_group prints its own stem, not its group_var", {
  expect_snapshot(print(sports_group()))
})

test_that("survey_var_group prints (none) for missing question text", {
  expect_snapshot(print(sports_group(question_text = NA_character_)))
})
