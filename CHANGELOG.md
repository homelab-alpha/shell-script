# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Add a brand guide and branding files in `.github/branding/` (logo, icons,
  favicon, and social preview), and show the logo at the top of `README.md`
- Add the `badges.yml` workflow and `.github/scripts/generate_badges.py` to render the
  README badges, including Super Linter and CodeQL, as SVG files on the `badges`
  branch

### Changed

- Move the repository tooling (`lint.sh`, `generate_badges.py`, `setup_gpg.sh`,
  and `verify_signatures.sh`) from `scripts/` to `.github/scripts/`, the
  branding from `assets/branding/` to `.github/branding/`, and the code style
  guide from `docs/` to `.github/docs/`. `scripts/` keeps the user scripts
- Add a 20 px protective border to the logo SVGs and show the logo in
  `README.md` at a fixed height of 100 px
- Update the badges only after Lint Repository and CodeQL ran and passed for the
  same commit: remove the `push` trigger from `badges.yml` and add the
  `check-workflows` job
- Replace the `img.shields.io` badges in `README.md` with the self-hosted
  badges
- Explain in `.github/super_linter.env` when to enable PowerShell validation
- Explain in `codeql.yml` when to add a language
- Ignore `notes.md`, `super_linter.log`, and Python cache files in `.gitignore`
- List `.github/scripts/generate_badges.py` as repository tooling in `CLAUDE.md`
- Replace the deprecated `deny-licenses` option in `dependency_review.yml` with
  an `allow-licenses` list of permissive licenses and CC BY-NC-SA 4.0, so GPL
  and LGPL stay blocked
- Check development dependencies too in `dependency_review.yml`, by setting
  `fail-on-scopes` to `runtime, development`
- chore: adopt the blueprint template as the repository standard [ad95b7f](https://github.com/homelab-alpha/shell-script/commit/ad95b7f0683429013d1f7dde08e1a798deb21df4) by [@homelab-alpha](https://github.com/homelab-alpha)
- chore(deps): comment on the pull request only when the dependency review fails [85b86a6](https://github.com/homelab-alpha/shell-script/commit/85b86a64cd275dbf5b07318225933bbb6207b66f) by [@homelab-alpha](https://github.com/homelab-alpha)
- docs: add CLAUDE.md with the project rules for Claude Code [d0cb16e](https://github.com/homelab-alpha/shell-script/commit/d0cb16eef91236d7b13f381bbb063d5eb67c9d2b) by [@homelab-alpha](https://github.com/homelab-alpha)
- chore(repo): adopt the current blueprint standard [0f044da](https://github.com/homelab-alpha/shell-script/commit/0f044da721823d8b4dae6020951fb15669a692de) by [@homelab-alpha](https://github.com/homelab-alpha)
- chore(repo): sync the latest blueprint updates [6a54f2a](https://github.com/homelab-alpha/shell-script/commit/6a54f2a63378111ed0f8e636a9b04aeea001447d) by [@homelab-alpha](https://github.com/homelab-alpha)
- chore(workflows): replace deny-licenses with allow-licenses [fca8d11](https://github.com/homelab-alpha/shell-script/commit/fca8d112d1e90c4521043fb5eac2f8f45f16b135) by [@homelab-alpha](https://github.com/homelab-alpha)
- chore(blueprint): sync with the blueprint [4bcdb55](https://github.com/homelab-alpha/shell-script/commit/4bcdb559071a743e7783dfa454ad6e68e182831b) by [@homelab-alpha](https://github.com/homelab-alpha)
- ci(workflows): request a reviewer on bot PRs [a218c7e](https://github.com/homelab-alpha/shell-script/commit/a218c7ed59d0929b19c8edb00dc8b8c3372c8a3e) by [@homelab-alpha](https://github.com/homelab-alpha)
- chore(github): sync Hugo and Dart Sass rules [9fedf57](https://github.com/homelab-alpha/shell-script/commit/9fedf57880ad1427e35f46ea342cead79f9c597c) by [@homelab-alpha](https://github.com/homelab-alpha)
- chore(github): sync runners, Renovate, and linters [52ae3fd](https://github.com/homelab-alpha/shell-script/commit/52ae3fdae2f94bebf9a7b1a3bb9726c1262d4a64) by [@homelab-alpha](https://github.com/homelab-alpha)
- ci(workflows): run workflows for bots [5e39e9c](https://github.com/homelab-alpha/shell-script/commit/5e39e9c444e0fff5f587e79da9b2bea045346b3d) by [@homelab-alpha](https://github.com/homelab-alpha)
- ci(workflows): allow BlueOak-1.0.0 license [7273cbe](https://github.com/homelab-alpha/shell-script/commit/7273cbefe262213288327bac92477b303d9ddfa0) by [@homelab-alpha](https://github.com/homelab-alpha)
- chore(labels): add dependency update labels [8f83105](https://github.com/homelab-alpha/shell-script/commit/8f83105932cb8ebc0335a47c1c349d25b8b2f5ba) by [@homelab-alpha](https://github.com/homelab-alpha)
- chore(renovate): remove default assignees [294893b](https://github.com/homelab-alpha/shell-script/commit/294893ba7fa8b78657d019efe13e96f5ba6c093c) by [@homelab-alpha](https://github.com/homelab-alpha)
- chore(renovate): group and automerge updates [36a20d8](https://github.com/homelab-alpha/shell-script/commit/36a20d8f945992d971b36d289210a1dacc06d599) by [@homelab-alpha](https://github.com/homelab-alpha)
- chore(sync): sync shared files with blueprint [e7507ab](https://github.com/homelab-alpha/shell-script/commit/e7507abb156298e72e1566ab17d676346246df8a) by [@homelab-alpha](https://github.com/homelab-alpha)
- docs: move and update AI contribution policy [530df19](https://github.com/homelab-alpha/shell-script/commit/530df19b94296272d195376df13d8f2d94de16b1) by [@homelab-alpha](https://github.com/homelab-alpha)
- chore: sync files with the blueprint [e0edd2e](https://github.com/homelab-alpha/shell-script/commit/e0edd2e36f1ef40372ee4704c51eaa17f2ec7de1) by [@homelab-alpha](https://github.com/homelab-alpha)

### Deprecated

### Removed

### Fixed

- Fix the link to the documentation site in `README.md`, which pointed to
  `homelab-alpha.nl/docs/shell-script/` instead of `homelab-alpha.nl/shell-script/`
- Fix the GitHub link in `NOTICE`, which pointed to `github.com/shell-script`
  instead of `github.com/homelab-alpha`
- Fix the table of contents link of `CONTRIBUTING.md` to its first heading
- fix(renovate): fix invalid automergeType and vulnerability rule [bd2796c](https://github.com/homelab-alpha/shell-script/commit/bd2796c378e23101457236b5e92d2e4a19dc752d) by [@homelab-alpha](https://github.com/homelab-alpha)
- fix(scripts): fix hugo check, jetbrains mono timestamp, and cert name placeholder [4d7147f](https://github.com/homelab-alpha/shell-script/commit/4d7147f1927cde9dfa20bace7f0aca7357de9cb7) by [@homelab-alpha](https://github.com/homelab-alpha)
- fix(scripts): make lint.sh executable [9b583f9](https://github.com/homelab-alpha/shell-script/commit/9b583f9ff90fd021f3ebd41f99529f90d9fae806) by [@homelab-alpha](https://github.com/homelab-alpha)
- fix(labels): skip unchanged labels and retry failed writes [c7fd80d](https://github.com/homelab-alpha/shell-script/commit/c7fd80d44e1f930a89c36d5f66a61630b610d354) by [@homelab-alpha](https://github.com/homelab-alpha)
- fix(docs): fix the TOC link to the first heading [ffff585](https://github.com/homelab-alpha/shell-script/commit/ffff5851a7ddbba6c7d8200bce1390f6bf778d1e) by [@homelab-alpha](https://github.com/homelab-alpha)
- fix(docs): fix the documentation site link [291e478](https://github.com/homelab-alpha/shell-script/commit/291e4784c0261d622bb1e21ce6c6dcaccfbbe69f) by [@homelab-alpha](https://github.com/homelab-alpha)
- fix(changelog): remove the date from Unreleased [1045956](https://github.com/homelab-alpha/shell-script/commit/1045956782ff092eca0cee4d0c518ffb81df4380) by [@homelab-alpha](https://github.com/homelab-alpha)
- fix(scripts): restore pull_request_body.py logic [fc5bd79](https://github.com/homelab-alpha/shell-script/commit/fc5bd79781ad588f978e5f805d90bcab6c61196c) by [@homelab-alpha](https://github.com/homelab-alpha)
- fix(changelog): remove the Unreleased link [8eba1bb](https://github.com/homelab-alpha/shell-script/commit/8eba1bb34b0e4d23684dfa80554629630cbf4895) by [@homelab-alpha](https://github.com/homelab-alpha)
- fix(workflow): do not draft Renovate PRs [7b8d72d](https://github.com/homelab-alpha/shell-script/commit/7b8d72db08d869c9626fc2dbb4780f6f47434e38) by [@homelab-alpha](https://github.com/homelab-alpha)

### Security

- Override the transitive dev dependencies `glob` (14.0.3) and `minimatch`
  (11.0.3) to fix Dependabot alerts, which textlint pulls in
