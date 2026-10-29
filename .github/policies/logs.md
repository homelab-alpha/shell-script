# Logs

- **Policy ID:** ENG-LOG-001
- **Version:** 1.0.0
- **Status:** Active
- **Effective Date:** 2026-10-29
- **Owner:** Homelab-Alpha
- **Applies To:** All repositories using GitHub Actions within the organization

> [!IMPORTANT]
>
> This is a living document and may be adjusted based on feedback and project
> priorities.

This document is the **canonical reference** for all logging standards and
practices across the project, including GitHub Actions workflows, shell scripts,
and Python utilities.

For workflow-specific compliance requirements (naming, permissions, concurrency,
signing), see [`.github/policies/github_actions.md`](./github_actions.md).

<details>
  <summary>Table of Contents (click to expand)</summary>
  <p>

1. [Logs](#logs)
   1. [Purpose](#purpose)
   2. [GitHub Actions Logging](#github-actions-logging)
      1. [Annotation Levels](#annotation-levels)
      2. [Error Logging Requirement](#error-logging-requirement)
      3. [Log Grouping](#log-grouping)
      4. [Job Summaries](#job-summaries)
      5. [Emoji Reference](#emoji-reference)
   3. [Script Logging — Bash](#script-logging--bash)
   4. [Script Logging — Python](#script-logging--python)
      1. [Standard Library `logging` Module](#standard-library-logging-module)
      2. [Log Levels](#log-levels)
      3. [GitHub Actions Integration](#github-actions-integration)
      4. [Structured Output](#structured-output)
   5. [Audit Logging](#audit-logging)
      1. [Required Audit Annotations](#required-audit-annotations)
      2. [Signing Failure Logging](#signing-failure-logging)
   6. [Log Retention](#log-retention)
   7. [What Not to Log](#what-not-to-log)
   8. [Revision History](#revision-history)

  </p>
</details>

## Purpose

Consistent logging makes it easier to diagnose failures, understand workflow
behavior, and maintain the project over time. All contributors are expected to
follow these logging conventions when adding or modifying workflows, scripts, or
tooling.

## GitHub Actions Logging

### Annotation Levels

GitHub Actions supports workflow annotations to surface important information
directly in the pull request and workflow run UI. Use the appropriate level for
the situation:

| Level   | Syntax                                      | When to Use                                                   |
| :------ | :------------------------------------------ | :------------------------------------------------------------ |
| Debug   | `echo "::debug::<message>"`                 | Low-level troubleshooting (opt-in via `ACTIONS_STEP_DEBUG`).  |
| Notice  | `echo "::notice title=<title>::<message>"`  | Informational messages; expected outcomes and status updates. |
| Warning | `echo "::warning title=<title>::<message>"` | Non-fatal issues; degraded behavior or skipped steps.         |
| Error   | `echo "::error title=<title>::<message>"`   | Fatal failures; the step or job cannot continue.              |

Always include a descriptive `title` so annotations are easy to identify in the
GitHub UI without having to expand the full log.

### Error Logging Requirement

Any step that exits with a **non-zero status** **must** emit an `::error::`
annotation **immediately before exiting**.

This ensures the failure is visible in the GitHub UI regardless of log volume.

**Compliant:**

```bash
echo "::error title=Linting failed::❌ Super-Linter found issues in the codebase."
exit 1
```

**Non-compliant:**

```bash
exit 1
```

### Log Grouping

Use `::group::` and `::endgroup::` to collapse related log output into named
sections. This keeps workflow logs readable, especially for long-running steps.

- Steps producing more than **three lines of output** **must** use log grouping.
- Group titles **must** be descriptive and human-readable.

```bash
echo "::group::📄 Loading environment variables"
# ... log output ...
echo "::endgroup::"
```

Group boundaries should wrap logically related operations — for example, all
steps involved in loading a configuration file, or all output from a cleanup
task.

### Job Summaries

Every workflow **must** include a job summary step that writes a structured
report to `$GITHUB_STEP_SUMMARY`. Job summaries appear on the workflow run page
and provide a quick overview without requiring users to inspect raw logs.

The summary step **must** use `if: always()` so that summaries are generated
even when the job fails.

A job summary **must** include at minimum:

1. The execution timestamp (`date -u`).
2. The result status of each major step (success or failure).
3. Runtime configuration values (branch, runner OS, relevant inputs).
4. A link to the workflow run details.

**Example pattern:**

```bash
cat <<EOF >> "$GITHUB_STEP_SUMMARY"

## 🔍 Workflow Summary

Execution completed at: $(date -u)

### 📈 Results

| Step | Result     |
| :--- | :--------- |
| Lint | ✅ Success |

### ⚙️ Configuration

- **Branch:** $GITHUB_REF
- **Runner OS:** $RUNNER_OS
- **Workflow Run:** [View Details](${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }})
EOF
```

### Emoji Reference

Use emojis consistently across all summaries and annotations to improve
scannability. This table is the **canonical reference** used across all policies
and workflows.

| Symbol | Meaning                    |
| :----- | :------------------------- |
| ✅     | Success                    |
| ❌     | Failure                    |
| ⚠️     | Warning or partial failure |
| ℹ️     | Informational              |
| 🗑️     | Deletion or cleanup        |
| 🔍     | Scanning or analysis       |
| ⏭️     | Skipped                    |
| 🔏     | Signing or verification    |

## Script Logging — Bash

Shell scripts used within workflows **must** follow these logging conventions:

- Use `set -Eeuo pipefail` at the top of every script to ensure errors are
  surfaced immediately and not silently swallowed.
- Write human-readable status messages to standard output for every significant
  action taken (e.g., file found, item deleted, step skipped).
- Use GitHub Actions annotation syntax (`::notice`, `::warning`, `::error`)
  rather than plain `echo` for messages that should surface in the workflow UI.
- For dry-run modes, always log what _would_ have happened so the output remains
  meaningful without performing destructive actions.

**Example:**

```bash
if [ "$DRY_RUN" != "true" ]; then
  gh api -X DELETE "/repos/$REPO/actions/caches/$CACHE_ID"
  echo "::notice title=Cache deleted::🗑️ Deleted Cache ID $CACHE_ID"
else
  echo "::notice title=Dry-run::ℹ️ Would delete Cache ID $CACHE_ID"
fi
```

## Script Logging — Python

Python scripts invoked by workflows **must** follow these logging conventions:

### Standard Library `logging` Module

All Python scripts **must** use the `logging` module from the standard library.
Direct `print()` statements for status output are **not permitted** in scripts
that are invoked by workflows.

```python
import logging

logging.basicConfig(
    level=logging.INFO,
    format="%(levelname)s: %(message)s",
)

logger = logging.getLogger(__name__)
```

### Log Levels

| Python Level      | When to Use                                                      |
| :---------------- | :--------------------------------------------------------------- |
| `logging.DEBUG`   | Low-level troubleshooting; only visible when explicitly enabled. |
| `logging.INFO`    | Expected outcomes, progress updates, and status messages.        |
| `logging.WARNING` | Non-fatal issues; degraded behavior or fallback paths.           |
| `logging.ERROR`   | Fatal failures; the script cannot continue.                      |

### GitHub Actions Integration

When a Python script runs inside a GitHub Actions workflow, it **should** emit
GitHub Actions annotations for messages at `WARNING` level and above so they
surface in the workflow UI:

```python
import logging
import os

def gh_annotation(level: str, title: str, message: str) -> None:
    """Emit a GitHub Actions annotation if running in CI."""
    if os.getenv("GITHUB_ACTIONS") == "true":
        print(f"::{level} title={title}::{message}")

logger = logging.getLogger(__name__)

try:
    result = process_data()
    logger.info("Processing completed successfully")
except ValueError as e:
    logger.error("Data processing failed: %s", e)
    gh_annotation("error", "Processing failed", f"❌ {e}")
    raise SystemExit(1)
```

### Structured Output

For scripts that produce data consumed by subsequent workflow steps, use
`GITHUB_OUTPUT` for machine-readable values and reserve logging for
human-readable status:

```python
import os

def set_output(name: str, value: str) -> None:
    """Write a value to GITHUB_OUTPUT for subsequent workflow steps."""
    output_file = os.getenv("GITHUB_OUTPUT", "")
    if output_file:
        with open(output_file, "a") as f:
            f.write(f"{name}={value}\n")
```

## Audit Logging

Workflows that create, modify, or delete Git objects (commits, tags, branches)
or GitHub resources (releases, issues, PRs) **must** emit audit annotations to
create a traceable record of automated actions.

### Required Audit Annotations

Every automated mutation **must** produce a `::notice` annotation with the
following information:

| Field     | Description                                          |
| :-------- | :--------------------------------------------------- |
| Action    | What was done (e.g., "Commit created", "Tag pushed") |
| Actor     | The identity used (e.g., `github-actions[bot]`)      |
| Reference | The SHA, tag name, or PR number                      |
| Timestamp | UTC timestamp of the action                          |

**Example — Automated commit (via Contents API):**

```bash
COMMIT_SHA=$(echo "$COMMIT_RESPONSE" | jq -r '.commit.sha')
echo "::notice title=Commit created::🔏 Commit ${COMMIT_SHA:0:7} created by github-actions[bot] at $(date -u)"
```

**Example — Release and tag created (via gh release create):**

```bash
echo "::notice title=Release created::🔏 Release v1.0.0 created at $(date -u)"
```

### Signing Failure Logging

Any failure related to commit or tag verification **must** emit an `::error`
annotation with sufficient detail for diagnosis:

```bash
echo "::error title=Verification failed::❌ Commit ${COMMIT_SHA:0:7} is not verified (reason: $REASON)"
```

## Log Retention

Workflow run logs are automatically cleaned up by the
[Housekeeping workflow](../../.github/workflows/housekeeping.yml), which runs
every Sunday at 03:00 UTC. The default retention period is **28 days** for
workflow runs and **7 days** for Actions caches.

These values can be adjusted when triggering the housekeeping workflow manually
via `workflow_dispatch`. A dry-run mode is available to preview what would be
deleted before taking any action.

## What Not to Log

Never include the following in log output, job summaries, or annotations:

- **Secrets or credentials** — tokens, passwords, API keys, GPG private keys, or
  signing passphrases.
- **Personal data** — usernames, email addresses, or any personally identifiable
  information beyond GitHub actor names already exposed by the platform.
- **Verbose internal state** by default — keep logs focused on outcomes and
  decisions, not low-level implementation details. Use `LOG_LEVEL=DEBUG` in
  Super Linter only when actively debugging.
- **GPG key material** — never log key IDs, fingerprints, or key content in
  plain text. Use `::add-mask::` for any derived GPG values.

The Super Linter log level is configured in `.github/super_linter.env` and
defaults to `NOTICE`, which provides a balanced output suitable for CI
environments.

## Revision History

| Version | Date       | Author        | Changes          |
| :------ | :--------- | :------------ | :--------------- |
| 1.0.0   | 2026-10-29 | Homelab-Alpha | Initial release. |
