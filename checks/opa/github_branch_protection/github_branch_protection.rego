package github_branch_protection

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
# title: Branch-Protection Check Present
# description: >-
#   Confirms that the Branch-Protection check is present in the scorecard report.
# custom:
#   short_name: branch_protection_check_present
#   failure_msg: The Branch-Protection check was not found in the scorecard report.
#   solution: >-
#     Ensure that the scorecard report includes the Branch-Protection check.
#   collections:
#   - osps
#   depends_on:
#   - github_branch_protection.scorecard_data_present
deny contains result if {
    not _has_branch_protection_check
    result := lib.result_helper(rego.metadata.chain(), [])
}


# METADATA
# title: Branch-Protection Score Threshold
# description: >-
#   Verifies that the Branch-Protection check score meets or exceeds the configured minimum threshold.
# custom:
#   short_name: branch_protection_score_threshold
#   failure_msg: Branch-Protection check score (%v) is below the required minimum threshold of %v.
#   solution: >-
#     Improve branch protection settings to meet the minimum score threshold. Review the scorecard details for specific recommendations.
#   collections:
#   - osps
#   depends_on:
#   - github_branch_protection.scorecard_data_present
#   - github_branch_protection.branch_protection_check_present
deny contains result if {
    min_score_str := lib.rule_data("min_branch_protection_score")
    min_score := to_number(min_score_str)
    some check in input.checks
    check.name == "Branch-Protection"
    check.score  # Ensure score field exists
    check.score < min_score

    result := lib.result_helper(rego.metadata.chain(), [check.score, min_score])
}


# Helper rule to check if branch protection check exists
_has_branch_protection_check if {
    some check in input.checks
    check.name == "Branch-Protection"
}
