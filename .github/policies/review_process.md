# Review Process

- **Policy ID:** ENG-REVIEW-001
- **Version:** 1.0.0
- **Status:** Active
- **Effective Date:** 2026-10-29
- **Owner:** Homelab-Alpha
- **Applies To:** All repositories using GitHub Actions within the organization

> [!IMPORTANT]
>
> This is a living document and may be adjusted based on feedback and project
> priorities.

This document outlines the review process for pull requests within the
shell-script repository. Its primary goal is to ensure the **quality,
consistency, and functionality** of all contributions before they are merged
into the `main` branch. The process is designed to be collaborative,
transparent, and respectful of everyone's time.

<details>
  <summary>Table of Contents (click to expand)</summary>
  <p>

1. [Review Process](#review-process)
   1. [General Principles](#general-principles)
   2. [Who Reviews](#who-reviews)
   3. [Review Timeline](#review-timeline)
   4. [Review Stages](#review-stages)
      1. [1. Automated Checks](#1-automated-checks)
      2. [2. Human Review](#2-human-review)
      3. [3. Approval and Merge](#3-approval-and-merge)
   5. [Review Criteria](#review-criteria)
      1. [Correctness](#correctness)
      2. [Code Quality](#code-quality)
      3. [Documentation](#documentation)
      4. [Security](#security)
      5. [Tests](#tests)
      6. [Git Hygiene](#git-hygiene)
   6. [Responding to Review Feedback](#responding-to-review-feedback)
   7. [Merge Strategy](#merge-strategy)
   8. [Automated Dependency Updates](#automated-dependency-updates)
   9. [Escalation](#escalation)
   10. [Revision History](#revision-history)

  </p>
</details>

## General Principles

- Reviews are a **collaborative effort**, not a gatekeeping exercise. The goal
  is to improve the contribution, not to reject it.
- Feedback must be **constructive, specific, and respectful**. Reference the
  relevant guideline or standard when requesting a change.
- Contributors are expected to **respond to review comments** in a timely
  manner. Pull requests with no activity for **14 days** after a review request
  may be closed and can be reopened when ready.
- All merged contributions must meet the standards described in
  [code_style_and_standards_guides.md](../docs/code_style_and_standards_guides.md)
  and [CONTRIBUTING.md](../../CONTRIBUTING.md).

## Who Reviews

Code ownership is defined in [`.github/CODEOWNERS`](../CODEOWNERS). All files in
the repository are currently owned by `@homelab-alpha`, which means every pull
request will automatically request a review from the project maintainers.

For an overview of maintainer roles and responsibilities, see
[MAINTAINERS.md](../../MAINTAINERS.md).

## Review Timeline

| Stage                                       | Target Timeframe                            |
| :------------------------------------------ | :------------------------------------------ |
| Initial acknowledgment                      | Within **5 business days**                  |
| Full review cycle (straightforward changes) | Within **2 weeks**                          |
| Full review cycle (complex changes)         | Longer; maintainers will communicate delays |

If a review is taking longer than expected, maintainers will leave a comment on
the pull request to communicate the delay and an estimated timeline.

## Review Stages

### 1. Automated Checks

Every pull request targeting `main` triggers the following automated checks. The
full Super Linter (`super_linter.yml`) runs on `main` after the merge and adds
actionlint, Gitleaks, Checkov, and the other linters:

| Check               | Workflow                | Purpose                                                                                              |
| :------------------ | :---------------------- | :--------------------------------------------------------------------------------------------------- |
| Linting             | `lint_pull_request.yml` | Runs `npm run lint` on the changed files: Prettier, textlint terminology, and merge conflict markers |
| Concurrency control | All workflows           | Cancels duplicate runs for the same branch or pull request                                           |

All automated checks must pass before a human review is requested or a merge is
performed. If a check fails:

1. Review the workflow run logs for details.
2. Fix the issue in your branch and push the changes.
3. The checks will re-run automatically.

> [!NOTE]
>
> Super Linter only lints **changed files** by default
> (`USE_FIND_ALGORITHM=false`). This keeps CI fast while still catching issues
> in modified code.

### 2. Human Review

Once automated checks pass, a maintainer will review the pull request. The
review covers the following areas (see [Review Criteria](#review-criteria) for
details):

- Correctness and functionality.
- Code quality and style consistency.
- Documentation and changelog updates.
- Security considerations.
- Test coverage (where applicable).

A maintainer may:

- **Approve** the pull request if it meets all standards.
- **Request changes** by leaving specific comments. Each comment should be
  addressed before re-requesting a review.
- **Close** the pull request if it does not align with the project's goals,
  duplicates an existing contribution, or violates the contribution guidelines.

### 3. Approval and Merge

Once a pull request is approved and all checks pass, a maintainer will merge it
using the appropriate strategy (see [Merge Strategy](#merge-strategy)).

## Review Criteria

Reviewers assess pull requests against the following criteria:

### Correctness

- Does the change do what it claims to do?
- Does it introduce any regressions or unintended side effects?
- Are edge cases handled appropriately?

### Code Quality

- Does the code follow the conventions in
  [code_style_and_standards_guides.md](../docs/code_style_and_standards_guides.md)?
- Is the code readable, well-structured, and appropriately commented?
- Are errors handled gracefully?

### Documentation

- Is the [CHANGELOG.md](../../CHANGELOG.md) updated under `[Unreleased]`?
- Is any affected documentation updated to reflect the change?
- Are new features or behaviors documented clearly?

### Security

- Does the change introduce any secrets, credentials, or sensitive data?
- Does it follow the practices in [SECURITY.md](../../SECURITY.md) and
  [code_style_and_standards_guides.md](../docs/code_style_and_standards_guides.md#security-practices)?
- Does it introduce new dependencies, and if so, are they justified and safe?

### Tests

- Are the changes covered by tests where applicable?
- Do all existing tests continue to pass?

### Git Hygiene

- Does the branch name follow the
  [naming convention](../../CONTRIBUTING.md#branch-naming)?
- Do commit messages follow the
  [Conventional Commits](../../CONTRIBUTING.md#commit-messages) format?
- Is the branch up to date with `main` and free of merge conflicts?

## Responding to Review Feedback

When a reviewer requests changes:

1. Read all comments carefully before making changes.
2. Address each comment in a separate commit or as part of a logical group of
   commits — do not squash everything into one commit during active review, as
   this makes it harder to track what changed.
3. Reply to each comment explaining what you changed or why you chose a
   different approach. Do not resolve threads yourself — let the reviewer do
   that after confirming the change.
4. Once all comments are addressed, re-request a review from the reviewer.

> [!IMPORTANT]
>
> Do not force-push to your branch during active review unless explicitly asked
> to. Force-pushing rewrites history and makes it difficult for reviewers to see
> what changed since their last review.

## Merge Strategy

| Scenario                                | Strategy                                                                    |
| :-------------------------------------- | :-------------------------------------------------------------------------- |
| Standard pull requests                  | **Squash and merge** — combines all commits into one clean commit on `main` |
| Automated dependency updates (Renovate) | **Squash and merge** — handled automatically via `automergeType: squash`    |

Squash merging keeps the `main` branch history clean and linear, with one commit
per logical change. The squash commit message must follow the
[Conventional Commits](../../CONTRIBUTING.md#commit-messages) format.

## Automated Dependency Updates

Dependency updates are handled automatically by
[Renovate](../../.github/renovate.json) and follow a separate, lightweight
review process:

- **Patch, pin, and digest updates** are automerged without human review when
  all checks pass, during business hours (Monday–Friday, 09:00–16:00 Amsterdam
  time).
- **Major and minor updates** are never automerged and require manual review by
  a maintainer.
- **Security vulnerability updates** are prioritized and labeled `security`.

Automated pull requests are labeled `automerge` and the relevant dependency
name, making them easy to filter in the pull request list.

## Escalation

If a contributor disagrees with a review decision, the following steps apply:

1. **Open discussion**: Reply to the review comment with a clear explanation of
   your reasoning. Most disagreements can be resolved through respectful
   discussion.
2. **Escalate to a Senior Maintainer**: If no resolution is reached, request
   input from a Senior Maintainer who was not involved in the original review.
3. **Project Founder decision**: If escalation does not resolve the matter, the
   Project Founder makes the final binding decision.

For the full conflict resolution process, see
[MAINTAINERS.md](../../MAINTAINERS.md#conflict-resolution).

## Revision History

| Version | Date       | Author        | Changes          |
| :------ | :--------- | :------------ | :--------------- |
| 1.0.0   | 2026-10-29 | Homelab-Alpha | Initial release. |
