## Construction ----------------------------------------------------------------

test_that("survey_var stores fields and fills in defaults", {
  v <- survey_var(
    stem = "M_SPORTS",
    cols = c("M_SPORTS_1", "M_SPORTS_2"),
    type = "multi",
    question_text = "Which of the following sports do you play?",
    response_options = list(M_SPORTS_1 = "Basketball", M_SPORTS_2 = "Soccer")
  )

  expect_equal(v@stem, "M_SPORTS")
  expect_equal(v@cols, c("M_SPORTS_1", "M_SPORTS_2"))
  expect_equal(v@type, "multi")
  expect_equal(v@question_text, "Which of the following sports do you play?")
  expect_equal(
    v@response_options,
    list(M_SPORTS_1 = "Basketball", M_SPORTS_2 = "Soccer")
  )
})

test_that("survey_var can be built incrementally, with defaults for unset fields", {
  v <- survey_var(stem = "M_SPORTS", cols = "M_SPORTS_1", type = "multi")

  expect_true(is.na(v@question_text))
  expect_equal(v@response_options, list())
})

test_that("a multi-select may be backed by a single column", {
  expect_no_error(
    survey_var(stem = "M_SPORTS", cols = "M_SPORTS_1", type = "multi")
  )
})

## Validation ------------------------------------------------------------------

test_that("survey_var rejects an empty or missing stem", {
  expect_snapshot(
    error = TRUE,
    survey_var(stem = character(0), cols = "S_GENDER", type = "single")
  )
  expect_snapshot(
    error = TRUE,
    survey_var(stem = NA_character_, cols = "S_GENDER", type = "single")
  )
  expect_snapshot(
    error = TRUE,
    survey_var(stem = "", cols = "S_GENDER", type = "single")
  )
})

test_that("survey_var rejects unusable cols", {
  expect_snapshot(
    error = TRUE,
    survey_var(stem = "S_GENDER", cols = character(0), type = "single")
  )
  expect_snapshot(
    error = TRUE,
    survey_var(stem = "M_SPORTS", cols = c("M_SPORTS_1", NA), type = "multi")
  )
  expect_snapshot(
    error = TRUE,
    survey_var(stem = "M_SPORTS", cols = c("M_SPORTS_1", ""), type = "multi")
  )
  expect_snapshot(
    error = TRUE,
    survey_var(
      stem = "M_SPORTS",
      cols = c("M_SPORTS_1", "M_SPORTS_1"),
      type = "multi"
    )
  )
})

test_that("survey_var rejects an invalid type", {
  expect_snapshot(
    error = TRUE,
    survey_var(stem = "S_GENDER", cols = "S_GENDER", type = "not_a_type")
  )
  expect_snapshot(
    error = TRUE,
    survey_var(stem = "S_GENDER", cols = "S_GENDER", type = "matrix")
  )
})

test_that("single and open_end require exactly one column", {
  expect_snapshot(
    error = TRUE,
    survey_var(stem = "S_GENDER", cols = c("A", "B"), type = "single")
  )
  expect_snapshot(
    error = TRUE,
    survey_var(stem = "comments_oe", cols = c("A", "B"), type = "open_end")
  )
})

test_that("a multi's response option names must be columns", {
  expect_snapshot(
    error = TRUE,
    survey_var(
      stem = "M_SPORTS",
      cols = c("M_SPORTS_1", "M_SPORTS_2"),
      type = "multi",
      response_options = list(M_SPORTS_1 = "Basketball", nope = "Soccer")
    )
  )
})

## Printing --------------------------------------------------------------------

test_that("survey_var prints with question text and response options", {
  v <- survey_var(
    stem = "S_GENDER",
    cols = "S_GENDER",
    type = "single",
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
  v <- survey_var(
    stem = "M_SPORTS",
    cols = paste0("M_SPORTS_", 1:4),
    type = "multi",
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

test_that("survey_var prints (none) for missing question text", {
  v <- survey_var(stem = "M_SPORTS", cols = "M_SPORTS_1", type = "multi")

  expect_snapshot(print(v))
})

test_that("print truncates long option lists, and n = Inf shows all", {
  v <- survey_var(
    stem = "M_BRANDS",
    cols = paste0("M_BRANDS_", 1:8),
    type = "multi",
    response_options = setNames(
      as.list(paste("Brand", LETTERS[1:8])),
      paste0("M_BRANDS_", 1:8)
    )
  )

  expect_snapshot(print(v))
  expect_snapshot(print(v, n = Inf))
})

test_that("format() returns the printed lines without printing", {
  v <- survey_var(stem = "S_GENDER", cols = "S_GENDER", type = "single")

  expect_type(format(v), "character")
  expect_silent(format(v))
})
