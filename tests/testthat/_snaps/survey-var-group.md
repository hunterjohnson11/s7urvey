# survey_var_group rejects an empty or missing stem

    Code
      sports_group(stem = "")
    Condition
      Error:
      ! <s7urvey::survey_var_group> object is invalid:
      - @stem must be a single non-empty string

---

    Code
      sports_group(stem = NA_character_)
    Condition
      Error:
      ! <s7urvey::survey_var_group> object is invalid:
      - @stem must be a single non-empty string

# survey_var_group rejects an empty or missing group_var

    Code
      sports_group(group_var = "")
    Condition
      Error:
      ! <s7urvey::survey_var_group> object is invalid:
      - @group_var must be a single non-empty string

# survey_var_group rejects empty or duplicated group_options

    Code
      sports_group(group_options = character(0))
    Condition
      Error:
      ! <s7urvey::survey_var_group> object is invalid:
      - @group_options must contain at least one value

---

    Code
      sports_group(group_options = c("Basketball", "Basketball"), members = list(
        Basketball = single_member("S_SPORTS_FREQ_1"), Soccer = single_member(
          "S_SPORTS_FREQ_2")))
    Condition
      Error:
      ! <s7urvey::survey_var_group> object is invalid:
      - @group_options must not contain duplicates

# survey_var_group requires members to match group_options

    Code
      sports_group(members = list(Basketball = single_member("S_SPORTS_FREQ_1"),
      Tennis = single_member("S_SPORTS_FREQ_2")))
    Condition
      Error:
      ! <s7urvey::survey_var_group> object is invalid:
      - names(@members) must match @group_options exactly

# survey_var_group rejects non-survey_var members

    Code
      sports_group(members = list(Basketball = single_member("S_SPORTS_FREQ_1"),
      Soccer = "nope"))
    Condition
      Error:
      ! <s7urvey::survey_var_group> object is invalid:
      - @members must all be survey_var objects

# survey_var_group rejects members of mixed type

    Code
      sports_group(members = list(Basketball = single_member("S_SPORTS_FREQ_1"),
      Soccer = survey_var(stem = "S_SPORTS_FREQ_2", cols = "S_SPORTS_FREQ_2", type = "multi")))
    Condition
      Error:
      ! <s7urvey::survey_var_group> object is invalid:
      - all @members must share the same @type

# survey_var_group prints its own stem, not its group_var

    Code
      print(sports_group())
    Output
      <survey_var_group> S_SPORTS_FREQ
        Question:  How often do you play each of the following sports?
        Group Var: sport
        Type:      Single-Select
        Members:   2
        Group Options:
        1: Basketball
        2: Soccer

# survey_var_group prints (none) for missing question text

    Code
      print(sports_group(question_text = NA_character_))
    Output
      <survey_var_group> S_SPORTS_FREQ
        Question:  (none)
        Group Var: sport
        Type:      Single-Select
        Members:   2
        Group Options:
        1: Basketball
        2: Soccer

