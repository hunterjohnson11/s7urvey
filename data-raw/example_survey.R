# Builds `example_survey`, a small, entirely synthetic dataset shipped with
# the package so examples/tests/vignettes never need to reference real
# (confidential) survey questions or data.
#
# Columns are plain numeric/character vectors carrying the same "label" +
# "labels" attributes haven::read_sav() would attach (variable label and
# value-label map, respectively) -- without depending on {haven} at
# runtime, since survey_var only ever reads those two attributes directly
# (see `attr(x, "labels")` in the reference parsing script).
#
# Variable labels follow the "VARNAME: subtext - question text" / "VARNAME:
# question text" conventions real survey exports use, so this dataset can
# double as a fixture for future auto-detection/parsing work.

library(tibble)

set.seed(8342)

n <- 40

# Adds a "label" (variable label) and "labels" (named value -> code vector,
# haven's convention) attribute to a vector without requiring {haven}.
labelled_vec <- function(x, label, value_labels = NULL) {
  attr(x, "label") <- label
  if (!is.null(value_labels)) {
    attr(x, "labels") <- value_labels
  }
  x
}

resp_id <- seq_len(n)

# Single-select demographic
gender_labels <- c(Male = 1, Female = 2, `Prefer not to say` = 3)
S_GENDER <- labelled_vec(
  sample(unname(gender_labels), n, replace = TRUE, prob = c(0.45, 0.45, 0.1)),
  label = "S_GENDER: What is your gender?",
  value_labels = gender_labels
)

age_labels <- c(
  `Under 25` = 1,
  `25-34` = 2,
  `35-44` = 3,
  `45-54` = 4,
  `55+` = 5
)
S_AGE <- labelled_vec(
  sample(unname(age_labels), n, replace = TRUE),
  label = "S_AGE: Which age group are you in?",
  value_labels = age_labels
)

# Multi-select: one yes/no dummy column per sport, each carrying its own
# (identical) yes/no value-label pair, per the multi-select convention.
sports <- c("Basketball", "Soccer", "Tennis", "Swimming")
yes_no <- c(No = 0, Yes = 1)
sport_probs <- c(0.4, 0.5, 0.25, 0.3)
sport_cols <- lapply(seq_along(sports), function(i) {
  labelled_vec(
    rbinom(n, 1, sport_probs[i]),
    label = sprintf(
      "M_SPORTS_%d: %s - Which of the following sports do you play?",
      i,
      sports[i]
    ),
    value_labels = yes_no
  )
})
names(sport_cols) <- paste0("M_SPORTS_", seq_along(sports))

# Matrix: shared frequency scale, one row per activity.
freq_labels <- c(Never = 1, Rarely = 2, Sometimes = 3, Often = 4)
freq_cols <- lapply(seq_along(sports[1:3]), function(i) {
  labelled_vec(
    sample(unname(freq_labels), n, replace = TRUE),
    label = sprintf(
      "S_SPORTS_FREQ_%d: %s - How often do you play each of the following sports?",
      i,
      sports[i]
    ),
    value_labels = freq_labels
  )
})
names(freq_cols) <- paste0("S_SPORTS_FREQ_", seq_along(sports[1:3]))

# Open-end
comment_bank <- c(
  "I wish there were more local leagues.",
  "I mostly play for fun with friends.",
  "Injuries have kept me from playing as much lately.",
  NA_character_
)
comments_oe <- labelled_vec(
  sample(comment_bank, n, replace = TRUE, prob = c(0.25, 0.35, 0.15, 0.25)),
  label = "comments_oe: Any other comments about your sports habits?"
)

example_survey <- tibble(
  resp_id = resp_id,
  S_GENDER = S_GENDER,
  S_AGE = S_AGE,
  !!!sport_cols,
  !!!freq_cols,
  comments_oe = comments_oe
)

usethis::use_data(example_survey, overwrite = TRUE)
