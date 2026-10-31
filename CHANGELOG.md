# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased] - 2026-10-29

### Added

- Add a brand guide and branding files in `assets/branding/` (logo, icons,
  favicon, and social preview), and show the logo at the top of `README.md`
- Add the `badges.yml` workflow and `scripts/generate_badges.py` to render the
  README badges, including Super Linter and CodeQL, as SVG files on the `badges`
  branch

### Changed

- Replace the `img.shields.io` badges in `README.md` with the self-hosted
  badges
- Explain in `.github/super_linter.env` when to enable PowerShell validation
- Explain in `codeql.yml` when to add a language
- Ignore `notes.md`, `super_linter.log`, and Python cache files in `.gitignore`
- List `scripts/generate_badges.py` as repository tooling in `CLAUDE.md`

### Deprecated

### Removed

### Fixed

- Fix the GitHub link in `NOTICE`, which pointed to `github.com/shell-script`
  instead of `github.com/homelab-alpha`
- Fix the table of contents link of `CONTRIBUTING.md` to its first heading

### Security

[Unreleased]: https://github.com/homelab-alpha/shell-script/compare/main...HEAD

---
