package github_branch_protection

import data.lib
import rego.v1

#
# METADATA
# title: Minimum Approvals for Main Branch
# description: >-
#   Verifies that the branch protection rule for the 'main' branch
#   has at least the configured minimum number of required approving reviews.
# custom:
#   short_name: min_approvals_check
#   failure_msg: Branch protection for 'main' requires pull request reviews but has less than the configured minimum of %v required approving reviews.
#   solution: >-
#     Increase the 'required_approving_review_count' in the branch protection settings to meet or exceed the policy's minimum.
#   collections:
#   - osps
#   depends_on:
#   - github_branch_protection.rules_present
#
deny contains result if {
    # Check if a pull request rule exists and meets the minimum approvals
    not _pull_request_rule_meets_min_approvals

    # Construct the result directly
    required_count := data.rule_data__configuration__main_branch_min_approvals
    result := lib.result_helper(rego.metadata.chain(), [required_count])
}

#
# METADATA
# title: Branch Protection Rules Present
# description: >-
#   Confirms that branch protection rules are present in the input.
# custom:
#   short_name: rules_present
#   failure_msg: No branch protection rules found in the input.
#   solution: >-
#     Configure at least one branch protection rule for the 'main' branch.
#   collections:
#   - osps
deny contains result if {
    # Check if the overall rules array exists
    not input.values.rules
    result := lib.result_helper(rego.metadata.chain(), [])
}

# Helper rule to check if a pull_request rule meets the minimum approval requirement
_pull_request_rule_meets_min_approvals if {
    some i
    rule = input.values.rules[i]
    rule.type == "pull_request"
    required_count := data.rule_data__configuration__main_branch_min_approvals
    rule.parameters.required_approving_review_count >= required_count
}