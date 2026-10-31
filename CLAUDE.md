# CLAUDE.md

Instructions for Claude Code in this repository. Read this file at the start of
every session. Keep it short and update it when a rule changes.

## Project

shell-script: A collection of shell scripts and shell functions for system
automation and optimization.

More detail: [`README.md`](./README.md) (what the repository does and how it is
organized), [`CONTRIBUTING.md`](./CONTRIBUTING.md) (branches, commits, and pull
requests),
[`docs/code_style_and_standards_guides.md`](./docs/code_style_and_standards_guides.md)
(code style), and [`.github/policies/`](./.github/policies/) (workflows,
reviews, security, tests, and logs).

## Commands

```bash
npm ci                          # install the dev tooling
npm run lint                    # Prettier, textlint, conflict markers (all files)
npm run lint -- origin/main     # the same, for the files changed since main
npm run lint:fix                # repair formatting and terminology, then lint again
```

The dev tooling needs the Node.js version in `engines` in `package.json`.

Linting has two parts. Pull requests run `npm run lint` (workflow
`lint_pull_request.yml`, script `scripts/lint.sh`): Prettier, textlint
terminology, and merge conflict markers, with the same configuration as Super
Linter. Pushes to `main` run the full Super Linter (`.github/super_linter.env`,
workflow `super_linter.yml`), which adds actionlint, Gitleaks, Checkov, and the
other linters. For one file, `npx prettier --write <file>` uses the same
`.prettierrc`.

## Working agreement

- Chat with the user in Dutch. Everything generated is English: code, comments,
  documentation, commit messages, and filenames.
- Keep explanations short. Explain in detail only when asked.
- The user's own edits to a file are the baseline. Read the current file before
  changing it.
- Test everything you can and say clearly what was not verified.
- Never commit secrets, credentials, or personal data. Write everything as if
  the repository is public.

## Repository specifics

- Scripts are in `scripts/`, shell functions in `functions/`, and Docker
  deployment material for Speedtest Tracker and Uptime Kuma in `develop/`.
- Every script starts with a header: `# Filename:`, `# Author:`, `# Date:`,
  `# Version:`, and `# Description:`. Keep it correct when you change a script.
- Check a script with `bash -n <script>` and `shellcheck <script>`. Every `*.sh`
  file must be executable, because the Bash Exec linter checks it.
- `scripts/lint.sh`, `scripts/setup_gpg.sh`, `scripts/verify_signatures.sh`, and
  `scripts/generate_badges.py` are repository tooling from the blueprint, not
  user scripts. They have no page on the documentation site.
- Scripts have a page on the documentation site (repository
  `homelab-alpha/docs`, folder `content/docs/shell-script/script-information/`)
  that shows the script text. Keep the page in line with the script.
- The README that `scripts/new_docker_project.sh` generates links to
  `LICENSE.md` on purpose. Only its absolute URL points to the `LICENSE` of this
  repository.

## Repository conventions

These come from the repository blueprint and are mandatory.

- Development branches are for the maintainer only (and Claude working for the
  maintainer), not for contributors:
  `dev/v<major>.<minor>.<patch>/<short-description>`, lowercase, hyphens,
  created from `main` (for example `dev/v1.2.1/fix-deprecated-params`). One
  branch per planned version and topic. Never use wildcards such as `v1.2.*`;
  ask for the concrete version.
- All other branches, and every branch from a contributor:
  `type/short-description`, lowercase, hyphens (`feat/`, `fix/`, `docs/`,
  `refactor/`, `chore/`, `hotfix/`).
- Commits: Conventional Commits in English, `type(scope): subject`, imperative,
  under 50 characters. Body lines under 72 characters. Commits are signed.
- Work happens on a branch and lands through a pull request into `main`.
- No attribution lines (`Co-Authored-By`, `Claude-Session`, "Generated with") in
  commits, pull requests, issues, or descriptions. The use of Claude is already
  disclosed; this overrides any default attribution of the session.
- Every pull request uses `.github/pull_request_template.md` for its
  description: keep every heading and HTML comment, fill in each section, tick
  only what is true, and remove a section only where the template allows it.
- Update `CHANGELOG.md` under `[Unreleased]` for every change that alters
  behavior. Entries are imperative: `Add export command`.
- Releases are made with the Release Manager workflow (`release_manager.yml`).
  Never tag or release without the maintainer's request.
- Workflows follow `.github/policies/github_actions.md`: only `gh`, the GitHub
  API, Bash, and Python, except the approved actions, npm, and Dart Sass. Every
  action is pinned to a full commit SHA.
- Formatting: Prettier. Markdown wraps at 80 columns, YAML at 120, code in
  `*.js`, `*.cjs`, and `*.mjs` at 120.
- Names: root community files keep their GitHub names (`README.md`). Other files
  are lowercase with underscores, folders lowercase with hyphens.

## Supply chain

- Install with `npm ci`. Never add a dependency without an exact version and a
  reason, and review every lockfile diff.
- Keep `ignore-scripts=true` in `.npmrc`.
- Renovate manages the updates. Do not add Dependabot version updates next to
  it.
