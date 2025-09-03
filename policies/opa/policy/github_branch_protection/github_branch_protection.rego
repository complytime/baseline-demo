package github_branch_protection
# Assisted by: Gemini 2.5 Flash

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
#
deny contains result if {
    # Check if a pull request rule exists and meets the minimum approvals
    not _pull_request_rule_meets_min_approvals

    # Construct the result directly
    required_count := data.min_approvals
    result := {
        "metadata": {
            "title": "Minimum Approvals for Main Branch",
            "description": "Verifies that the branch protection rule for the 'main' branch has at least the configured minimum number of required approving reviews.",
            "severity": "high",
            "short_name": "min_approvals_check",
        },
        "msg": sprintf("Branch protection for 'main' requires pull request reviews but has less than the configured minimum of %v required approving reviews.", [required_count]),
        "solution": "Increase the 'required_approving_review_count' in the branch protection settings to meet or exceed the policy's minimum.",
    }
}

#
# METADATA
# title: Pull Request Rule Exists
# description: >-
#   Confirms that a 'pull_request' rule is defined in the branch protection settings.
# custom:
#   short_name: pull_request_rule_exists
#   failure_msg: No 'pull_request' rule found for the main branch.
#   solution: >-
#     Add a 'Pull Request' rule to the branch protection settings for the 'main' branch.
#
deny contains result if {
    # Check if the overall rules array exists
    input.values.rules
    # Check if a pull_request rule exists
    not _has_pull_request_rule

    # Construct the result directly
    result := {
        "metadata": {
            "title": "Pull Request Rule Exists",
            "description": "Confirms that a 'pull_request' rule is defined in the branch protection settings.",
            "severity": "high",
            "short_name": "pull_request_rule_exists",
        },
        "msg": "No 'pull_request' rule found for the main branch.",
        "solution": "Add a 'Pull Request' rule to the branch protection settings for the 'main' branch.",
    }
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
#
deny contains result if {
    # Check if the overall rules array exists
    not input.values.rules

    # Construct the result directly
    result := {
        "metadata": {
            "title": "Branch Protection Rules Present",
            "description": "Confirms that branch protection rules are present in the input.",
            "severity": "high",
            "short_name": "rules_present",
        },
        "msg": "No branch protection rules found in the input.",
        "solution": "Configure at least one branch protection rule for the 'main' branch.",
    }
}

# Helper rule to check if a pull_request rule exists
_has_pull_request_rule if {
    some i
    input.values.rules[i].type == "pull_request"
}

# Helper rule to check if a pull_request rule meets the minimum approval requirement
_pull_request_rule_meets_min_approvals if {
    some i
    rule = input.values.rules[i]
    rule.type == "pull_request"
    required_count := data.min_approvals
    rule.parameters.required_approving_review_count >= required_count
}
