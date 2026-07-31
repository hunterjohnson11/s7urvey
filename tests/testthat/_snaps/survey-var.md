# survey_var rejects an empty or missing stem

    Code
      survey_var(stem = character(0), cols = "S_GENDER", type = "single")
    Condition
      Error:
      ! <s7urvey::survey_var> object is invalid:
      - @stem must be a single non-empty string

---

    Code
      survey_var(stem = NA_character_, cols = "S_GENDER", type = "single")
    Condition
      Error:
      ! <s7urvey::survey_var> object is invalid:
      - @stem must be a single non-empty string

---

    Code
      survey_var(stem = "", cols = "S_GENDER", type = "single")
    Condition
      Error:
      ! <s7urvey::survey_var> object is invalid:
      - @stem must be a single non-empty string

# survey_var rejects empty cols

    Code
      survey_var(stem = "S_GENDER", cols = character(0), type = "single")
    Condition
      Error:
      ! <s7urvey::survey_var> object is invalid:
      - @cols must contain at least one column name

# survey_var rejects an invalid type

    Code
      survey_var(stem = "S_GENDER", cols = "S_GENDER", type = "not_a_type")
    Condition
      Error:
      ! <s7urvey::survey_var> object is invalid:
      - @type must be one of single, multi, matrix, open_end, other

# survey_var prints with question text, subquestions, and response options

    Code
      print(v)
    Output
      <survey_var> S_MEDIA_FREQ
        Type:    Matrix
        Columns: 2
        Question: How frequently do you access each platform?
        Subquestions:
        1: Facebook
        2: Instagram
        Response Options:
        1: Never
        2: Rarely
        3: Often

# survey_var prints (none) for missing question text

    Code
      print(v)
    Output
      <survey_var> M_SPORTS
        Type:    Multi-Select
        Columns: 1
        Question: (none)

