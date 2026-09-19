# s7urvey 0.1.0

First development release. The API is experimental and will change without deprecation warnings.

- `survey_var()` represents a single survey question — one answer from the respondent — across one or more columns. Types are `single`, `multi`, `open_end`, and `other`.

- `survey_var_group()` represents a question answered separately once per level of some dimension. This covers both matrix questions and looped questions.

- Both classes validate their structure on construction and print a readable summary. All descriptive metadata is optional, so a question can be classified from its structure alone.