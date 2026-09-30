## Fixtures --------------------------------------------------------------------

freq_options <- list(`1` = "Never", `2` = "Rarely", `3` = "Often")

freq_member <- function(col) {
  single_select(stem = col, cols = col, response_options = freq_options)
}

sports_battery <- function(...) {
  args <- list(
    stem = "S_SPORTS_FREQ",
    group_var = "sport",
    group_options = c("Basketball", "Soccer"),
    question_text = "How often do you play each of the following sports?",
    members = list(
      Basketball = freq_member("S_SPORTS_FREQ_1"),
      Soccer = freq_member("S_SPORTS_FREQ_2")
    )
  )
  do.call(battery, utils::modifyList(args, list(...)))
}

## Construction ----------------------------------------------------------------

test_that("a question stores fields and fills in defaults", {
  v <- multi_select(
    stem = "M_SPORTS",
    cols = c("M_SPORTS_1", "M_SPORTS_2"),
    question_text = "Which of the following sports do you play?",
    response_options = list(M_SPORTS_1 = "Basketball", M_SPORTS_2 = "Soccer")
  )

  expect_equal(v@stem, "M_SPORTS")
  expect_equal(v@cols, c("M_SPORTS_1", "M_SPORTS_2"))
  expect_equal(v@question_text, "Which of the following sports do you play?")
  expect_equal(
    v@response_options,
    list(M_SPORTS_1 = "Basketball", M_SPORTS_2 = "Soccer")
  )
})

test_that("a question can be built incrementally, with defaults for unset fields", {
  v <- multi_select(stem = "M_SPORTS", cols = "M_SPORTS_1")

  expect_true(is.na(v@question_text))
  expect_equal(v@response_options, list())
})

test_that("a multi-select may be backed by a single column", {
  expect_no_error(multi_select(stem = "M_SPORTS", cols = "M_SPORTS_1"))
})

test_that("a battery stores fields and fills in defaults", {
  g <- sports_battery()

  expect_equal(g@stem, "S_SPORTS_FREQ")
  expect_equal(g@group_var, "sport")
  expect_equal(g@group_options, c("Basketball", "Soccer"))
  expect_length(g@members, 2)
  expect_equal(g@members$Basketball@cols, "S_SPORTS_FREQ_1")
  expect_true(is.na(
    battery(
      stem = "X",
      group_var = "y",
      group_options = "a",
      members = list(a = freq_member("A"))
    )@question_text
  ))
})

test_that("a matrix question is a battery of single-selects", {
  g <- sports_battery()

  expect_true(all(vapply(
    g@members,
    S7::S7_inherits,
    logical(1),
    class = single_select
  )))
  expect_equal(g@members$Soccer@response_options, freq_options)
})

test_that("battery members are reachable by group option", {
  g <- sports_battery()

  expect_equal(g@members[["Soccer"]]@cols, "S_SPORTS_FREQ_2")
})

## Validation ------------------------------------------------------------------

test_that("a question rejects an empty or missing stem", {
  expect_snapshot(
    error = TRUE,
    single_select(stem = character(0), cols = "S_GENDER")
  )
  expect_snapshot(
    error = TRUE,
    single_select(stem = NA_character_, cols = "S_GENDER")
  )
  expect_snapshot(error = TRUE, single_select(stem = "", cols = "S_GENDER"))
  expect_snapshot(error = TRUE, sports_battery(stem = ""))
})

test_that("a question rejects unusable cols", {
  expect_snapshot(
    error = TRUE,
    single_select(stem = "S_GENDER", cols = character(0))
  )
  expect_snapshot(
    error = TRUE,
    multi_select(stem = "M_SPORTS", cols = character(0))
  )
  expect_snapshot(
    error = TRUE,
    multi_select(stem = "M_SPORTS", cols = c("M_SPORTS_1", NA))
  )
  expect_snapshot(
    error = TRUE,
    multi_select(stem = "M_SPORTS", cols = c("M_SPORTS_1", ""))
  )
  expect_snapshot(
    error = TRUE,
    multi_select(stem = "M_SPORTS", cols = c("M_SPORTS_1", "M_SPORTS_1"))
  )
})

test_that("single-selects and open-ends take exactly one column", {
  expect_snapshot(
    error = TRUE,
    single_select(stem = "S_GENDER", cols = c("A", "B"))
  )
  expect_snapshot(
    error = TRUE,
    open_end(stem = "comments_oe", cols = c("A", "B"))
  )
})

test_that("a multi's response option names must be columns", {
  expect_snapshot(
    error = TRUE,
    multi_select(
      stem = "M_SPORTS",
      cols = c("M_SPORTS_1", "M_SPORTS_2"),
      response_options = list(M_SPORTS_1 = "Basketball", nope = "Soccer")
    )
  )
})

test_that("a battery rejects an empty or missing group_var", {
  expect_snapshot(error = TRUE, sports_battery(group_var = ""))
})

test_that("a battery rejects empty or duplicated group_options", {
  expect_snapshot(error = TRUE, sports_battery(group_options = character(0)))
  expect_snapshot(
    error = TRUE,
    sports_battery(
      group_options = c("Basketball", "Basketball"),
      members = list(
        Basketball = freq_member("S_SPORTS_FREQ_1"),
        Soccer = freq_member("S_SPORTS_FREQ_2")
      )
    )
  )
})

test_that("a battery requires members to match group_options", {
  expect_snapshot(
    error = TRUE,
    sports_battery(
      members = list(
        Basketball = freq_member("S_SPORTS_FREQ_1"),
        Tennis = freq_member("S_SPORTS_FREQ_2")
      )
    )
  )
})

test_that("a battery's members must be questions answered once", {
  expect_snapshot(
    error = TRUE,
    sports_battery(
      members = list(
        Basketball = freq_member("S_SPORTS_FREQ_1"),
        Soccer = "nope"
      )
    )
  )
  expect_snapshot(
    error = TRUE,
    sports_battery(
      members = list(
        Basketball = freq_member("S_SPORTS_FREQ_1"),
        Soccer = sports_battery()
      )
    )
  )
})

test_that("a battery rejects members of mixed kinds", {
  expect_snapshot(
    error = TRUE,
    sports_battery(
      members = list(
        Basketball = freq_member("S_SPORTS_FREQ_1"),
        Soccer = multi_select(
          stem = "S_SPORTS_FREQ_2",
          cols = "S_SPORTS_FREQ_2"
        )
      )
    )
  )
})

## Printing --------------------------------------------------------------------

test_that("a single-select prints with question text and response options", {
  v <- single_select(
    stem = "S_GENDER",
    cols = "S_GENDER",
    question_text = "What is your gender?",
    response_options = list(
      `1` = "Male",
      `2` = "Female",
      `3` = "Prefer not to say"
    )
  )

  expect_snapshot(print(v))
})

test_that("a multi-select prints its options keyed by column", {
  v <- multi_select(
    stem = "M_SPORTS",
    cols = paste0("M_SPORTS_", 1:4),
    question_text = "Which of the following sports do you play?",
    response_options = list(
      M_SPORTS_1 = "Basketball",
      M_SPORTS_2 = "Soccer",
      M_SPORTS_3 = "Tennis",
      M_SPORTS_4 = "Swimming"
    )
  )

  expect_snapshot(print(v))
})

test_that("a question prints (none) for missing question text", {
  v <- multi_select(stem = "M_SPORTS", cols = "M_SPORTS_1")

  expect_snapshot(print(v))
})

test_that("print truncates long option lists, and n = Inf shows all", {
  v <- multi_select(
    stem = "M_BRANDS",
    cols = paste0("M_BRANDS_", 1:8),
    response_options = setNames(
      as.list(paste("Brand", LETTERS[1:8])),
      paste0("M_BRANDS_", 1:8)
    )
  )

  expect_snapshot(print(v))
  expect_snapshot(print(v, n = Inf))
})

test_that("format() returns the printed lines without printing", {
  v <- single_select(stem = "S_GENDER", cols = "S_GENDER")

  expect_type(format(v), "character")
  expect_silent(format(v))
})

test_that("a battery prints its own stem, not its group_var", {
  expect_snapshot(print(sports_battery()))
})

test_that("a battery prints (none) for missing question text", {
  expect_snapshot(print(sports_battery(question_text = NA_character_)))
})
