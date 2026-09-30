# a question rejects an empty or missing stem

    Code
      single_select(stem = character(0), cols = "S_GENDER")
    Condition
      Error:
      ! <s7urvey::single_select> object is invalid:
      - @stem must be a single non-empty string

---

    Code
      single_select(stem = NA_character_, cols = "S_GENDER")
    Condition
      Error:
      ! <s7urvey::single_select> object is invalid:
      - @stem must be a single non-empty string

---

    Code
      single_select(stem = "", cols = "S_GENDER")
    Condition
      Error:
      ! <s7urvey::single_select> object is invalid:
      - @stem must be a single non-empty string

---

    Code
      sports_battery(stem = "")
    Condition
      Error:
      ! <s7urvey::battery> object is invalid:
      - @stem must be a single non-empty string

# a question rejects unusable cols

    Code
      single_select(stem = "S_GENDER", cols = character(0))
    Condition
      Error:
      ! <s7urvey::single_select> object properties are invalid:
      - @cols must be a single column name

---

    Code
      multi_select(stem = "M_SPORTS", cols = character(0))
    Condition
      Error:
      ! <s7urvey::multi_select> object properties are invalid:
      - @cols must contain at least one column name

---

    Code
      multi_select(stem = "M_SPORTS", cols = c("M_SPORTS_1", NA))
    Condition
      Error:
      ! <s7urvey::multi_select> object properties are invalid:
      - @cols must not contain NA or empty strings

---

    Code
      multi_select(stem = "M_SPORTS", cols = c("M_SPORTS_1", ""))
    Condition
      Error:
      ! <s7urvey::multi_select> object properties are invalid:
      - @cols must not contain NA or empty strings

---

    Code
      multi_select(stem = "M_SPORTS", cols = c("M_SPORTS_1", "M_SPORTS_1"))
    Condition
      Error:
      ! <s7urvey::multi_select> object properties are invalid:
      - @cols must not contain duplicates

# single-selects and open-ends take exactly one column

    Code
      single_select(stem = "S_GENDER", cols = c("A", "B"))
    Condition
      Error:
      ! <s7urvey::single_select> object properties are invalid:
      - @cols must be a single column name

---

    Code
      open_end(stem = "comments_oe", cols = c("A", "B"))
    Condition
      Error:
      ! <s7urvey::open_end> object properties are invalid:
      - @cols must be a single column name

# a multi's response option names must be columns

    Code
      multi_select(stem = "M_SPORTS", cols = c("M_SPORTS_1", "M_SPORTS_2"),
      response_options = list(M_SPORTS_1 = "Basketball", nope = "Soccer"))
    Condition
      Error:
      ! <s7urvey::multi_select> object is invalid:
      - names(@response_options) must all be entries in @cols

# a battery rejects an empty or missing group_var

    Code
      sports_battery(group_var = "")
    Condition
      Error:
      ! <s7urvey::battery> object is invalid:
      - @group_var must be a single non-empty string

# a battery rejects empty or duplicated group_options

    Code
      sports_battery(group_options = character(0))
    Condition
      Error:
      ! <s7urvey::battery> object is invalid:
      - @group_options must contain at least one value

---

    Code
      sports_battery(group_options = c("Basketball", "Basketball"), members = list(
        Basketball = freq_member("S_SPORTS_FREQ_1"), Soccer = freq_member(
          "S_SPORTS_FREQ_2")))
    Condition
      Error:
      ! <s7urvey::battery> object is invalid:
      - @group_options must not contain duplicates

# a battery requires members to match group_options

    Code
      sports_battery(members = list(Basketball = freq_member("S_SPORTS_FREQ_1"),
      Tennis = freq_member("S_SPORTS_FREQ_2")))
    Condition
      Error:
      ! <s7urvey::battery> object is invalid:
      - names(@members) must match @group_options exactly

# a battery's members must be questions answered once

    Code
      sports_battery(members = list(Basketball = freq_member("S_SPORTS_FREQ_1"),
      Soccer = "nope"))
    Condition
      Error:
      ! <s7urvey::battery> object is invalid:
      - @members must all be questions answered once, not batteries

---

    Code
      sports_battery(members = list(Basketball = freq_member("S_SPORTS_FREQ_1"),
      Soccer = sports_battery()))
    Condition
      Error:
      ! <s7urvey::battery> object is invalid:
      - @members must all be questions answered once, not batteries

# a battery rejects members of mixed kinds

    Code
      sports_battery(members = list(Basketball = freq_member("S_SPORTS_FREQ_1"),
      Soccer = multi_select(stem = "S_SPORTS_FREQ_2", cols = "S_SPORTS_FREQ_2")))
    Condition
      Error:
      ! <s7urvey::battery> object is invalid:
      - all @members must be the same kind of question

# a single-select prints with question text and response options

    Code
      print(v)
    Output
      <single_select> S_GENDER
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
      <multi_select> M_SPORTS
        Type:     Multi-Select
        Columns:  4
        Question: Which of the following sports do you play?
        Response Options:
        M_SPORTS_1: Basketball
        M_SPORTS_2: Soccer
        M_SPORTS_3: Tennis
        M_SPORTS_4: Swimming

# a question prints (none) for missing question text

    Code
      print(v)
    Output
      <multi_select> M_SPORTS
        Type:     Multi-Select
        Columns:  1
        Question: (none)

# print truncates long option lists, and n = Inf shows all

    Code
      print(v)
    Output
      <multi_select> M_BRANDS
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
      <multi_select> M_BRANDS
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

# a battery prints its own stem, not its group_var

    Code
      print(sports_battery())
    Output
      <battery> S_SPORTS_FREQ
        Question:  How often do you play each of the following sports?
        Group Var: sport
        Type:      Single-Select
        Members:   2
        Group Options:
        1: Basketball
        2: Soccer

# a battery prints (none) for missing question text

    Code
      print(sports_battery(question_text = NA_character_))
    Output
      <battery> S_SPORTS_FREQ
        Question:  (none)
        Group Var: sport
        Type:      Single-Select
        Members:   2
        Group Options:
        1: Basketball
        2: Soccer

