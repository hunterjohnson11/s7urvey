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

# survey_var rejects unusable cols

    Code
      survey_var(stem = "S_GENDER", cols = character(0), type = "single")
    Condition
      Error:
      ! <s7urvey::survey_var> object is invalid:
      - @cols must contain at least one column name

---

    Code
      survey_var(stem = "M_SPORTS", cols = c("M_SPORTS_1", NA), type = "multi")
    Condition
      Error:
      ! <s7urvey::survey_var> object is invalid:
      - @cols must not contain NA or empty strings

---

    Code
      survey_var(stem = "M_SPORTS", cols = c("M_SPORTS_1", ""), type = "multi")
    Condition
      Error:
      ! <s7urvey::survey_var> object is invalid:
      - @cols must not contain NA or empty strings

---

    Code
      survey_var(stem = "M_SPORTS", cols = c("M_SPORTS_1", "M_SPORTS_1"), type = "multi")
    Condition
      Error:
      ! <s7urvey::survey_var> object is invalid:
      - @cols must not contain duplicates

# survey_var rejects an invalid type

    Code
      survey_var(stem = "S_GENDER", cols = "S_GENDER", type = "not_a_type")
    Condition
      Error:
      ! <s7urvey::survey_var> object is invalid:
      - @type must be one of single, multi, open_end, other

---

    Code
      survey_var(stem = "S_GENDER", cols = "S_GENDER", type = "matrix")
    Condition
      Error:
      ! <s7urvey::survey_var> object is invalid:
      - @type must be one of single, multi, open_end, other

# single and open_end require exactly one column

    Code
      survey_var(stem = "S_GENDER", cols = c("A", "B"), type = "single")
    Condition
      Error:
      ! <s7urvey::survey_var> object is invalid:
      - @type = "single" requires exactly one column in @cols

---

    Code
      survey_var(stem = "comments_oe", cols = c("A", "B"), type = "open_end")
    Condition
      Error:
      ! <s7urvey::survey_var> object is invalid:
      - @type = "open_end" requires exactly one column in @cols

# a multi's response option names must be columns

    Code
      survey_var(stem = "M_SPORTS", cols = c("M_SPORTS_1", "M_SPORTS_2"), type = "multi",
      response_options = list(M_SPORTS_1 = "Basketball", nope = "Soccer"))
    Condition
      Error:
      ! <s7urvey::survey_var> object is invalid:
      - names(@response_options) must all be entries in @cols when @type = "multi"

# survey_var prints with question text and response options

    Code
      print(v)
    Output
      <survey_var> S_GENDER
        Type:     Single-Select
        Columns:  1
        Question: What is your gender?
        Response Options:
        1: Male
        2: Female
        3: Prefer not to say

# a multi-select prints its options keyed by column

    Code
      print(v)
    Output
      <survey_var> M_SPORTS
        Type:     Multi-Select
        Columns:  4
        Question: Which of the following sports do you play?
        Response Options:
        M_SPORTS_1: Basketball
        M_SPORTS_2: Soccer
        M_SPORTS_3: Tennis
        M_SPORTS_4: Swimming

# survey_var prints (none) for missing question text

    Code
      print(v)
    Output
      <survey_var> M_SPORTS
        Type:     Multi-Select
        Columns:  1
        Question: (none)

# print truncates long option lists, and n = Inf shows all

    Code
      print(v)
    Output
      <survey_var> M_BRANDS
        Type:     Multi-Select
        Columns:  8
        Question: (none)
        Response Options:
        M_BRANDS_1: Brand A
        M_BRANDS_2: Brand B
        M_BRANDS_3: Brand C
        M_BRANDS_4: Brand D
        M_BRANDS_5: Brand E
          ... and 3 more (use print(x, n = Inf) to see all)

---

    Code
      print(v, n = Inf)
    Output
      <survey_var> M_BRANDS
        Type:     Multi-Select
        Columns:  8
        Question: (none)
        Response Options:
        M_BRANDS_1: Brand A
        M_BRANDS_2: Brand B
        M_BRANDS_3: Brand C
        M_BRANDS_4: Brand D
        M_BRANDS_5: Brand E
        M_BRANDS_6: Brand F
        M_BRANDS_7: Brand G
        M_BRANDS_8: Brand H

