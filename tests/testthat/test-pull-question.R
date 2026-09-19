## Fixtures --------------------------------------------------------------------

gender <- survey_var(
  stem = "S_GENDER",
  cols = "S_GENDER",
  type = "single",
  response_options = list(
    `1` = "Male",
    `2` = "Female",
    `3` = "Prefer not to say"
  )
)

sports <- survey_var(
  stem = "M_SPORTS",
  cols = paste0("M_SPORTS_", 1:4),
  type = "multi",
  response_options = list(
    M_SPORTS_1 = "Basketball",
    M_SPORTS_2 = "Soccer",
    M_SPORTS_3 = "Tennis",
    M_SPORTS_4 = "Swimming"
  )
)

freq <- list(`1` = "Never", `2` = "Rarely", `3` = "Sometimes", `4` = "Often")
items <- c("Basketball", "Soccer", "Tennis")
sports_freq <- survey_var_group(
  stem = "S_SPORTS_FREQ",
  group_var = "sport",
  group_options = items,
  members = stats::setNames(
    lapply(seq_along(items), function(i) {
      survey_var(
        stem = paste0("S_SPORTS_FREQ_", i),
        cols = paste0("S_SPORTS_FREQ_", i),
        type = "single",
        response_options = freq
      )
    }),
    items
  )
)

## Extraction ------------------------------------------------------------------

test_that("a single-select gives one labelled row per respondent", {
  out <- pull_question(example_survey, gender)

  expect_named(out, c(".row", "group", "item", "value"))
  expect_equal(nrow(out), nrow(example_survey))
  expect_s3_class(out$value, "factor")
  expect_equal(levels(out$value), c("Male", "Female", "Prefer not to say"))
  expect_true(all(is.na(out$group)))
})

test_that("a multi-select gives every respondent for every option", {
  out <- pull_question(example_survey, sports)

  expect_equal(nrow(out), nrow(example_survey) * 4)
  expect_length(unique(out$.row), nrow(example_survey))
  expect_setequal(out$item, unlist(sports@response_options, use.names = FALSE))
  expect_type(out$value, "logical")
  expect_equal(
    sum(out$value),
    sum(as.matrix(example_survey[, sports@cols]))
  )
})

test_that("a group stacks its members and keeps the response scale ordered", {
  out <- pull_question(example_survey, sports_freq)

  expect_equal(nrow(out), nrow(example_survey) * 3)
  expect_setequal(out$group, items)
  expect_equal(levels(out$value), unlist(freq, use.names = FALSE))
})

## Validation ------------------------------------------------------------------

test_that("pull_question reports columns the data does not have", {
  absent <- survey_var(stem = "NOPE", cols = "NOPE", type = "single")

  expect_snapshot(error = TRUE, pull_question(example_survey, absent))
})
