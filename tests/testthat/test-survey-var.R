test_that("survey_var stores fields and fills in defaults", {
  v <- survey_var(
    stem = "M_SPORTS",
    cols = c("M_SPORTS_1", "M_SPORTS_2"),
    type = "multi",
    question_text = "Which of the following sports do you play?",
    subquestion_labels = list(M_SPORTS_1 = "Basketball", M_SPORTS_2 = "Soccer")
  )

  expect_equal(get_stem(v), "M_SPORTS")
  expect_equal(get_cols(v), c("M_SPORTS_1", "M_SPORTS_2"))
  expect_equal(get_type(v), "multi")
  expect_equal(
    get_question_text(v),
    "Which of the following sports do you play?"
  )
  expect_equal(
    get_subquestions(v),
    list(M_SPORTS_1 = "Basketball", M_SPORTS_2 = "Soccer")
  )
  expect_equal(get_response_options(v), list())
})

test_that("survey_var can be built incrementally, with defaults for unset fields", {
  v <- survey_var(stem = "M_SPORTS", cols = "M_SPORTS_1", type = "multi")

  expect_true(is.na(get_question_text(v)))
  expect_equal(get_subquestions(v), list())
  expect_equal(get_response_options(v), list())
})

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

test_that("survey_var rejects empty cols", {
  expect_snapshot(
    error = TRUE,
    survey_var(stem = "S_GENDER", cols = character(0), type = "single")
  )
})

test_that("survey_var rejects an invalid type", {
  expect_snapshot(
    error = TRUE,
    survey_var(stem = "S_GENDER", cols = "S_GENDER", type = "not_a_type")
  )
})

test_that("survey_var prints with question text, subquestions, and response options", {
  v <- survey_var(
    stem = "S_MEDIA_FREQ",
    cols = c("S_MEDIA_FREQ_1", "S_MEDIA_FREQ_2"),
    type = "matrix",
    question_text = "How frequently do you access each platform?",
    subquestion_labels = list(
      S_MEDIA_FREQ_1 = "Facebook",
      S_MEDIA_FREQ_2 = "Instagram"
    ),
    response_options = list(`1` = "Never", `2` = "Rarely", `3` = "Often")
  )

  expect_snapshot(print(v))
})

test_that("survey_var prints (none) for missing question text", {
  v <- survey_var(stem = "M_SPORTS", cols = "M_SPORTS_1", type = "multi")

  expect_snapshot(print(v))
})
