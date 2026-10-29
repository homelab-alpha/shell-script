# Code Style and Standards Guide

## Introduction

This guide helps contributors understand how we write code and structure
contributions in the shell-script repository. Following these guidelines keeps
our codebase consistent, maintainable, and easy to review. Consistency is more
important than personal preference — when in doubt, match the existing style.

<details>
  <summary>Table of Contents (click to expand)</summary>
  <p>

1. [Code Style and Standards Guide](#code-style-and-standards-guide)
   1. [Introduction](#introduction)
   2. [General Code Quality](#general-code-quality)
   3. [Formatting](#formatting)
   4. [File and Folder Conventions](#file-and-folder-conventions)
   5. [Git Guidelines](#git-guidelines)
      1. [Branch Naming Guidelines](#branch-naming-guidelines)
      2. [Commit Message Guidelines](#commit-message-guidelines)
   6. [Language-Specific Guidelines](#language-specific-guidelines)
      1. [YAML](#yaml)
      2. [Markdown](#markdown)
      3. [Environment Files](#environment-files)
      4. [JSON](#json)
      5. [Shell Scripts](#shell-scripts)
      6. [PowerShell Scripts](#powershell-scripts)
      7. [GitHub Actions Workflows](#github-actions-workflows)
   7. [Linting](#linting)
      1. [Run Super Linter locally with Docker](#run-super-linter-locally-with-docker)
   8. [Dependency Management](#dependency-management)
   9. [Security Practices](#security-practices)
   10. [Changelog Practices](#changelog-practices)

  </p>
</details>

## General Code Quality

- **Be Consistent**: Always match the existing code style. Consistency is more
  important than personal preferences.
- **Keep it Simple**: Write clear, easy-to-read code. Use names that make sense
  for variables, functions, and classes.
- **Add Comments (When Needed)**: Explain complex parts of your code briefly. Do
  not comment on what the code does — comment on _why_ it does it.
- **Break Down Tasks**: Organize your code into small, reusable pieces (modules
  or components).
- **Handle Errors**: Make sure your code can handle errors gracefully and logs
  them properly.
- **Avoid Sensitive Data**: Never hardcode secrets, tokens, passwords, or API
  keys. Use environment variables or secure configuration management instead.

## Formatting

We use **Prettier** to automatically format and check our code. These tools
ensure consistent style across the entire project. Run Prettier before
committing to avoid style-related review comments.

General formatting rules that apply across all file types:

- Use **2 spaces** for indentation (not tabs), unless a language or tool
  requires otherwise.
- Ensure files end with a **single newline**.
- Remove **trailing whitespace** on all lines.
- Keep lines to a maximum of **80 characters** where possible. Code blocks may
  extend to **120 characters**.

## File and Folder Conventions

- File and folder names use **lowercase letters** and **hyphens** as separators
  (e.g., File: `review_process.md`, `super_linter.env`; Folder: `docker`,
  `docker-compose`).
- Configuration files for tooling live in `.github/linters/`.
- GitHub Actions workflows live in `.github/workflows/`.
- Policy documents live in `.github/policies/`.
- Empty folders must contain a `.placeholder` file to prevent accidental
  deletion and to communicate intent clearly.
- The `.gitignore` includes common exclusions for databases, build artifacts,
  IDE files, logs, and temporary files. Do not commit any of these.

## Git Guidelines

These guidelines ensure our commit history is clean, readable, and easy to
follow.

### Branch Naming Guidelines

Create a new branch for every change. Name your branches to clearly describe
their purpose.

- **Format**: `type/short-description`
- **Case**: Use **lowercase** letters; separate words with **hyphens**.
- **Length**: Aim for under **50 characters** in the description part.

**Prefixes (Types):**

| Prefix      | Purpose                                |
| :---------- | :------------------------------------- |
| `feat/`     | New features                           |
| `fix/`      | Bugfixes                               |
| `docs/`     | Documentation changes                  |
| `refactor/` | Code restructuring (no feature or fix) |
| `chore/`    | General maintenance tasks              |
| `hotfix/`   | Urgent production fixes                |

**Valid examples:**

```none
feat/add-user-authentication
fix/login-page-display-error
docs/update-installation-guide
chore/update-dependencies
refactor/simplify-retrieval-logic
```

**Invalid examples:**

```none
login-error-fix      (missing type prefix)
bug123               (too vague)
Feature/AddUserAuth  (wrong casing)
update               (not descriptive)
```

### Commit Message Guidelines

Always write commit messages in **English** and follow the
[Conventional Commits](https://conventionalcommits.org) specification.

**Header (First Line):**

- **Format**: `type(scope): brief subject`
- **Types**:
  - `feat`: New feature.
  - `fix`: Bugfix.
  - `docs`: Documentation changes.
  - `style`: Code formatting (no logic change).
  - `refactor`: Code restructuring (no feature/fix).
  - `perf`: Performance improvements.
  - `test`: Test updates.
  - `chore`: General maintenance, build updates.
  - `revert`: Reverting a previous commit.
- **Scope (Optional)**: The part of the codebase affected (e.g., `core`, `data`,
  `cli`, `docs`).
- **Subject**: Written in **imperative mood** (e.g., "Add export", "Fix bug").
  Keep it **under 50 characters**. Do not end with a period.

**Body (Optional):**

- Leave a **blank line** after the header.
- Explain **what** you changed and **why** — not how.
- Use **bullet points** (`-`) for multiple details.
- Keep lines under **72 characters**.

**Examples:**

```git
feat(core): add JSON export for archived memories
```

```git
fix(retrieval): handle null reference on empty archive

- Added a null check before iterating over memory entries.
- Updated unit tests to cover the empty-archive edge case.
```

```git
docs: update installation steps in README
```

```git
chore(deps): update super-linter to v8.6.0
```

## Language-Specific Guidelines

### YAML

YAML is used for GitHub Actions workflows, issue templates, discussion
templates, label definitions, and linter configuration.

- Start every YAML file with `---`.
- Use **2-space indentation**.
- Prefer **explicit string quoting** where values could be ambiguous.
- Boolean values must be `true` or `false` (lowercase); avoid `yes`/`no`.
- Keep lines within a readable length; line-length enforcement is disabled in
  `.yamllint.yml` but clarity is still expected.
- Trailing spaces are not permitted.
- Files must end with a newline.

Linting is enforced via `.github/linters/.yaml-lint.yml` using the rules:
anchors, braces, brackets, colons, commas, hyphens, indentation, key-duplicates,
new-line-at-end-of-file, new-lines, and trailing-spaces.

### Markdown

Markdown is used for all documentation, policy files, and templates.

- Use **ATX-style headings** (`#`, `##`, etc.).
- Wrap lines at **80 characters** where possible; tables are exempt.
- Use **2-space indentation** for nested lists.
- Use fenced code blocks (` ``` `) with a language identifier.
- Do not use bare URLs — always use descriptive link text.
- Use GitHub-flavored callouts where appropriate:

  ```markdown
  > [!NOTE]
  >
  > Informational note.

  > [!IMPORTANT]
  >
  > Critical information the reader must not miss.

  > [!WARNING]
  >
  > Warns of a potential risk or breaking change.
  ```

Linting is enforced via `.github/linters/.markdown-lint.yml`. Key rules include:
2-space list indentation (MD007), 80-character line length (MD013), and standard
punctuation after headings (MD026).

### Environment Files

Environment files (`.env`-style) are validated by Super Linter's ENV linter.

- Use `UPPER_SNAKE_CASE` for all variable names.
- Comment every variable with a brief explanation of its purpose.
- Group related variables together with a section comment.
- Never commit actual secrets — use placeholder values or reference a secrets
  manager.
- The `super_linter.env` file is the only `.env`-style file committed to the
  repository (explicitly excluded from `.gitignore` via `!super_linter.env`).

### JSON

JSON is used for Renovate configuration and linter configurations such as
`.textlintrc`.

- Use **2-space indentation**.
- Ensure all keys are **double-quoted**.
- Do not include trailing commas.
- Files must be valid JSON; use a linter or formatter to verify before
  committing.

### Shell Scripts

Shell scripts are used both inside GitHub Actions workflows and as repository
tooling (for example, `init.sh`). The same conventions apply in both contexts.

- Use `set -Eeuo pipefail` at the top of every script or script block to ensure
  strict error handling.
- Use `$()` for command substitution instead of backticks.
- Quote all variable expansions: `"$VARIABLE"` not `$VARIABLE`.
- Use `[[ ]]` for conditionals in Bash.
- Prefer named variables over positional parameters for clarity.
- Write meaningful log output using `echo "::notice ..."`,
  `echo "::warning ..."`, and `echo "::error ..."` for GitHub Actions
  annotations.
- Use `::group::` and `::endgroup::` to group related log output in workflow
  runs.
- **Portability**: scripts intended to run on contributor machines (such as
  `init.sh`) must work on both Linux (GNU userland) and macOS (BSD userland).
  Detect the environment where necessary — for example, GNU `sed` accepts
  `sed -i 'expr'` while BSD `sed` requires `sed -i '' 'expr'`.
- Do not rely on features that require Bash 4+ (for example, `mapfile`,
  associative arrays) in contributor-facing scripts, because macOS still ships
  Bash 3.2 by default. Workflows running on Ubuntu runners may use Bash 4+
  features freely.

### PowerShell Scripts

PowerShell scripts are provided as Windows-native equivalents of contributor
shell scripts (for example, `init.ps1`). They must stay in sync with their Bash
counterparts — identical placeholders, identical flags, identical behavior.

- Target **Windows PowerShell 5.1** as the minimum version so the scripts run
  out of the box on Windows 10 and 11 without requiring a PowerShell 7
  installation.
- Set `$ErrorActionPreference = 'Stop'` at the top of the script to fail fast on
  unexpected errors.
- Use `[CmdletBinding()]` and a `param(...)` block with typed parameters.
- Provide a comment-based help block (`.SYNOPSIS`, `.DESCRIPTION`, `.EXAMPLE`)
  at the top so `Get-Help .\script.ps1 -Detailed` works correctly.
- Use `Write-Host` with colors for user-facing output; reserve `Write-Output`
  for values that are intended to be consumed in a pipeline.
- When reading or writing files that are expected to be consumed by Linux or
  macOS tooling, write UTF-8 **without** a byte-order mark:

  ```powershell
  $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($path, $content, $utf8NoBom)
  ```

- Avoid aliases (`ls`, `cat`, `%`, `?`) in committed scripts. Use the full
  cmdlet name (`Get-ChildItem`, `Get-Content`, `ForEach-Object`, `Where-Object`)
  for readability and portability across PowerShell editions.

### GitHub Actions Workflows

- Workflow files live in `.github/workflows/` and use the `.yml` extension.
- Every workflow must define explicit **permissions** at the job or workflow
  level, using the principle of least privilege.
- Use **pinned versions** for all actions (e.g., `actions/checkout@v6.0.2`).
- Every workflow must include a **concurrency** block to prevent duplicate runs.
- Workflows should include a **job summary** step using `$GITHUB_STEP_SUMMARY`.
- Exclude bot-triggered runs using:

  ```yaml
  if: |
    github.event.sender.type != 'Bot' &&
    !contains(github.actor, '[bot]')
  ```

- Set a `timeout-minutes` on all jobs to prevent runaway executions.
- Infrastructure-as-code security checks (Checkov) skip `CKV_TF_1` and
  `CKV_GHA_7` as configured in `.github/linters/.checkov.yaml`.

For a complete reference on workflow naming, logging, and job summary
requirements, see
[`.github/policies/github_actions.md`](./.github/policies/github_actions.md).

## Linting

This repository lints in two stages.

- **Pull requests** run `npm run lint` (`lint_pull_request.yml`,
  `scripts/lint.sh`) on the changed files: Prettier, textlint terminology, and
  merge conflict markers. Run `npm run lint:fix` to repair formatting and
  terminology locally.
- **Pushes to `main`** run
  [Super Linter](https://github.com/super-linter/super-linter) across all file
  types. It adds actionlint, Gitleaks, Checkov, and the other linters.

The following linters are currently active (configured in
`.github/super_linter.env`):

| Linter                     | Scope                                    |
| :------------------------- | :--------------------------------------- |
| Checkov                    | Infrastructure-as-code security scanning |
| ENV                        | Environment file validation              |
| GitHub Actions             | Workflow file validation                 |
| Gitleaks                   | Secret and credential detection          |
| Git merge conflict markers | Unresolved merge conflict detection      |
| Markdown                   | Markdown style and structure             |
| Natural Language           | Terminology and grammar checking         |
| Pre-commit                 | Pre-commit hook configuration validation |
| Renovate                   | Dependency configuration validation      |
| YAML                       | YAML structure and style                 |

Linting configuration files are stored in `.github/linters/`:

| File                | Purpose                            |
| :------------------ | :--------------------------------- |
| `.checkov.yaml`     | Checkov skip rules                 |
| `.markdownlint.yml` | Markdown linting rules             |
| `.textlintrc`       | Natural language terminology rules |
| `.yamllint.yml`     | YAML linting rules                 |

> [!TIP]
>
> Run Super Linter locally before submitting a pull request to catch issues
> early and avoid unnecessary review cycles.

### Run Super Linter locally with Docker

> [!NOTE]
>
> Run Super Linter in the ROOT DIR ~shell-script

```bash
#!/bin/bash

# Filename:    super_linter.sh
# Author:      Homelab-Alpha
# Date:        2026-10-29
# Version:     1.0.0

# Description: Executes GitHub Super-Linter locally within a Docker container.
#              Ensures project-specific configurations are respected and manages
#              clean-up of temporary Docker artifacts.

set -Eeuo pipefail

# Verify the presence of the environment file to prevent Docker execution errors.
if [[ ! -f ".github/super_linter.env" ]]; then
  echo "::error::Missing .github/super_linter.env — cannot start Super Linter."
  exit 1
fi

docker run --rm \
  --env-file .github/super_linter.env \
  -e RUN_LOCAL=true \
  -e DEFAULT_WORKSPACE=/tmp/lint \
  -v "$(pwd):/tmp/lint" \
  ghcr.io/super-linter/super-linter:latest
```

## Dependency Management

Dependencies are managed automatically by **Renovate** (see
`.github/renovate.json`).

- All direct dependencies are pinned to an exact version.
- Renovate proposes updates on a schedule and at a controlled concurrency.
- Patch, pin, and digest updates auto-merge during business hours.
- Minor and major updates require manual review.
- Security updates are prioritized and labelled automatically.
- OSV vulnerability alerts are enabled.

Do not manually update pinned dependency versions in workflow files unless there
is a specific reason. Let Renovate handle routine updates.

## Security Practices

- **No secrets in code**: Never commit API keys, passwords, tokens, or any
  sensitive credentials. Use environment variables or a secrets manager.
- **Gitleaks** runs on every push to detect accidentally committed secrets.
  False positives can be allowlisted in `.gitleaksignore`.
- **Checkov** scans infrastructure-as-code files for misconfigurations.
- Follow the [Security Policy](./SECURITY.md) when reporting vulnerabilities.
- Keep dependencies up to date to minimize exposure to known CVEs — Renovate
  handles this automatically.
- New code is reviewed by maintainers before merging into `main` to catch
  potential security issues early.

## Changelog Practices

This project follows the
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) format. All
contributors are expected to update `CHANGELOG.md` under the `[Unreleased]`
section when submitting a pull request.

**Categories to use (in order):**

| Category     | When to use                                       |
| :----------- | :------------------------------------------------ |
| `Added`      | New features or capabilities                      |
| `Changed`    | Changes to existing functionality                 |
| `Deprecated` | Features that will be removed in a future release |
| `Removed`    | Features removed in this release                  |
| `Fixed`      | Bugfixes                                          |
| `Security`   | Security fixes or vulnerability disclosures       |

**Rules:**

- Write entries in **plain English** from the user's perspective — not the
  developer's perspective.
- Use imperative mood: "Add export command", not "Added export command".
- Keep entries concise; one line per change where possible.
- Reference the relevant issue or pull request number where applicable (e.g.,
  `Fix null reference in retrieval (#42)`).
- Do not delete the empty category headers in `[Unreleased]` — they signal
  intent and are cleaned up automatically at release time.

---

For contribution workflows, branch conventions, and pull request guidelines, see
[CONTRIBUTING.md](./CONTRIBUTING.md).
