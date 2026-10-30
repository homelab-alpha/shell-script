<!-- markdownlint-disable MD041 -->

[![Super Linter](https://github.com/homelab-alpha/shell-script/actions/workflows/super_linter.yml/badge.svg)](https://github.com/homelab-alpha/shell-script/actions/workflows/super_linter.yml)
[![CodeQL](https://github.com/homelab-alpha/shell-script/actions/workflows/codeql.yml/badge.svg)](https://github.com/homelab-alpha/shell-script/actions/workflows/codeql.yml)
[![Last commit](https://img.shields.io/github/last-commit/homelab-alpha/shell-script?style=flat&logo=github&logoColor=96a1a9&labelColor=313A41&color=3955CD&label=Last%20commit&cacheSeconds=3600)](https://github.com/homelab-alpha/shell-script/commits/main/)
[![Repo Size](https://img.shields.io/github/repo-size/homelab-alpha/shell-script?style=flat&logo=github&logoColor=96a1a9&labelColor=313A41&color=3955CD&label=Repo%20size&cacheSeconds=3600)](https://github.com/homelab-alpha/shell-script/tree/main)
[![Changelog](https://img.shields.io/badge/Changelog-Keep%20a%20Changelog%20v1.1.0-313A41?style=flat&logo=keepachangelog&logoColor=96a1a9&&labelColor=313A41&color=3955CD)](https://github.com/homelab-alpha/shell-script/blob/main/CHANGELOG.md)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-3.0-313A41?style=flat&logo=contributorcovenant&logoColor=96a1a9&&labelColor=313A41&color=3955CD)](https://github.com/homelab-alpha/shell-script/blob/main/CODE_OF_CONDUCT.md)
[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-313A41?style=flat&logo=conventionalcommits&logoColor=96a1a9&&labelColor=313A41&color=3955CD)](https://conventionalcommits.org)
[![Semantic Versioning](https://img.shields.io/badge/SemVer-2.0.0-313A41?style=flat&logo=semver&logoColor=96a1a9&&labelColor=313A41&color=3955CD)](https://semver.org/spec/v2.0.0.html)
[![License](https://img.shields.io/github/license/homelab-alpha/shell-script?style=flat&logo=creativecommons&logoColor=96a1a9&labelColor=313A41&color=3955CD&label=License)](https://github.com/homelab-alpha/shell-script/blob/main/LICENSE)

# Shell Script

A collection of shell scripts and shell functions for system automation and
optimization.

<details>
  <summary>Table of Contents (click to expand)</summary>
  <p>

1. [Shell Script](#shell-script)
   1. [Description](#description)
   2. [Features](#features)
      1. [Scripts](#scripts)
      2. [Functions](#functions)
   3. [Project Status](#project-status)
   4. [Getting Started](#getting-started)
      1. [Requirements](#requirements)
      2. [Installation](#installation)
   5. [Development](#development)
   6. [Project Structure](#project-structure)
   7. [CI/CD and Automation](#cicd-and-automation)
      1. [Workflows](#workflows)
      2. [Linting](#linting)
      3. [Dependency Management](#dependency-management)
   8. [Policies and Standards](#policies-and-standards)
   9. [Working with Claude](#working-with-claude)
   10. [Known Issues](#known-issues)
       1. [Currently Being Addressed](#currently-being-addressed)
   11. [Contributing](#contributing)
   12. [Support](#support)
   13. [Security](#security)
   14. [Roadmap](#roadmap)
   15. [License](#license)

  </p>
</details>

## Description

**shell-script** is a collection of Bash scripts for a Linux homelab. The
scripts install development tools, scaffold Docker projects, generate keys,
check the health of a system, and automate Git maintenance. The repository also
holds a set of small shell functions for everyday use in the terminal, and
development material for Uptime Kuma and Speedtest Tracker.

Each script starts with a header that describes its purpose, version, and usage.
More documentation is on the
[Homelab-Alpha documentation site](https://homelab-alpha.nl/docs/shell-script/).

## Features

- **Scripts** — 21 Bash scripts in `scripts/`, from tool installers to Docker
  project generators.
- **Shell functions** — 10 functions in `functions/` that you can source in your
  shell.
- **Development material** — Custom Speedtest Tracker widgets and an Uptime Kuma
  Slack notification provider in `develop/`.

### Scripts

| Script                                | Purpose                                                                                                                |
| :------------------------------------ | :--------------------------------------------------------------------------------------------------------------------- |
| `audio_converter.sh`                  | Converts m4a, mp3, and wma files to MP3 (128k, 44.1 kHz, stereo).                                                      |
| `check_pi_throttling.sh`              | Checks the throttling status of a Raspberry Pi with `vcgencmd`.                                                        |
| `check_system_info.sh`                | Shows uptime, hardware information, temperature, and `systemctl` status.                                               |
| `clearcache.sh`                       | Drops clean caches and reclaimable slab objects such as dentries and inodes.                                           |
| `cronjob_template.sh`                 | Cronjob template that pings a monitoring server for a health check.                                                    |
| `github_pr_inspector.sh`              | Interactive menu that builds `.patch` and `.diff` links for GitHub pull requests.                                      |
| `gnome_keybindings_backup_restore.sh` | Backs up and restores GNOME keybindings.                                                                               |
| `gpg_keygen_script.sh`                | Generates a GPG key pair.                                                                                              |
| `install_latest_dart_sass.sh`         | Installs the latest Dart Sass to `/usr/local/dart-sass`.                                                               |
| `install_latest_go.sh`                | Installs the latest Go to `/usr/local/go`.                                                                             |
| `install_latest_hugo.sh`              | Downloads and installs the latest Hugo release.                                                                        |
| `install_latest_jetbrains_mono.sh`    | Installs the latest JetBrains Mono font in the system-wide fonts directory.                                            |
| `install_latest_protoc.sh`            | Installs the latest protoc (Protocol Buffers) to `/usr/local/protoc`.                                                  |
| `maintain_git_repo.sh`                | Automates the maintenance of a Git repository.                                                                         |
| `new_docker_compose_file.sh`          | Creates a Docker Compose environment (directories, compose files, and database and app configuration) from user input. |
| `new_docker_project.sh`               | Creates a Docker container directory structure and configuration files from user input.                                |
| `ssh_keygen_script.sh`                | Generates and converts SSH key pairs.                                                                                  |
| `super_linter.sh`                     | Runs GitHub Super Linter locally in a Docker container.                                                                |
| `sync_containers.sh`                  | Synchronizes Docker container images from a predefined list, with a disk space check and a log file.                   |
| `uptime_kuma_pr_test_v2.sh`           | Tests Uptime Kuma 2.x pull requests in a Docker container.                                                             |
| `user_accounts_info.sh`               | Lists system and normal user accounts.                                                                                 |

### Functions

| File                     | Function                       | Purpose                                                                           |
| :----------------------- | :----------------------------- | :-------------------------------------------------------------------------------- |
| `cpg.sh`                 | `cpg`                          | Copies a file or directory, recursively when needed.                              |
| `dns_check.sh`           | `dns-checker`                  | Checks network connectivity and DNS server availability.                          |
| `encrypt_and_decrypt.sh` | `file-encrypt`, `file-decrypt` | Encrypts and decrypts files or directories with AES-256 through OpenSSL.          |
| `ex.sh`                  | `ex`                           | Extracts archives (tar, zip, gzip, bzip2, rar, and more) by detecting the format. |
| `health_check.sh`        | `health-check`                 | Checks the availability of a URL over HTTP and HTTPS.                             |
| `mkdirg.sh`              | `mkdirg`                       | Creates a directory and enters it.                                                |
| `mvg.sh`                 | `mvg`                          | Moves a file or directory and enters the destination.                             |
| `targzip.sh`             | `targzip`                      | Creates a gzip-compressed tar archive.                                            |
| `tarzip.sh`              | `tarzip`                       | Creates a zip archive of a folder.                                                |
| `up.sh`                  | `up`                           | Moves up a number of directory levels.                                            |

## Project Status

> [!NOTE]
>
> **Status:** Maintained
>
> The repository is maintained and updated through pull requests and automated
> dependency updates. Planned work is listed in [ROADMAP.md](./ROADMAP.md).

## Getting Started

### Requirements

A Linux system with Bash. Some scripts need extra tools, for example Docker,
Git, or OpenSSL. Check the header of a script before you run it.

### Installation

```bash
git clone https://github.com/homelab-alpha/shell-script.git
cd shell-script
chmod +x scripts/<script>.sh
./scripts/<script>.sh
```

To use a function, source its file in your shell, for example
`source functions/up.sh`.

## Development

Set up the dev tooling on any computer. It needs Node.js 24 (see `engines` in
`package.json`):

```bash
git clone https://github.com/homelab-alpha/shell-script.git
cd shell-script
npm ci
npm run lint
```

Linting has two parts. Every pull request runs `npm run lint` (Prettier,
textlint terminology, and merge conflict markers on the changed files), which
you can also run locally. `npm run lint:fix` repairs formatting and terminology
for you. Every push to `main` runs the full Super Linter, which you can run
locally with Docker:

```bash
docker run --rm -e RUN_LOCAL=true -e USE_FIND_ALGORITHM=true \
  -e VALIDATE_ALL_CODEBASE=true --env-file .github/super_linter.env \
  -v "$PWD":/tmp/lint ghcr.io/super-linter/super-linter:v9.0.0
```

For quick formatting of a single file, `npx prettier --write <file>` uses the
same `.prettierrc`.

## Project Structure

```treeview
shell-script/
├── .claude/                                    # Claude Code project settings
│   └── settings.json                           # Shared permissions for Claude Code
├── .github/                                    # GitHub-specific configuration and automation
│   ├── DISCUSSION_TEMPLATE/                    # GitHub Discussions templates
│   │   ├── announcements.yml                   # Template for announcements
│   │   ├── feature-request.yml                 # Template for feature requests
│   │   ├── feedback.yml                        # Template for feedback
│   │   ├── help-support.yml                    # Template for help and support
│   │   └── q-a.yml                             # Template for Q&A
│   ├── ISSUE_TEMPLATE/                         # GitHub issue templates
│   │   ├── bug_report.yml                      # Template for bug reports
│   │   ├── config.yml                          # Issue template configuration
│   │   ├── i18n_issue.yml                      # Template for translation & localization
│   │   └── security_report.yml                 # Template for security issues
│   ├── linters/                                # Configuration files for Super Linter
│   │   ├── .checkov.yaml                       # Infrastructure-as-code security rules
│   │   ├── .gitleaks.toml                      # Gitleaks secret scanning configuration
│   │   ├── .markdown-lint.yml                  # Markdown linting rules
│   │   ├── .powershell-psscriptanalyzer.psd1   # PowerShell static analysis rules
│   │   ├── .textlintrc                         # Text/grammar linting configuration
│   │   ├── .yaml-lint.yml                      # YAML linting rules
│   │   └── actionlint.yml                      # GitHub Actions workflow linting rules
│   ├── policies/                               # Internal policies and documentation
│   │   ├── github_actions.md                   # Workflow standards (ENG-CI-001)
│   │   ├── labels.md                           # Label color strategy and rules
│   │   ├── logs.md                             # Logging policies and practices
│   │   ├── review_process.md                   # Code review process
│   │   ├── security.md                         # Security policy
│   │   └── tests.md                            # Testing policy
│   ├── workflows/                              # GitHub Actions workflows
│   │   ├── codeql.yml                          # CodeQL security analysis
│   │   ├── contributors.yml                    # Contributors list generator
│   │   ├── dependency_review.yml               # Dependency review
│   │   ├── housekeeping.yml                    # Cache and run cleanup
│   │   ├── issues.yml                          # Issue automation
│   │   ├── labels.yml                          # Label synchronization
│   │   ├── lint_pull_request.yml               # npm linting for pull requests
│   │   ├── merge_conflicts.yml                 # Merge conflict detection
│   │   ├── milestone_manager.yml               # Milestone automation
│   │   ├── pull_request.yml                    # Pull request automation
│   │   ├── release_manager.yml                 # Release automation
│   │   ├── signing_test.yml                    # Test API-based commit and tag signing
│   │   ├── stale_issues_and_pull_requests.yml  # Stale issue management
│   │   ├── super_linter.yml                    # Super Linter
│   │   └── unreproducible_issues.yml           # Unreproducible issue management
│   ├── CODEOWNERS                              # Code ownership definitions
│   ├── labels.yml                              # Repository label definitions
│   ├── pull_request_template.md                # Pull request template
│   ├── renovate.json                           # Renovate dependency automation
│   └── super_linter.env                        # Super Linter environment configuration
├── develop/                                    # Development material for Docker deployments
│   ├── speedtest-tracker/                      # Custom PHP widgets and dashboard for Speedtest Tracker (15 files)
│   └── uptime-kuma/                            # Custom Slack notification provider for Uptime Kuma (2 files)
├── docs/                                       # Project documentation (API, usage, guides)
│   └── code_style_and_standards_guides.md      # Coding standards and style guidelines
├── functions/                                  # Shell functions to source in your shell
│   ├── cpg.sh                                  # Copies a file or directory, recursively when needed.
│   ├── dns_check.sh                            # Checks network connectivity and DNS server availability.
│   ├── encrypt_and_decrypt.sh                  # Encrypts and decrypts files or directories with AES-256 through OpenSSL.
│   ├── ex.sh                                   # Extracts archives (tar, zip, gzip, bzip2, rar, and more) by detecting the format.
│   ├── health_check.sh                         # Checks the availability of a URL over HTTP and HTTPS.
│   ├── mkdirg.sh                               # Creates a directory and enters it.
│   ├── mvg.sh                                  # Moves a file or directory and enters the destination.
│   ├── targzip.sh                              # Creates a gzip-compressed tar archive.
│   ├── tarzip.sh                               # Creates a zip archive of a folder.
│   └── up.sh                                   # Moves up a number of directory levels.
├── scripts/                                    # Utility and automation shell scripts
│   ├── audio_converter.sh                      # Converts m4a, mp3, and wma files to MP3
│   ├── check_pi_throttling.sh                  # Checks the throttling status of a Raspberry Pi with `vcgencmd`
│   ├── check_system_info.sh                    # Shows uptime, hardware information, temperature, and `systemctl` status
│   ├── clearcache.sh                           # Drops clean caches and reclaimable slab objects such as dentries and inodes
│   ├── cronjob_template.sh                     # Cronjob template that pings a monitoring server for a health check
│   ├── github_pr_inspector.sh                  # Interactive menu that builds `.patch` and `.diff` links for GitHub pull requests
│   ├── gnome_keybindings_backup_restore.sh     # Backs up and restores GNOME keybindings
│   ├── gpg_keygen_script.sh                    # Generates a GPG key pair
│   ├── install_latest_dart_sass.sh             # Installs the latest Dart Sass to `/usr/local/dart-sass`
│   ├── install_latest_go.sh                    # Installs the latest Go to `/usr/local/go`
│   ├── install_latest_hugo.sh                  # Downloads and installs the latest Hugo release
│   ├── install_latest_jetbrains_mono.sh        # Installs the latest JetBrains Mono font in the system-wide fonts directory
│   ├── install_latest_protoc.sh                # Installs the latest protoc
│   ├── lint.sh                                 # Local lint (Prettier, textlint, conflict markers)
│   ├── maintain_git_repo.sh                    # Automates the maintenance of a Git repository
│   ├── new_docker_compose_file.sh              # Creates a Docker Compose environment
│   ├── new_docker_project.sh                   # Creates a Docker container directory structure and configuration files from user input
│   ├── setup_gpg.sh                            # Configures API or GPG signing for Git operations
│   ├── ssh_keygen_script.sh                    # Generates and converts SSH key pairs
│   ├── super_linter.sh                         # Runs GitHub Super Linter locally in a Docker container
│   ├── sync_containers.sh                      # Synchronizes Docker container images from a predefined list, with a disk space check and a log file
│   ├── uptime_kuma_pr_test_v2.sh               # Tests Uptime Kuma 2.x pull requests in a Docker container
│   ├── user_accounts_info.sh                   # Lists system and normal user accounts
│   └── verify_signatures.sh                    # Verifies commit and tag signatures
├── .editorconfig                               # Editor settings (indent, line endings)
├── .gitignore                                  # Git ignore rules
├── .gitleaksignore                             # Gitleaks secret scanning allowlist
├── .npmrc                                      # npm supply-chain hardening
├── .pre-commit-config.yaml                     # Local pre-commit hooks (mirrors CI)
├── .prettierignore                             # Files excluded from Prettier formatting
├── .prettierrc                                 # Prettier configuration file
├── AI_CONTRIBUTION_POLICY.md                   # Rules for contributions made with AI assistance
├── CHANGELOG.md                                # Project change history
├── CLAUDE.md                                   # Project rules for Claude Code
├── CODE_OF_CONDUCT.md                          # Contributor Covenant Code of Conduct
├── CONTRIBUTING.md                             # Contribution guidelines
├── CONTRIBUTORS.md                             # Auto-generated contributors list
├── GOVERNANCE.md                               # Project governance model
├── LICENSE                                     # Creative Commons BY-NC-SA 4.0 license
├── MAINTAINERS.md                              # Project maintainer list and process
├── NOTICE                                      # Attribution and license notice
├── package-lock.json                           # Locked versions of the dev tooling
├── package.json                                # Dev tooling (Prettier, textlint) and lint scripts
├── README.md                                   # Primary repository documentation
├── ROADMAP.md                                  # Planned features and milestones
├── SECURITY.md                                 # Security policy and reporting guidelines
├── SUPPORT.md                                  # Support channels and response times
└── TERMS_OF_SERVICE.md                         # Terms of service
```

## CI/CD and Automation

The repository includes a set of GitHub Actions workflows that run automatically
on push, pull request, and scheduled triggers.

### Workflows

| Workflow                             | Trigger                 | Purpose                                              |
| :----------------------------------- | :---------------------- | :--------------------------------------------------- |
| `codeql.yml`                         | Push, PR, schedule      | CodeQL static analysis for security vulnerabilities  |
| `contributors.yml`                   | Push to `main`          | Auto-generates `CONTRIBUTORS.md`                     |
| `dependency_review.yml`              | PR                      | Reviews dependency changes for known vulnerabilities |
| `housekeeping.yml`                   | Weekly schedule, manual | Cleans up old workflow runs and Actions caches       |
| `issues.yml`                         | Issue events            | Automates issue labeling and triage                  |
| `labels.yml`                         | Push, manual            | Synchronizes repository labels from `labels.yml`     |
| `lint_pull_request.yml`              | PR, manual              | Runs `npm run lint` on the changed files             |
| `merge_conflicts.yml`                | Push, PR                | Detects merge conflicts in open pull requests        |
| `milestone_manager.yml`              | Manual                  | Automates milestone creation and lifecycle           |
| `pull_request.yml`                   | PR events               | Pull request automation and validation               |
| `release_manager.yml`                | Manual                  | Automates GitHub Releases                            |
| `signing_test.yml`                   | Manual                  | Tests API-based commit and tag signing               |
| `stale_issues_and_pull_requests.yml` | Schedule                | Marks and closes stale issues and pull requests      |
| `super_linter.yml`                   | Push to `main`, manual  | Runs Super Linter across the codebase                |
| `unreproducible_issues.yml`          | Schedule                | Manages issues that cannot be reproduced             |

All workflows follow the standards documented in
[`.github/policies/github_actions.md`](./.github/policies/github_actions.md),
including actions pinned to a commit SHA, concurrency controls, timeout limits,
bot filtering, and structured job summaries.

### Linting

Pull requests are linted with `npm run lint` (`scripts/lint.sh`), which uses
Prettier, textlint, and a merge conflict marker check with the configuration
files below. Pushes to `main` run
[Super Linter](https://github.com/super-linter/super-linter), configured through
`.github/super_linter.env`. The following linters are enabled: Bash, Bash Exec,
Checkov, ENV, GitHub Actions (actionlint), Gitleaks, Git merge conflict markers,
JSON (Prettier), Markdown (Prettier), Natural Language (textlint), Pre-commit,
Renovate, and YAML (Prettier).

Linter-specific configuration files are stored in `.github/linters/` and include
rules for Checkov, Gitleaks, markdownlint, textlint, yamllint, actionlint, and
PowerShell.

### Dependency Management

Dependency updates are managed by [Renovate](https://github.com/apps/renovate).
The configuration in `.github/renovate.json` pins GitHub Actions to commit SHAs
and npm packages to exact versions, waits 7 days before it proposes a new
release, merges patch, pin, and digest updates automatically with squash, and
prioritizes security updates. Major and minor updates are never merged
automatically. Renovate also keeps a dependency dashboard issue.

## Policies and Standards

The repository includes internal policies that define how the project operates.
These are documented in `.github/policies/` and in root-level files:

| Document                                                                               | Purpose                                              |
| :------------------------------------------------------------------------------------- | :--------------------------------------------------- |
| [`.github/policies/github_actions.md`](./.github/policies/github_actions.md)           | Workflow structure, security, and logging standards  |
| [`.github/policies/labels.md`](./.github/policies/labels.md)                           | Label naming, color strategy, and usage rules        |
| [`.github/policies/logs.md`](./.github/policies/logs.md)                               | Logging conventions for workflows and scripts        |
| [`.github/policies/review_process.md`](./.github/policies/review_process.md)           | Code review stages, criteria, and merge strategy     |
| [`.github/policies/security.md`](./.github/policies/security.md)                       | Security scanning and vulnerability management       |
| [`.github/policies/tests.md`](./.github/policies/tests.md)                             | Testing standards, structure, and conventions        |
| [`docs/code_style_and_standards_guides.md`](./docs/code_style_and_standards_guides.md) | Coding style guidelines and Prettier configuration   |
| [`AI_CONTRIBUTION_POLICY.md`](./AI_CONTRIBUTION_POLICY.md)                             | Rules for contributions made with AI assistance      |
| [`GOVERNANCE.md`](./GOVERNANCE.md)                                                     | Project governance model and decision-making process |
| [`MAINTAINERS.md`](./MAINTAINERS.md)                                                   | Maintainer roles, responsibilities, and current list |
| [`TERMS_OF_SERVICE.md`](./TERMS_OF_SERVICE.md)                                         | Terms of use for the repository                      |

## Working with Claude

Project rules and conventions for Claude Code live in
[`CLAUDE.md`](./CLAUDE.md). The shared settings are in
[`.claude/settings.json`](./.claude/settings.json). The code style guide is in
[`docs/code_style_and_standards_guides.md`](./docs/code_style_and_standards_guides.md),
so a session on any computer follows the same rules.

## Known Issues

The maintainers strive to provide a seamless experience. Below are any known
bugs, limitations, or issues you might encounter. This section is updated
regularly.

### Currently Being Addressed

No known issues at this time.

If you discover a bug or experience an issue not listed here, please
[open an issue on GitHub](https://github.com/homelab-alpha/shell-script/issues/new/choose).

## Contributing

Contributions are welcome. See [CONTRIBUTING.md](./CONTRIBUTING.md) for
contribution guidelines, branch naming conventions, commit message format, and
the review process. AI-assisted contributions follow
[AI_CONTRIBUTION_POLICY.md](./AI_CONTRIBUTION_POLICY.md).

## Support

For setup questions, troubleshooting, and general help, see
[SUPPORT.md](./SUPPORT.md).

## Security

To report a security vulnerability, please follow the process described in
[SECURITY.md](./SECURITY.md). Do **not** report security issues via public
GitHub issues or discussions.

## Roadmap

Planned features, milestones, and the long-term direction of the project are
documented in [ROADMAP.md](./ROADMAP.md).

## License

This project is licensed under the **Creative Commons
Attribution-NonCommercial-ShareAlike 4.0 International License** (CC BY-NC-SA
4.0). See the [LICENSE](./LICENSE) and [NOTICE](./NOTICE) files for the full
license text and attribution requirements.
