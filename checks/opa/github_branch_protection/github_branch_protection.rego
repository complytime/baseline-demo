package github_branch_protection

import data.lib
import rego.v1


# METADATA
# title: Branch Protection Rules Present
# description: >-
#   Confirms that branch protection rules are present in the input.
# custom:
#   short_name: rules_present
#   failure_msg: No branch protection rules found in the input.
#   solution: >-
#     Configure at least one branch protection rule for the primary branch.
#   collections:
#   - osps
deny contains result if {
    # Check if the overall rules array exists
    not input.values
    result := lib.result_helper(rego.metadata.chain(), [])
}


# METADATA
# title: Pull Request Rule Required
# description: >-
#   Confirms that a branch protection rule of type 'pull_request' is present.
#   This is a prerequisite for checking approval counts.
# custom:
#   short_name: pull_request_rule_required
#   failure_msg: A branch protection rule of type 'pull_request' is required for the primary branch but was not found.
#   solution: >-
#     Add a branch protection rule with type 'pull_request' to your branch protection settings.
#   collections:
#   - osps
#   - branch_protections
#   depends_on:
#   - github_branch_protection.rules_present
deny contains result if {
    not _has_pull_request_rule
    result := lib.result_helper(rego.metadata.chain(), [])
}


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
#   - branch_protections
#   depends_on:
#   - github_branch_protection.rules_present
#   - github_branch_protection.pull_request_rule_required
deny contains result if {
    required_count := lib.rule_data("main_branch_min_approvals")
    some rule in input.values
    rule.type == "pull_request"
    rule.parameters.required_approving_review_count < required_count

    result := lib.result_helper(rego.metadata.chain(), [required_count])
}

_has_pull_request_rule if {
    some rule in input.values
    rule.type == "pull_request"
}