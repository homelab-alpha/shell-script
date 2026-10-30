# Labels

- **Policy ID:** ENG-LABEL-001
- **Version:** 1.0.0
- **Status:** Active
- **Effective Date:** 2026-10-29
- **Owner:** Homelab-Alpha
- **Applies To:** All repositories using GitHub Actions within the organization

> [!IMPORTANT]
>
> This is a living document and may be adjusted based on feedback and project
> priorities.

This document defines the semantic color strategy and categorization rules for
GitHub labels used across the repository. Labels are managed automatically via
`.github/labels.yml` and synchronized by the
[Labels workflow](./../workflows/labels.yml).

<details>
  <summary>Table of Contents (click to expand)</summary>
  <p>

1. [Labels](#labels)
   1. [Purpose](#purpose)
   2. [Important Rules](#important-rules)
   3. [Color Strategy](#color-strategy)
      1. [🔴 Critical / Errors / Blockers](#-critical--errors--blockers)
      2. [🟠 High Risk / Regressions](#-high-risk--regressions)
      3. [🟡 Status / Triage / Waiting](#-status--triage--waiting)
      4. [🟢 Positive / Completed / Resolved](#-positive--completed--resolved)
      5. [🔵 Tooling / CI/CD / Dependencies](#-tooling--cicd--dependencies)
      6. [🟣 Conceptual / Discussion / Features](#-conceptual--discussion--features)
      7. [⚫⚪ Neutral / Closed / No Action](#-neutral--closed--no-action)
   4. [Priority Labels](#priority-labels)
   5. [PR Labels](#pr-labels)
   6. [Quality Requirements](#quality-requirements)
   7. [Modifying Labels](#modifying-labels)
   8. [Revision History](#revision-history)

  </p>
</details>

## Purpose

A consistent label system enables:

- Faster distinction between **priority, status, type, and tooling**.
- Better scannability in GitHub across issues and pull requests.
- A predictable, self-documenting workflow for contributors and maintainers.

## Important Rules

1. Analyze all existing labels and their meanings before making any changes.
2. Retain all labels exactly as they are:
   - ❌ Do not rename
   - ❌ Do not delete
   - ❌ Do not modify descriptions
3. Only adjust the **`color`** field when updating existing labels.
4. New labels must be added to [`.github/labels.yml`](./../labels.yml) and
   follow the color strategy below before they are used.

## Color Strategy

Use this semantic mapping consistently. Each category maps to a distinct color
family. Labels within the same category use the same or very similar hex values.

### 🔴 Critical / Errors / Blockers

- **For:** `bug`, `security`, `P0: critical`, `blocked`, `releaseblocker`,
  `test failures`, `security vulnerability`
- **Tone:** Eye-catching, high urgency. Use red-spectrum values.

### 🟠 High Risk / Regressions

- **For:** `breaking change`, `major`, `performance regression`
- **Tone:** Less aggressive than red, but still highly important. Use orange.

### 🟡 Status / Triage / Waiting

- **For:** `in progress`, `needs input`, `triage`, `in review`, `needs design`,
  `needs testing`, `followed up`, `PR: needs review`,
  `PR: please address review comments`, `PR: depends on other`
- **Tone:** Neutral, process-focused. Use yellow/amber.

### 🟢 Positive / Completed / Resolved

- **For:** `fix`, `automerge`, `question-answered`, `minor`, `patch`, `P3: low`
- **Tone:** Clearly "good / done". Use green.

### 🔵 Tooling / CI/CD / Dependencies

- **For:**
  - `ci/cd`, `github-actions`
  - All `docker.io/*` image labels
  - All `ghcr.io/*` image labels
  - `dependencies`, `dev dependencies`, `gomod`, `go`, `node`
  - Specific tool labels: `eslint`, `prettier`, `vite`, `vue`, `typescript`,
    `renovate`, `super-linter/super-linter`
- **Tone:** Consistent blue spectrum. Labels in the same subcategory (e.g., all
  Docker image labels) use the same hex value.

### 🟣 Conceptual / Discussion / Features

- **For:** `enhancement`, `feature request`, `discussion`, `question`, `a11y`,
  `refactor`, `code quality`, `migration`, `integration`, `localized`,
  `external`, `breaking change`
- **Tone:** Creative, non-urgent. Use purple.

### ⚫⚪ Neutral / Closed / No Action

- **For:** `wontfix`, `duplicate`, `stale`, `invalid`, `spam`,
  `cannot reproduce`, `user error`, `deprecated`, `YANKED`, `revert`,
  `conversation lock`
- **Tone:** Muted, low visual priority. Use gray.

## Priority Labels

Priority labels must form a clear visual gradient from high urgency to low:

| Label            | Color Family | Meaning                         |
| :--------------- | :----------- | :------------------------------ |
| `P0: critical`   | 🔴 Red       | Immediate action required       |
| `P1: high`       | 🔴 Red-ish   | Address as soon as possible     |
| `P2: moderate`   | 🟡 Yellow    | Normal scheduling               |
| `P3: low`        | 🟢 Green     | Non-urgent improvement          |
| `P4: negligible` | ⚫ Gray      | Minimal impact, lowest priority |

## PR Labels

Pull request lifecycle labels form a consistent subgroup within the status
category (yellow/amber). They should be visually related to each other but
distinct from issue status labels.

| Label                                | Stage            |
| :----------------------------------- | :--------------- |
| `PR: needs review`                   | Awaiting review  |
| `PR: please address review comments` | Changes required |
| `PR: please resolve merge conflict`  | Conflict present |
| `PR: depends on other`               | Blocked          |

## Quality Requirements

When defining or updating labels, verify the following:

- Good readability in **GitHub dark mode**.
- Sufficient contrast between labels shown side by side.
- No two labels with different semantic meanings share the same hex color.
- No excessively light colors (hard to read in dark mode).
- No pure black or pure white unless absolutely necessary.
- Maximum **six to eight clear color families** across the full label set.

## Modifying Labels

All label changes must go through [`.github/labels.yml`](./../labels.yml).
Direct edits via the GitHub UI are not permitted as they will be overwritten on
the next workflow run.

To add a new label:

1. Add the entry to [`.github/labels.yml`](./../labels.yml) following the
   existing format.
2. Assign a color that matches the semantic category above.
3. Write a clear, concise `description` (one sentence).
4. Open a pull request. The Labels workflow will apply the change automatically
   on merge to `main`.

## Revision History

| Version | Date       | Author        | Changes          |
| :------ | :--------- | :------------ | :--------------- |
| 1.0.0   | 2026-10-29 | Homelab-Alpha | Initial release. |
