# GitHub Actions

- **Policy ID:** ENG-CI-001
- **Version:** 1.0.0
- **Status:** Active
- **Effective Date:** 2026-10-29
- **Owner:** Homelab-Alpha
- **Applies To:** All repositories using GitHub Actions within the organization

## Purpose

This policy defines mandatory standards for GitHub Actions to ensure
consistency, security, maintainability, and a high-quality developer experience.

It establishes **enforceable requirements** for:

- workflow structure
- naming and readability
- approved tooling and scripting languages
- commit, tag, and release signing
- logging and error signaling
- concurrency and permissions
- job-level reporting via `$GITHUB_STEP_SUMMARY`
- reusable workflow conventions

The provided example workflow is **normative** and represents the **reference
implementation** for compliance.

## Scope

This policy applies to:

- All GitHub Actions workflows.
- All repositories owned or maintained by the organization.
- All contributors who create or modify workflows.

This policy does **not** apply to third-party workflows that are consumed
without modification.

## Policy Objectives

- Provide consistent and readable workflow execution logs.
- Reduce mean time to diagnose CI and automation failures.
- Prevent unsafe or ambiguous workflow behavior.
- Enable standardized enforcement across teams and repositories.
- Ensure every workflow surfaces a **clear, human-readable execution summary**.
- Guarantee that all automated commits, tags, and releases carry a **verified
  signature**.
- Restrict workflow tooling to an **approved, auditable set** of tools.

## Mandatory Requirements

### Naming Conventions

#### Workflow Names

- Workflows **must** define a top-level `name`.
- Names **must** be descriptive and include a relevant emoji.

```yaml
name: 🕵️ Manage Stale Issues and Pull Requests
```

#### Job Names

- All jobs **must** define a `name`.
- Job names **must** be human-readable and include a relevant emoji.

```yaml
jobs:
  cleanup:
    name: 🔍 Process stale items
```

#### Step Names

- Every step **must** define a `name`.
- Step names **must**:
  - describe a single action
  - start with a verb
  - include an emoji where appropriate

Purely technical or boilerplate steps **may** omit an emoji if no clear semantic
signal is added.

```yaml
- name: 🏁 Notify start of process
```

### Permissions

- Every workflow or job **must** declare explicit `permissions`.
- Follow the **principle of least privilege**: grant only the permissions
  required for the job to complete.
- Default permissions should never be relied upon implicitly.

```yaml
permissions:
  contents: read
  issues: write
```

### Concurrency

- Every workflow **must** include a `concurrency` block.
- Use a meaningful group key that scopes concurrency to the branch, pull request
  number, or run ID as appropriate.
- Set `cancel-in-progress: true` for workflows where duplicate runs should be
  cancelled (e.g., linting, CI). Use `cancel-in-progress: false` for workflows
  where partial runs would leave state behind (e.g., releases, housekeeping).

```yaml
concurrency:
  group: linting-${{ github.ref }}
  cancel-in-progress: true
```

### Timeouts

- All jobs **must** define `timeout-minutes` to prevent runaway executions.
- Choose a realistic upper bound for the job's expected duration, adding a
  reasonable buffer.

```yaml
jobs:
  lint:
    timeout-minutes: 15
```

### Pinned Action Versions

- All external actions **must** be pinned to the full commit SHA of a release,
  followed by a comment with the version (e.g.,
  `actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1 # v7.0.1`).
- Do not use tags or branches such as `@main`, `@latest`, `@v4`, or `@v7.0.1`,
  as these are mutable and can introduce breaking changes or supply-chain
  vulnerabilities.
- Version updates are managed automatically by Renovate
  (`helpers:pinGitHubActionDigests`), which keeps the SHA and the comment in
  sync.

### Bot Filtering

Workflows that should not run on automated commits **must** include a bot filter
at the job level:

```yaml
if: |
  github.event.sender.type != 'Bot' &&
  !contains(github.actor, '[bot]')
```

## Approved Tooling

Workflows **must** use only the following tools for repository operations,
scripting, and automation logic. This restriction ensures that all workflow
behavior is auditable, reproducible, and free from undocumented third-party
dependencies.

### Permitted Tools

| Tool               | Usage                                                         |
| :----------------- | :------------------------------------------------------------ |
| `gh` (GitHub CLI)  | Repository operations: PRs, issues, releases, labels, caches. |
| GitHub REST API    | Advanced operations via `curl` or `wget` with `$GH_TOKEN`.    |
| GitHub GraphQL API | Complex queries and batch mutations via `gh api graphql`.     |
| `bash`             | Scripting, orchestration, and control flow.                   |
| `python3`          | Complex logic, data transformations, and utility scripts.     |

### Approved External Actions

The following GitHub-maintained or explicitly approved actions **may** be used.
They are exempt from the general restriction because they provide functionality
that cannot be replicated with the permitted tools above:

| Action                             | Purpose                          |
| :--------------------------------- | :------------------------------- |
| `actions/checkout`                 | Repository checkout.             |
| `actions/upload-artifact`          | Artifact upload.                 |
| `actions/download-artifact`        | Artifact download.               |
| `github/codeql-action/*`           | CodeQL security analysis.        |
| `actions/dependency-review-action` | Dependency vulnerability review. |
| `super-linter/super-linter`        | Multi-language linting.          |

### Restrictions

- **No other external actions** may be used without explicit written approval
  from the Owner and documentation in the repository `README.md`.
- **No `npm`, `npx`, or package manager invocations** in workflow steps unless
  the package is part of an approved action's internal toolchain.
- **No downloading or executing arbitrary binaries** from external sources.
- Requests for new tooling exceptions **must** include a justification
  explaining why the task cannot be accomplished with the permitted tools.

### Python Dependencies

When a workflow step requires Python packages beyond the standard library:

- Dependencies **must** be listed in a `requirements.txt` or `pyproject.toml`
  file committed to the repository.
- Installation **must** use `pip install -r requirements.txt` within the
  workflow step.
- All packages **must** be pinned to exact versions.
- Renovate **should** be configured to manage Python dependency updates.

## Commit, Tag, and Release Signing

All automated operations that create or modify Git objects **must** produce a
**verified signature** visible in the GitHub UI. This section defines the
requirements and approved methods for achieving verified status.

### How Verified Status Works

GitHub determines the "Verified" badge based on the **commit** that a tag or
release points to, not on the tag object itself. This means:

- If the **commit** is signed (via Contents API PUT, or by a contributor with a
  registered GPG/SSH key), the tag and release that reference that commit
  inherit the "Verified" badge in the GitHub UI.
- `gh release create` creates a **lightweight tag** pointing directly to the
  target commit. If that commit is verified, the tag shows as verified.
- The Git Tags API creates **annotated tag objects**, but these are **not
  automatically signed** by GitHub — the `reason` field returns `unsigned`.

This behavior has been confirmed through testing on this repository. The policy
requirements below reflect this reality.

### Primary Method: GitHub API

The preferred method for creating verified commits is through the **GitHub
Contents API** via `gh` (GitHub CLI). When `GITHUB_TOKEN` is used to
authenticate PUT requests, GitHub automatically signs the resulting commit and
marks it as **Verified**. No local Git configuration, GPG keys, or SSH keys are
required.

This is the method used by all existing workflows in this repository.

### Automated Commits via Contents API

Workflows that create or update files (e.g., `CONTRIBUTORS.md`, `CHANGELOG.md`,
`ROADMAP.md`) **must** use the GitHub Contents API **PUT** method. Commits
created through PUT requests with `GITHUB_TOKEN` are automatically verified.

**Compliant pattern:**

```bash
# Get the current file SHA (required for updates)
SHA=$(gh api "repos/$REPO/contents/$FILE_PATH" --jq '.sha' 2>/dev/null || true)

# Encode the new content
CONTENT=$(base64 --wrap=0 < "$FILE_PATH")

# Create/update the file — the resulting commit is automatically verified
gh api --method PUT "repos/$REPO/contents/$FILE_PATH" \
  -f message="chore: update $FILE_PATH" \
  -f content="$CONTENT" \
  -f sha="$SHA" \
  -f branch="$BRANCH"
```

> [!IMPORTANT]
>
> The `GH_TOKEN` environment variable **must** be set at the job level to
> `${{ secrets.GITHUB_TOKEN }}`. This ensures all `gh api` calls are
> authenticated and resulting commits are verified.

> [!WARNING]
>
> **Contents API DELETE produces unsigned commits.** The DELETE method on the
> Contents API (`gh api --method DELETE "repos/$REPO/contents/..."`) creates
> commits that are **not verified** (`reason: unsigned`). This is a known GitHub
> platform behavior. Avoid using Contents API DELETE in workflows that require
> all commits to be verified. If file deletion is necessary, use the Git Trees
> API to compose a commit without the file instead.

### Tags and Releases via `gh release create`

Tags **must** be created through `gh release create`. This creates a
**lightweight tag** pointing to the target commit. The tag inherits the
"Verified" badge from the underlying commit — as long as the commit is verified,
the tag and release will show as verified in the GitHub UI.

**Compliant pattern:**

```bash
gh release create "v1.0.0" \
  --repo "$REPO" \
  --target "$BRANCH" \
  --title "v1.0.0" \
  --notes-file release_notes.md
```

For prereleases:

```bash
gh release create "v1.0.0-alpha.1" \
  --repo "$REPO" \
  --target "$BRANCH" \
  --title "v1.0.0-alpha.1" \
  --notes-file release_notes.md \
  --prerelease \
  --latest=false
```

> [!NOTE]
>
> The "Verified" badge on a tag comes from the **commit** it points to, not from
> the tag itself. Ensure the target commit is verified (e.g., created via
> Contents API PUT, or signed by a contributor with a registered GPG/SSH key)
> before creating the release.

**Non-compliant patterns:**

```bash
# ❌ Local lightweight tag without verified commit
git tag "v1.0.0"
git push origin "v1.0.0"

# ❌ Local annotated tag without GPG signing
git tag -a "v1.0.0" -m "Release v1.0.0"
git push origin "v1.0.0"
```

### Branches and Pull Requests via API

Branches and pull requests **must** be created via the GitHub API. This ensures
consistent behavior and proper authentication.

**Branch creation:**

```bash
BASE_SHA=$(gh api "repos/$REPO/git/ref/heads/main" --jq '.object.sha')
gh api --method POST "repos/$REPO/git/refs" \
  -f ref="refs/heads/$BRANCH" \
  -f sha="$BASE_SHA"
```

**Pull request creation:**

```bash
gh api --method POST "repos/$REPO/pulls" \
  -f title="chore(release): v1.0.0" \
  -f head="$BRANCH" \
  -f base="main" \
  -f body="$PR_BODY"
```

The PR title **must** follow the Conventional Commits format.

### Fallback Method: GPG Signing (Local Git Operations)

In rare cases where the API cannot be used (e.g., multi-file commits that
require a Git Tree + Commit object), local `git commit` or `git tag` may be used
with GPG signing. This is the **only** scenario where local Git configuration is
permitted.

Use the `.github/scripts/setup_gpg.sh --gpg` helper to configure signing:

1. Store the GPG private key as `GPG_PRIVATE_KEY` (armor-exported, base64
   encoded) in repository or organization secrets.
2. Store the passphrase as `GPG_PASSPHRASE` in repository or organization
   secrets.
3. Call the setup script in the workflow:

```bash
source .github/scripts/setup_gpg.sh --gpg
```

> [!CAUTION]
>
> GPG private keys in secrets **must** be rotated at least annually. Key
> rotation dates **must** be tracked and documented. Any suspected compromise
> **must** be reported immediately as a security incident.

### Signing Verification

Verification **must** always check the **commit** that a tag points to, not the
tag object itself. This is because GitHub's "Verified" badge for tags is derived
from the underlying commit's signature.

**Commit verification:**

```bash
VERIFIED=$(gh api "repos/$REPO/commits/$COMMIT_SHA" \
  --jq '.commit.verification.verified')

if [ "$VERIFIED" != "true" ]; then
  echo "::error title=Signature verification failed::❌ Commit is not verified"
  exit 1
fi
echo "::notice title=Signature verified::✅ Commit signature is verified"
```

**Tag verification (via underlying commit):**

```bash
# Resolve the tag to its target commit SHA
REF_DATA=$(gh api "repos/$REPO/git/ref/tags/$TAG_NAME" \
  --jq '[.object.type, .object.sha] | @tsv')
OBJ_TYPE=$(echo "$REF_DATA" | cut -f1)
OBJ_SHA=$(echo "$REF_DATA" | cut -f2)

# If annotated tag, resolve further to the commit
if [ "$OBJ_TYPE" = "tag" ]; then
  COMMIT_SHA=$(gh api "repos/$REPO/git/tags/$OBJ_SHA" --jq '.object.sha')
else
  COMMIT_SHA="$OBJ_SHA"
fi

# Verify the commit the tag points to
VERIFIED=$(gh api "repos/$REPO/commits/$COMMIT_SHA" \
  --jq '.commit.verification.verified')

if [ "$VERIFIED" != "true" ]; then
  echo "::error title=Tag verification failed::❌ Tag $TAG_NAME points to unverified commit"
  exit 1
fi
echo "::notice title=Tag verified::✅ Tag $TAG_NAME points to verified commit"
```

For comprehensive verification, use `.github/scripts/verify_signatures.sh`:

```bash
# Verify last 10 commits and last 5 tags (strict mode)
./.github/scripts/verify_signatures.sh --commits 10 --tags 5 --strict
```

### Known Platform Behaviors

| API Method          | Object Created  | Verified? | Notes                                                   |
| :------------------ | :-------------- | :-------: | :------------------------------------------------------ |
| Contents API PUT    | Commit          |  ✅ Yes   | Standard method for single-file changes.                |
| Contents API DELETE | Commit          |   ❌ No   | Produces `unsigned` commits. Avoid.                     |
| Git Tags API POST   | Annotated Tag   |   ❌ No   | Tag object is `unsigned`. Commit may still be verified. |
| `gh release create` | Lightweight Tag |    N/A    | Inherits verified status from the target commit.        |
| Git Refs API POST   | Branch/Ref      |    N/A    | No signature applicable.                                |
| Pulls API POST      | Pull Request    |    N/A    | No signature applicable.                                |

## Reusable Workflows

### When to Use Reusable Workflows

A reusable workflow (`workflow_call`) **should** be used when:

- The same logic is needed across **two or more repositories**.
- A workflow implements a **standardized process** that must remain consistent
  (e.g., release signing, compliance checks).
- The workflow contains **complex logic** that benefits from centralized
  maintenance.

A standalone workflow is appropriate when the logic is **repository-specific**
and unlikely to be reused.

### Naming Convention

Reusable workflows **must** follow this naming pattern:

```text
_reusable-<purpose>.yml
```

The underscore prefix distinguishes internal/reusable workflows from standalone
workflows in directory listings. Examples:

- `_reusable-lint.yml`
- `_reusable-release-signing.yml`
- `_reusable-pr-validation.yml`

### Documentation Requirements

Every reusable workflow **must** document its interface in the workflow file
itself using YAML comments:

```yaml
# Reusable workflow: _reusable-lint.yml
# Purpose: Run Super Linter with standardized configuration.
# Inputs:
#   - log_level (string, default: "NOTICE"): Super Linter log level.
# Secrets:
#   - None required.
# Outputs:
#   - lint_result (string): "success" or "failure".

on:
  workflow_call:
    inputs:
      log_level:
        description: "Super Linter log level"
        required: false
        default: "NOTICE"
        type: string
    outputs:
      lint_result:
        description: "Result of the linting run"
        value: ${{ jobs.lint.outputs.result }}
```

## Logging Policy

For detailed logging standards, including annotation levels, log grouping,
script logging conventions, and retention policies, see
[`.github/policies/logs.md`](./logs.md).

This section summarizes the mandatory requirements that directly affect workflow
compliance.

### Approved Log Levels

Only the following workflow commands are permitted for status communication:

| Level   | Command                            | Usage                               |
| :------ | :--------------------------------- | :---------------------------------- |
| Debug   | `::debug::{message}`               | Low-level troubleshooting (opt-in). |
| Notice  | `::notice [title=...]::{message}`  | High-level progress or context.     |
| Warning | `::warning [title=...]::{message}` | Non-fatal but actionable issues.    |
| Error   | `::error [title=...]::{message}`   | Fatal or policy-relevant failures.  |

All annotations **must** include a descriptive `title` parameter so they are
easy to identify in the GitHub UI without expanding the full log.

### Error Logging Requirement

Any step that exits with a **non-zero status** **must** emit an `::error::`
annotation **immediately before exiting**.

This ensures the failure is visible in the GitHub UI regardless of log volume.

**Compliant:**

```bash
echo "::error title=Simulation failed::❌ Placeholder failure for policy compliance"
exit 1
```

**Non-compliant:**

```bash
exit 1
```

### Log Grouping

- Steps producing more than **three lines of output** **must** use log grouping.
- Group titles **must** be descriptive and human-readable.

```bash
echo "::group::🔍 Stale detection"
echo "Processing stale issues and pull requests"
echo "::endgroup::"
```

Group boundaries should wrap logically related operations — for example, all
steps involved in loading a configuration file, or all output from a cleanup
task.

## Job Summary Requirement

Every **job** **must** generate **exactly one** job summary using
`$GITHUB_STEP_SUMMARY`.

The job summary is the **primary user-facing report** of the workflow run and
**must be generated even when the job fails**.

The summary step **must** use `if: always()`.

### Required Content

Each summary **must** include:

1. **Overall result** using a Markdown header with a status emoji.
2. **Key metrics or processed targets**, expressed as a table.
3. **Final status indicators** using emojis (see table below).
4. **Runtime configuration values** when relevant (branch, inputs, thresholds).
5. **A link to the workflow run details** via `${{ github.server_url }}`.

### Emoji Reference

Use emojis consistently across all summaries to improve scannability:

| Symbol | Meaning                    |
| :----- | :------------------------- |
| ✅     | Success                    |
| ❌     | Failure                    |
| ⚠️     | Warning or partial failure |
| ℹ️     | Informational              |
| 🗑️     | Deletion or cleanup        |
| 🔍     | Scanning or analysis       |
| ⏭️     | Skipped                    |

### Reference Implementation (Normative)

The following workflow represents the **canonical, policy-compliant
implementation** of logging, error handling, signing, and job summary
generation.

> Workflows following this structure are considered compliant by default.

```yaml
---
name: 🕵️ Manage Stale Issues and Pull Requests

on:
  schedule:
    - cron: "0 3 * * *"

  workflow_dispatch:
    inputs:
      days_before_stale_issue:
        description: "Days of inactivity before marking an issue as stale"
        required: true
        default: 11
        type: number
      days_before_close_issue:
        description: "Days after stale before closing the issue"
        required: true
        default: 3
        type: number
      days_before_stale_pull_request:
        description: "Days of inactivity before marking a pull request as stale"
        required: true
        default: 25
        type: number
      days_before_close_pull_request:
        description: "Days after stale before closing the pull request"
        required: true
        default: 3
        type: number

permissions:
  issues: write
  pull-requests: write

concurrency:
  group: stale-${{ github.ref }}
  cancel-in-progress: true

jobs:
  cleanup:
    name: 🔍 Process stale items
    runs-on: ubuntu-latest
    timeout-minutes: 15

    if: |
      github.event.sender.type != 'Bot' &&
      !contains(github.actor, '[bot]')

    env:
      GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      DAYS_BEFORE_STALE_ISSUES:
        ${{ github.event.inputs.days_before_stale_issue || '11' }}
      DAYS_BEFORE_CLOSE_ISSUES:
        ${{ github.event.inputs.days_before_close_issue || '3' }}
      DAYS_BEFORE_STALE_PRS:
        ${{ github.event.inputs.days_before_stale_pull_request || '25' }}
      DAYS_BEFORE_CLOSE_PRS:
        ${{ github.event.inputs.days_before_close_pull_request || '3' }}

    steps:
      - name: 🏁 Notify start of process
        run: |
          echo "::notice title=Workflow started::🔍 Stale processing started"
          echo "::group::ℹ️ Execution context"
          echo "Repository: ${{ github.repository }}"
          echo "Workflow ref: ${{ github.ref }}"
          echo "Runner OS: ${{ runner.os }}"
          echo "::endgroup::"

      - name: 🔍 Process stale issues
        id: process_issues
        run: |
          echo "::group::🔍 Stale issue detection"
          gh issue list \
            --repo "${{ github.repository }}" \
            --state open \
            --json number,updatedAt,labels \
            --jq '.[] | select(.updatedAt < (now - ($DAYS_BEFORE_STALE_ISSUES | tonumber * 86400) | todate))' \
            || true
          echo "::endgroup::"

      - name: 🔍 Process stale pull requests
        id: process_prs
        run: |
          echo "::group::🔍 Stale PR detection"
          gh pr list \
            --repo "${{ github.repository }}" \
            --state open \
            --json number,updatedAt,labels \
            --jq '.[] | select(.updatedAt < (now - ($DAYS_BEFORE_STALE_PRS | tonumber * 86400) | todate))' \
            || true
          echo "::endgroup::"

      - name: 📊 Generate job summary
        if: always()
        run: |
          echo "::group::📊 Generating Summary Report"

          ISSUE_STATUS="${{ steps.process_issues.outcome == 'success' && '✅ Success' || '❌ Failed' }}"
          PR_STATUS="${{ steps.process_prs.outcome == 'success' && '✅ Success' || '❌ Failed' }}"

          cat <<EOF >> "$GITHUB_STEP_SUMMARY"
          ## 🕵️ Stale Management Summary

          Execution completed at: $(date -u)

          ### 📈 Execution Results

          | Target           |  Action   | Result        |
          | :--------------- | :-------: | :------------ |
          | 🎫 Issues        | Processed | $ISSUE_STATUS |
          | 🏗️ Pull Requests | Processed | $PR_STATUS    |

          ### ⚙️ Runtime Configuration

          - **Issue Stale Threshold:** ${{ env.DAYS_BEFORE_STALE_ISSUES }} days
          - **PR Stale Threshold:** ${{ env.DAYS_BEFORE_STALE_PRS }} days
          - **Close Grace Period:** ${{ env.DAYS_BEFORE_CLOSE_ISSUES }} days

          ### 🧩 Notes

          - Workflow Run: [View Details](${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }})
          EOF

          echo "::endgroup::"
```

## Secrets and Security

- **Masking:** Derived sensitive values or dynamic secrets **must** be masked
  using `::add-mask::{value}`.
- **Leak Prevention:** Secrets **must never** be logged in plain text.
- **Debug Safety:** Debug logging **must not** expose credentials or tokens.
- **Token Scope:** Use `secrets.GITHUB_TOKEN` for repository-scoped operations.
  Personal access tokens must not be stored in repository secrets unless
  explicitly approved by Homelab-Alpha.
- **GPG Key Rotation:** GPG private keys stored as secrets **must** be rotated
  at least annually. Rotation dates **must** be documented.
- **Token Exposure:** The `GH_TOKEN` environment variable **must** be set at the
  job level (not step level) to prevent accidental exposure in multi-step jobs.

> [!CAUTION]
>
> Any violation of this section is treated as a **security incident** and
> escalated to the Security Operations Center (SOC).

## Enforcement

### Enforcement Mechanisms

At least one of the following enforcement mechanisms **must** be implemented:

1. **Reusable Workflow Enforcement:** All workflows extend a centrally managed
   template.
2. **Pull Request Enforcement:** PRs modifying workflows require a `CODEOWNERS`
   review from Homelab-Alpha.
3. **Automated Linting:** CI checks (e.g., `actionlint`) validate compliance for
   missing names or forbidden patterns.
4. **Tooling Audit:** CI checks verify that workflow steps use only approved
   tools and actions. Steps referencing unapproved external actions or binaries
   **must** be flagged.

### Non-Compliance Handling

- Non-compliant workflows will be blocked from merging.
- Repeated violations trigger a mandatory training session.
- Exceptions must be documented in the repository `README.md` and approved by
  the Owner.

## Compliance Checklist

Use this checklist when authoring or reviewing a workflow:

### Structure and Naming

- [ ] Top-level `name` is defined with an emoji.
- [ ] All jobs define a `name` with an emoji.
- [ ] All steps define a `name` starting with a verb.

### Security and Permissions

- [ ] `permissions` are declared at the workflow or job level.
- [ ] No secrets are logged in plain text.
- [ ] `GH_TOKEN` is set at the job level via `env`.

### Execution Control

- [ ] A `concurrency` block is present with an appropriate `cancel-in-progress`
      value.
- [ ] All jobs set `timeout-minutes`.
- [ ] Bot-triggered runs are filtered where appropriate.

### Tooling

- [ ] Only approved tools are used (`gh`, GitHub API, `bash`, `python3`).
- [ ] All external actions are from the approved list.
- [ ] All external actions use a pinned tagged version.
- [ ] No unapproved binaries are downloaded or executed.

### Signing

- [ ] Automated commits use the GitHub Contents API PUT (not local
      `git commit`).
- [ ] Tags are created via `gh release create` targeting a verified commit.
- [ ] The target commit is verified (visible in GitHub UI).
- [ ] GPG signing is only used as fallback for multi-file commits.

### Logging and Reporting

- [ ] Every non-zero exit is preceded by an `::error::` annotation.
- [ ] Steps with more than three lines of output use `::group::` /
      `::endgroup::`.
- [ ] A job summary step with `if: always()` is present.
- [ ] The summary includes a result table, runtime configuration, and a run
      link.

## Revision History

| Version | Date       | Author        | Changes          |
| :------ | :--------- | :------------ | :--------------- |
| 1.0.0   | 2026-10-29 | Homelab-Alpha | Initial release. |

## 🏁 Final Statement

This policy prioritizes **clarity, safety, and consistency**. Automation is
infrastructure. Infrastructure must be predictable. Every automated change must
be **traceable, signed, and verifiable**.
