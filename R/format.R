# Shared Print-Method Styling Helpers ----------------------------------------

# Shared inline styling for print methods: colors mark *categories* (class tag, object name, field label) rather than specific types/values, so the same functions are reused across every class's print method and the eye only has a few colors to learn.

# The "<survey_var>" class tag -- cli's built-in .cls styling (adds the
# angle brackets and colors them per the active theme).
fmt_tag <- function(x) cli::format_inline("{.cls {x}}")

# The object's own name/identity (a stem): bold green.
fmt_object_name <- function(x) {
  cli::style_bold(cli::make_ansi_style("green4")(x))
}

# A field/category label (Type, Columns, Question, Subquestions, Response Options): bold orange.
fmt_collection <- function(x) cli::style_bold(cli::make_ansi_style("orange")(x))

# A field's value (the thing next to a label): cyan.
fmt_level <- function(x) cli::make_ansi_style("cyan3")(x)

# A dim annotation, e.g. a missing value or a truncation note.
fmt_annotation <- function(x) cli::make_ansi_style("grey")(x)

# Console width to wrap long text fields to, so a wrapped question doesn't
# run into the next section. Falls back to 80 outside an interactive console.
print_width <- function() {
  tryCatch(cli::console_width(), error = function(e) 80L)
}

# Wraps `value` to fit the console, right of a left-aligned "label:" of width `label_w`, with continuation lines hanging under the value (not the label) Width is computed on the plain text so ANSI color codes (added afterward) don't throw off wrapping or alignment.
wrap_field <- function(
  label,
  value,
  label_w,
  indent = "  ",
  value_fmt = fmt_level
) {
  plain_label <- formatC(paste0(label, ":"), width = -label_w)
  plain_prefix <- paste0(indent, plain_label, " ")
  cont_indent <- strrep(" ", nchar(plain_prefix))
  avail <- max(20, print_width() - nchar(plain_prefix))
  body <- strwrap(as.character(value), width = avail)
  if (length(body) == 0) {
    body <- ""
  }

  colored_prefix <- paste0(indent, fmt_collection(plain_label), " ")
  c(
    paste0(colored_prefix, value_fmt(body[1])),
    if (length(body) > 1) paste0(cont_indent, value_fmt(body[-1]))
  )
}

# Keeps only the first `n` elements of a (possibly named) list/vector, so a 20-item multi-select doesn't dominate the console by default. `n = Inf` (passed through from `print(x, n = Inf)`) shows everything.
truncate_items <- function(items, n) {
  total <- length(items)
  if (!is.finite(n) || n >= total) {
    return(list(shown = items, more = 0L))
  }
  n <- max(0L, as.integer(n))
  list(shown = items[seq_len(n)], more = total - n)
}

# A dim note appended after a truncated list, telling the user how to see the rest.
truncation_note <- function(more, indent) {
  paste0(
    indent,
    "    ",
    fmt_annotation(sprintf(
      "... and %d more (use print(x, n = Inf) to see all)",
      more
    ))
  )
}
