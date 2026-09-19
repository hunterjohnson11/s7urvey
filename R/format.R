# Shared Print Formatting -----------------------------------------------------

nbsp <- intToUtf8(160L)

## Inline Styles --------------------------------------------------------------

fmt_object_name <- function(x) {
  cli::style_bold(cli::make_ansi_style("green4")(x))
}

fmt_collection <- function(x) {
  cli::style_bold(cli::make_ansi_style("orange")(x))
}

fmt_level <- function(x) {
  cli::make_ansi_style("cyan3")(x)
}

fmt_annotation <- function(x) {
  cli::make_ansi_style("grey")(x)
}

## Fields ---------------------------------------------------------------------

fmt_field <- function(label, width) {
  paste0(
    fmt_collection(paste0(label, ":")),
    strrep(nbsp, max(0L, width - nchar(label) - 1L))
  )
}

cli_field_block <- function(width) {
  cli::cli_div(
    theme = list(div = list("margin-left" = 2, "text-exdent" = width + 1L)),
    .auto_close = FALSE
  )
}

cli_question_line <- function(question_text, width) {
  if (length(question_text) == 1 && !is.na(question_text)) {
    cli::cli_text("{fmt_field('Question', width)} {fmt_level(question_text)}")
  } else {
    cli::cli_text("{fmt_field('Question', width)} {fmt_annotation('(none)')}")
  }
}
## Sections -------------------------------------------------------------------

truncate_items <- function(items, n) {
  total <- length(items)
  if (!is.finite(n) || n >= total) {
    return(list(shown = items, more = 0L))
  }
  n <- max(0L, as.integer(n))
  list(shown = items[seq_len(n)], more = total - n)
}

cli_truncation_note <- function(more) {
  if (more == 0) {
    return(invisible())
  }
  note <- sprintf("... and %d more (use print(x, n = Inf) to see all)", more)
  cli::cli_div(theme = list(div = list("margin-left" = 2)), .auto_close = FALSE)
  cli::cli_text("{fmt_annotation(note)}")
  cli::cli_end()
}

cli_named_list_section <- function(header, items, n) {
  if (length(items) == 0) {
    return(invisible())
  }
  width <- max(nchar(names(items))) + 1L
  tr <- truncate_items(items, n)
  cli_field_block(width)
  cli::cli_text("{fmt_collection(header)}")
  for (code in names(tr$shown)) {
    value <- unlist(tr$shown[[code]])
    cli::cli_text("{fmt_field(code, width)} {fmt_level(value)}")
  }
  cli_truncation_note(tr$more)
  cli::cli_end()
}
