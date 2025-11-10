package scorecard_code_review

import data.lib
import rego.v1


# METADATA
# title: Scorecard Data Present
# description: >-
#   Confirms that OpenSSF scorecard data is present in the input.
# custom:
#   short_name: scorecard_data_present
#   failure_msg: No OpenSSF scorecard data found in the input.
#   solution: >-
#     Ensure that a valid OpenSSF scorecard JSON report is provided as input.
#   collections:
#   - osps
deny contains result if {
    not input.checks
    result := lib.result_helper(rego.metadata.chain(), [])
}


# METADATA
# title: Code-Review Check Present
# description: >-
#   Confirms that the Code-Review check is present in the scorecard report.
# custom:
#   short_name: code_review_check_present
#   failure_msg: The Code-Review check was not found in the scorecard report.
#   solution: >-
#     Ensure that the scorecard report includes the Code-Review check.
#   collections:
#   - osps
#   depends_on:
#   - scorecard_code_review.scorecard_data_present
deny contains result if {
    not _has_code_review_check
    result := lib.result_helper(rego.metadata.chain(), [])
}


# METADATA
# title: Code-Review Score Threshold
# description: >-
#   Verifies that the Code-Review check score meets or exceeds the configured minimum threshold.
#   The Code-Review check validates that pull requests are reviewed by someone other than the author.
# custom:
#   short_name: code_review_score_threshold
#   failure_msg: Code-Review check score (%v) is below the required minimum threshold of %v.
#   solution: >-
#     Ensure that pull requests require code review by someone other than the author. Configure branch protection rules to require reviews before merging.
#   collections:
#   - osps
#   depends_on:
#   - scorecard_code_review.scorecard_data_present
#   - scorecard_code_review.code_review_check_present
deny contains result if {
    min_score_str := lib.rule_data("min_code_review_score")
    min_score := to_number(min_score_str)
    some check in input.checks
    check.name == "Code-Review"
    check.score  # Ensure score field exists
    check.score < min_score

    result := lib.result_helper(rego.metadata.chain(), [check.score, min_score])
}

# Helper rule to check if branch protection check exists
_has_code_review_check if {
    some check in input.checks
    check.name == "Code-Review"
}
