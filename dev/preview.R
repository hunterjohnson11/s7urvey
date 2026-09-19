devtools::load_all()

cli::cli_h1("Colour support")
cli::cli_inform(c(
  "*" = "ANSI colours detected: {.val {cli::num_ansi_colors()}}",
  "*" = "Console width: {.val {cli::console_width()}}",
  "i" = "If colours show as {.val 1}, run this in the Positron console, not via Rscript."
))

cli::cli_h1("Palette swatch")
cat(
  paste0(
    "  ",
    cli::format_inline("{.cls survey_var}"),
    "        {.cls} inline      class tag"
  ),
  paste0(
    "  ",
    fmt_object_name("M_SPORTS"),
    "            fmt_object_name()  stem / identity"
  ),
  paste0(
    "  ",
    fmt_collection("Response Options:"),
    "   fmt_collection()   field + section labels"
  ),
  paste0("  ", fmt_level("Basketball"), "          fmt_level()        values"),
  paste0(
    "  ",
    fmt_annotation("(none)"),
    "              fmt_annotation()   missing + truncation"
  ),
  sep = "\n"
)

cli::cli_h1("Single-select")
single <- survey_var(
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
print(single)

cli::cli_h1("Multi-select")
multi <- survey_var(
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
print(multi)

cli::cli_h1("Matrix (group of single-selects)")
freq <- list(`1` = "Never", `2` = "Rarely", `3` = "Sometimes", `4` = "Often")
items <- c("Basketball", "Soccer", "Tennis")
matrix_group <- survey_var_group(
  stem = "S_SPORTS_FREQ",
  group_var = "sport",
  group_options = items,
  question_text = "How often do you play each of the following sports?",
  members = setNames(
    lapply(seq_along(items), function(i) {
      survey_var(
        stem = paste0("S_SPORTS_FREQ_", i),
        cols = paste0("S_SPORTS_FREQ_", i),
        type = "single",
        question_text = paste0("How often do you play ", items[i], "?"),
        response_options = freq
      )
    }),
    items
  )
)
print(matrix_group)

cli::cli_h1("Open-end")
print(survey_var(
  stem = "comments_oe",
  cols = "comments_oe",
  type = "open_end",
  question_text = "Any other comments about your sports habits?"
))

cli::cli_h1("Bare object (grey annotation)")
print(survey_var(
  stem = "M_SPORTS",
  cols = paste0("M_SPORTS_", 1:4),
  type = "multi"
))

cli::cli_h1("Truncation (grey note)")
brands <- survey_var(
  stem = "M_BRANDS",
  cols = paste0("M_BRANDS_", 1:12),
  type = "multi",
  question_text = "Which of these brands have you purchased in the last six months?",
  response_options = setNames(
    as.list(paste("Brand", LETTERS[1:12])),
    paste0("M_BRANDS_", 1:12)
  )
)
print(brands)

cli::cli_h1("Same object, n = Inf")
print(brands, n = Inf)

cli::cli_h1("Long question text (wrap + hanging indent)")
print(survey_var(
  stem = "S_LONG",
  cols = "S_LONG",
  type = "single",
  question_text = paste(
    "Thinking about the past twelve months and everything you have done",
    "in your free time, how often would you say you took part in organised",
    "sporting activity of any kind, either as a player or as a spectator?"
  ),
  response_options = freq
))

cli::cli_h1("Looped question (group of multi-selects)")
print(survey_var_group(
  stem = "M_INTERESTED",
  group_var = "device",
  group_options = c("iPhone", "Android"),
  question_text = "Which features interest you?",
  members = list(
    iPhone = survey_var(
      stem = "M_INTERESTED_IPHONE",
      cols = paste0("M_INTERESTED_IPHONE_", 1:2),
      type = "multi",
      response_options = list(
        M_INTERESTED_IPHONE_1 = "Camera",
        M_INTERESTED_IPHONE_2 = "Battery life"
      )
    ),
    Android = survey_var(
      stem = "M_INTERESTED_ANDROID",
      cols = paste0("M_INTERESTED_ANDROID_", 1:2),
      type = "multi",
      response_options = list(
        M_INTERESTED_ANDROID_1 = "Camera",
        M_INTERESTED_ANDROID_2 = "Battery life"
      )
    )
  )
))

cli::cli_h1("Edit colours in R/format.R")
cli::cli_bullets(c(
  "*" = "{.fn fmt_object_name} stem, currently {.val green4} bold",
  "*" = "{.fn fmt_collection} field labels, currently {.val orange} bold",
  "*" = "{.fn fmt_level} values, currently {.val cyan3}",
  "*" = "{.fn fmt_annotation} missing and truncation, currently {.val grey}",
  "i" = "Any name from {.run grDevices::colours()} or a hex string works.",
  "i" = "Change one, then re-run {.run devtools::load_all()} and this file."
))
