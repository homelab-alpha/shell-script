# Contributing to shell-script

Thank you for your interest in contributing to **shell-script**! We welcome
contributions of all kinds — from bug reports and feature requests to code
improvements and documentation updates. This guide will walk you through
everything you need to know to contribute effectively.

> [!IMPORTANT]
>
> Please read this document carefully before submitting any contributions. Not
> all pull requests will be accepted. Following these guidelines ensures a
> smooth and efficient review process for everyone involved.

<details>
  <summary>Table of Contents (click to expand)</summary>
  <p>

1. [Contributing to shell-script](#contributing-to-shell-script)
   1. [Code of Conduct](#code-of-conduct)
   2. [Getting Started](#getting-started)
      1. [Prerequisites](#prerequisites)
      2. [Fork and Clone](#fork-and-clone)
   3. [How to Contribute](#how-to-contribute)
      1. [Reporting Bugs](#reporting-bugs)
      2. [Reporting Security Vulnerabilities](#reporting-security-vulnerabilities)
      3. [Requesting Features](#requesting-features)
      4. [Improving Documentation](#improving-documentation)
      5. [Submitting Code Changes](#submitting-code-changes)
   4. [Development Guidelines](#development-guidelines)
      1. [Branch Naming](#branch-naming)
      2. [Commit Messages](#commit-messages)
      3. [Code Style](#code-style)
      4. [Linting](#linting)
      5. [Changelog](#changelog)
   5. [Pull Requests](#pull-requests)
      1. [Before You Submit](#before-you-submit)
      2. [Submitting a Pull Request](#submitting-a-pull-request)
      3. [Review Process](#review-process)
   6. [Community](#community)

  </p>
</details>

## Code of Conduct

This project follows the
[Contributor Covenant 3.0 Code of Conduct](./CODE_OF_CONDUCT.md). By
participating in this project, you agree to abide by its terms. Please treat
everyone with respect and help us maintain a welcoming and inclusive community.

To report a possible Code of Conduct violation, **send an email to the
[Homelab-Alpha team](mailto:homelab.api@gmail.com)**.

## Getting Started

### Prerequisites

Before contributing, make sure you have the following set up:

- **Git**: For version control.
- A **GitHub account**: Required to submit issues and pull requests.
- Familiarity with the project's purpose — read the [README](./README.md) to
  understand what shell-script is and how it works.

### Fork and Clone

1. Fork the repository by clicking **Fork** at the top of the
   [GitHub page](https://github.com/homelab-alpha/shell-script).
2. Clone your fork locally:

   ```bash
   git clone https://github.com/ < your-username > /shell-script.git
   cd shell-script
   ```

3. Add the upstream remote so you can keep your fork up to date:

   ```bash
   git remote add upstream https://github.com/homelab-alpha/shell-script.git
   ```

4. Keep your fork in sync before starting any work:

   ```bash
   git fetch upstream
   git checkout main
   git merge upstream/main
   ```

## How to Contribute

### Reporting Bugs

If you encounter a bug, please
[open a Bug Report](https://github.com/homelab-alpha/shell-script/issues/new?template=bug_report.yml)
using our issue template. Before submitting, search the
[existing issues](https://github.com/homelab-alpha/shell-script/issues) to avoid
duplicates.

A good bug report includes:

- A clear and descriptive title.
- Steps to reproduce the issue.
- What you expected to happen vs. what actually happened.
- Relevant logs or error messages.
- Your environment details (OS, software version, runtime, etc.).

### Reporting Security Vulnerabilities

> [!WARNING]
>
> Do **not** report security vulnerabilities through public GitHub issues.

Please follow the process outlined in our [Security Policy](./SECURITY.md).
Submit a private
[GitHub Security Advisory](https://github.com/homelab-alpha/shell-script/security/advisories/new)
and then notify the team by
[opening a Security Issue](https://github.com/homelab-alpha/shell-script/issues/new?template=security_report.yml)
with only the advisory URL — no sensitive details in the issue itself.

We aim to respond to vulnerability reports within **72 hours**.

### Requesting Features

Feature requests are managed through
[GitHub Discussions](https://github.com/homelab-alpha/shell-script/discussions/categories/feature-request).
Please search existing discussions before opening a new one, and provide as much
context as possible: the problem you are solving, your proposed solution, and
any alternatives you have considered.

### Improving Documentation

Documentation improvements are always appreciated. This includes fixing typos,
clarifying existing content, or adding missing information. Follow the same
branch and commit conventions described below, and use the `docs` commit type.

### Submitting Code Changes

Code contributions are welcome! Please make sure your changes align with the
project's goals and follow the guidelines in this document before opening a pull
request.

## Development Guidelines

### Branch Naming

Create a new branch for every contribution. Branches must follow this format:

```none
type/short-description
```

- Use **lowercase** letters only.
- Separate words with **hyphens**.
- Keep the description **brief and specific** (under 50 characters).

| Prefix      | Purpose                             |
| :---------- | :---------------------------------- |
| `feat/`     | New features                        |
| `fix/`      | Bugfixes                            |
| `docs/`     | Documentation changes               |
| `refactor/` | Code restructuring (no feature/fix) |
| `chore/`    | General maintenance tasks           |
| `hotfix/`   | Urgent production fixes             |

**Valid examples:**

```none
feat/add-json-export
fix/retrieval-null-reference
docs/update-readme-installation
chore/update-dependencies
```

**Invalid examples:**

```none
bugfix-123          (missing type prefix)
Feature/AddExport   (wrong casing)
update              (too vague)
```

### Commit Messages

All commit messages must be written in **English** and follow the
[Conventional Commits](https://conventionalcommits.org) specification.

**Format:**

```none
type(scope): brief subject
```

- The **type** must be one of: `feat`, `fix`, `docs`, `style`, `refactor`,
  `perf`, `test`, `chore`, `revert`.
- The **scope** is optional and indicates the part of the codebase affected
  (e.g., `core`, `data`, `cli`).
- The **subject** must be written in imperative mood and kept under **50
  characters**.

**Optional body:**

- Leave a blank line after the header.
- Explain _what_ changed and _why_ (not how).
- Use bullet points (`-`) for multiple items.
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

### Code Style

We use **Prettier** for automatic code formatting. Please ensure your code is
consistently formatted before committing.

Follow these general principles:

- **Consistency**: Match the existing code style.
- **Simplicity**: Write clear, readable code with meaningful names.
- **Comments**: Add comments only to explain complex logic, not obvious steps.
- **Modularity**: Break code into small, reusable components or functions.
- **Error Handling**: Handle errors gracefully and log them appropriately.

For the full style reference, see
[code_style_and_standards_guides.md](./docs/code_style_and_standards_guides.md).

### Linting

This repository uses
[Super Linter](https://github.com/super-linter/super-linter) to enforce code
quality. The following linters are active:

- **Checkov** — infrastructure-as-code security scanning
- **ENV** — environment file validation
- **GitHub Actions** — workflow file validation
- **Gitleaks** — secret detection
- **Git merge conflict markers** — conflict detection
- **Markdown** — Markdown linting
- **Natural Language** — terminology and grammar checking
- **Pre-commit** — pre-commit hook validation
- **Renovate** — dependency configuration validation
- **YAML** — YAML linting

Run linting locally before submitting a pull request to catch issues early.
Linting runs automatically on all pushes and pull requests targeting `main`.

### Changelog

Update `CHANGELOG.md` under the `[Unreleased]` section as part of every pull
request that changes behavior. Use the appropriate category: `Added`, `Changed`,
`Deprecated`, `Removed`, `Fixed`, or `Security`.

Write entries from the user's perspective in imperative mood:
`Add export command`, not `Added export command`.

See
[code_style_and_standards_guides.md](./docs/code_style_and_standards_guides.md#changelog-practices)
for the full changelog conventions.

## Pull Requests

### Before You Submit

- [ ] Your branch follows the [branch naming convention](#branch-naming).
- [ ] Your commits follow the [commit message convention](#commit-messages).
- [ ] Your code follows the [code style guidelines](#code-style).
- [ ] You have tested your changes locally.
- [ ] Linting passes locally.
- [ ] You have updated any relevant documentation.
- [ ] You have updated `CHANGELOG.md` under `[Unreleased]`.
- [ ] Your pull request targets the `main` branch.

### Submitting a Pull Request

1. Push your branch to your fork:

   ```bash
   git push origin feat/your-feature-name
   ```

2. Open a pull request against the `main` branch of the upstream repository.
3. Fill in the [pull request template](./.github/pull_request_template.md)
   completely. Do not remove any sections.
4. Assign relevant labels if possible.
5. Wait for a maintainer to acknowledge your pull request — we aim to respond
   within **5 business days**.

> [!NOTE]
>
> Pull requests that do not follow the template or guidelines may be closed
> without review.

### Review Process

All pull requests go through a structured review process to ensure code quality
and consistency. Here is what to expect:

- A maintainer will review your pull request and may request changes.
- Address all review comments by pushing additional commits to your branch.
- Once all discussions are resolved and checks pass, a maintainer will approve
  and merge your pull request.
- Straightforward contributions are typically reviewed within **two weeks**.
  Complex changes may take longer, and we will communicate any delays.

Dependency updates (patch, pin, digest) are handled automatically by
[Renovate](https://docs.renovatebot.com/) and are automerged when all checks
pass. Major and minor dependency updates require manual review.

For a detailed overview of the review workflow, see
[`.github/policies/review_process.md`](./.github/policies/review_process.md).

## Community

We would love to hear from you! Here are the places where you can connect:

| Channel                                                                                                        | Purpose                                |
| :------------------------------------------------------------------------------------------------------------- | :------------------------------------- |
| [Announcements](https://github.com/homelab-alpha/shell-script/discussions/categories/announcements)            | Stay up to date with releases and news |
| [Feature Requests](https://github.com/homelab-alpha/shell-script/discussions/categories/feature-request)       | Propose new features                   |
| [Feedback](https://github.com/homelab-alpha/shell-script/discussions/categories/feedback)                      | Share thoughts and suggestions         |
| [Help & Support](https://github.com/homelab-alpha/shell-script/discussions/categories/help-support)            | Ask questions and get help             |
| [Q&A](https://github.com/homelab-alpha/shell-script/discussions/categories/q-a)                                | Get answers from the community         |
| [General Discussion](https://github.com/homelab-alpha/homelab-alpha/discussions/categories/general-discussion) | Off-topic conversations                |

For information about becoming a maintainer, see
[MAINTAINERS.md](./MAINTAINERS.md).

---

Thank you for taking the time to contribute to shell-script. Every contribution
— no matter how small — helps the project grow and improve. 🙏
