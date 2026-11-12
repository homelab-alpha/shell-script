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
      6. [GitHub Actions Workflows](#github-actions-workflows)
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

- File and folder names use **lowercase letters**. Files use **underscores** as
  separators (e.g., `review_process.md`, `super_linter.env`); folders use
  **hyphens** (e.g., `docker`, `docker-compose`). Root community files keep
  their GitHub names (e.g., `README.md`).
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
  - `build`: Build tool or dependency changes.
  - `ci`: CI configuration and workflow changes.
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
  `.yaml-lint.yml` but clarity is still expected.
- Trailing spaces are not permitted.
- Files must end with a newline.

The yamllint hook of `.pre-commit-config.yaml` uses
`.github/linters/.yaml-lint.yml` with the rules: anchors, brackets, colons,
commas, empty-lines, hyphens, key-duplicates, new-line-at-end-of-file,
new-lines, and trailing-spaces. The rules for braces and indentation are off,
because Prettier decides those (in `labels.yml` it writes lists of mappings in a
way that yamllint rejects).

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

The markdownlint hook of `.pre-commit-config.yaml` uses
`.github/linters/.markdown-lint.yml`. Key rules include: 2-space list
indentation (MD007) and standard punctuation after headings (MD026). The rule
for line length (MD013) is off, because Prettier wraps the prose at 80
characters.

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
  features freely. The exception is `.github/scripts/lint.sh` (`npm run lint`):
  it needs Bash 4 or higher, and it stops with a message when Bash is older.

### GitHub Actions Workflows

- Workflow files live in `.github/workflows/` and use the `.yml` extension.
- Every workflow must define explicit **permissions** at the job or workflow
  level, using the principle of least privilege.
- Pin every action to a full **commit SHA**, followed by a comment with the
  version (e.g.,
  `actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1 # v7.0.1`). Tags
  such as `@v7` are not allowed.
- Every workflow must include a **concurrency** block to prevent duplicate runs.
- Workflows should include a **job summary** step using `$GITHUB_STEP_SUMMARY`.
- Do not skip bot-triggered runs: workflows run for bots in the same way as for
  people.

- Set a `timeout-minutes` on all jobs to prevent runaway executions.
- Infrastructure-as-code security checks (Checkov) skip `CKV_TF_1` and
  `CKV_GHA_7` as configured in `.github/linters/.checkov.yaml`.

For a complete reference on workflow naming, logging, and job summary
requirements, see
[`.github/policies/github_actions.md`](../policies/github_actions.md).

## Linting

This repository lints in two stages.

- **Pull requests** run `npm run lint` (`lint_pull_request.yml`,
  `.github/scripts/lint.sh`) on the changed files: Prettier, textlint
  terminology, and merge conflict markers. Run `npm run lint:fix` to repair
  formatting and terminology locally.
- **Pushes to `main`** run
  [Super Linter](https://github.com/super-linter/super-linter) across all file
  types. It adds actionlint, Gitleaks, Checkov, and the other linters.

The following linters are currently active (configured in
`.github/super_linter.env`):

| Linter                     | Scope                                    |
| :------------------------- | :--------------------------------------- |
| Bash                       | Shell script validation                  |
| Bash Exec                  | Executable bit of shell scripts          |
| Checkov                    | Infrastructure-as-code security scanning |
| ENV                        | Environment file validation              |
| GitHub Actions             | Workflow file validation                 |
| Gitleaks                   | Secret and credential detection          |
| Git merge conflict markers | Unresolved merge conflict detection      |
| JSON (Prettier)            | JSON formatting                          |
| Markdown (Prettier)        | Markdown formatting                      |
| Natural Language           | Terminology and grammar checking         |
| Pre-commit                 | Pre-commit hook configuration validation |
| Renovate                   | Dependency configuration validation      |
| YAML (Prettier)            | YAML formatting                          |

Linting configuration files are stored in `.github/linters/`:

| File                 | Purpose                                                    |
| :------------------- | :--------------------------------------------------------- |
| `.checkov.yaml`      | Checkov skip rules                                         |
| `.gitleaks.toml`     | Gitleaks configuration                                     |
| `.markdown-lint.yml` | Markdown linting rules (pre-commit hook)                   |
| `.textlintrc`        | Natural language terminology rules                         |
| `.yaml-lint.yml`     | YAML linting rules (pre-commit hook)                       |
| `actionlint.yml`     | Ignored shellcheck messages in workflow files (actionlint) |

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
- Renovate proposes updates at any time, without a schedule or a limit on open
  pull requests (the time zone is Europe/Amsterdam).
- Renovate groups updates by kind (for example `github actions (minor)`), so a
  week of updates is a few pull requests. Major updates stay separate.
- Renovate automerges patch, pin, and digest updates of GitHub Actions,
  pre-commit hooks, and npm dev dependencies once the checks pass. A maintainer
  reviews and merges every other update. Security updates are never automerged.
- The pull requests of Renovate are not put back to draft by Pull Request
  Automation, because a draft cannot automerge.
- Indirect Go modules (such as Hugo modules) are updated too, so that `go.mod`
  and `go.sum` stay current.
- Container images are pinned to a digest (`docker:pinDigests`). The first
  digest pins of all images arrive in one pull request.
- The hook revisions in `.pre-commit-config.yaml` are pinned to a full commit
  SHA, with the version in a `# frozen:` comment. Renovate keeps both in sync
  (`:enablePreCommit`).
- Security updates are prioritized and labelled automatically.
- OSV vulnerability alerts are enabled.

Do not manually update pinned dependency versions in workflow files unless there
is a specific reason. Let Renovate handle routine updates.

## Security Practices

- **No secrets in code**: Never commit API keys, passwords, tokens, or any
  sensitive credentials. Use environment variables or a secrets manager.
- **Gitleaks** runs on every push to `main` to detect accidentally committed
  secrets. False positives can be allowlisted in `.gitleaksignore`.
- **Checkov** scans infrastructure-as-code files for misconfigurations.
- Follow the [Security Policy](../../SECURITY.md) when reporting
  vulnerabilities.
- Keep dependencies up to date to minimize exposure to known CVEs — Renovate
  handles this automatically.
- New code is reviewed by maintainers before merging into `main` to catch
  potential security issues early.

## Changelog Practices

This project follows the
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) format. The Update
Changelog workflow runs every 8 hours (and by hand) and adds an entry to
`CHANGELOG.md` under the `[Unreleased]` section for every pull request merged
since the last release:
`- type(scope): subject [1a2b3c4](commit link) by [@anna](profile link)`. The
title of the pull request is the text, so write it as a conventional commit. The
entry can be corrected by hand afterwards. An entry is skipped when its commit
link (or an older `(#N)`) is already in the file, and for pull requests of a
bot. All entries of one run go in one commit.

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
- In an entry that you write by hand, reference the relevant issue or pull
  request number where applicable (e.g.,
  `Fix null reference in retrieval (#42)`).
- Empty category headers in `[Unreleased]` are fine: Release Manager leaves the
  categories without entries out of the released section.

**Release notes:** the Release Manager workflow writes the section of a release
and the notes of the GitHub release from the text under `[Unreleased]`. When
that text has no entries, it lists the pull requests that were merged since the
last tag, one entry per pull request. The title of the pull request is the text,
so write it as a conventional commit (`feat(app): add export`). An entry has the
same format as an entry of `CHANGELOG.md`:
`- feat(app): add export [1a2b3c4](commit link) by [@anna](profile link)`. The
type decides the category:

| Type of the title                               | Category   |
| :---------------------------------------------- | :--------- |
| `feat`                                          | `Added`    |
| `fix`                                           | `Fixed`    |
| `fix(security)`                                 | `Security` |
| `refactor`, `perf`, `revert`                    | `Changed`  |
| `docs`, `chore`, `ci`, `build`, `test`, `style` | `Changed`  |
| any other type                                  | `Changed`  |
| no type                                         | `Changed`  |

The last three rows only count for pull requests of a person. Pull requests of a
bot (the release, the contributors list, dependency updates) are left out. A `!`
after the type marks a breaking change. A commit that was pushed to `main`
without a pull request is listed on its own, under `Changed` when its subject
has no type.

The pull request list is only used when `[Unreleased]` has no entries. Text that
you write under `[Unreleased]` replaces it, so add every change by hand in that
case. Because Update Changelog runs every 8 hours, start it by hand before you
run Release Manager; a pull request that was merged a few hours earlier is
otherwise missing from the release. **Squash and merge** is the standard (see
[the review process](../policies/review_process.md#merge-strategy)); **Create a
merge commit** works too. **Rebase and merge** leaves no pull request in the
history, so the pull request is not listed.

---

For contribution workflows, branch conventions, and pull request guidelines, see
[CONTRIBUTING.md](../../CONTRIBUTING.md).
