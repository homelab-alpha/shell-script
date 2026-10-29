# Security Policy

This document describes the security policy for the **shell-script** repository,
including supported versions, the vulnerability reporting process, and general
security practices.

<details>
  <summary>Table of Contents (click to expand)</summary>
  <p>

1. [Security Policy](#security-policy)
   1. [Supported Versions](#supported-versions)
   2. [Reporting a Vulnerability](#reporting-a-vulnerability)
      1. [What to Include](#what-to-include)
      2. [What to Expect](#what-to-expect)
   3. [Disclosure Policy](#disclosure-policy)
   4. [General Security Guidelines](#general-security-guidelines)

  </p>
</details>

## Supported Versions

Only the following branch and version receive active security updates. Users on
unsupported branches or older versions are strongly encouraged to upgrade.

| Branch         | Supported | Notes                                                                                  |
| :------------- | :-------- | :------------------------------------------------------------------------------------- |
| `main`         | ✅ Yes    | Primary stable branch. Receives all security updates.                                  |
| `dev`          | ❌ No     | Active development branch. May contain unstable code; no dedicated security updates.   |
| Other branches | ❌ No     | Feature branches, release candidates, and personal forks are not officially supported. |

| Version       | Supported | Notes                                                                                     |
| :------------ | :-------- | :---------------------------------------------------------------------------------------- |
| Latest stable | ✅ Yes    | The most recently tagged stable release (e.g., `v1.0.0`). Only this version is supported. |
| Prereleases   | ❌ No     | Alpha, beta, and dev releases are not supported for security updates.                     |
| Older stable  | ❌ No     | Previous stable versions are not supported. Please upgrade to the latest release.         |

## Reporting a Vulnerability

> [!WARNING]
>
> **Do not** report security vulnerabilities through public GitHub issues, pull
> requests, or discussions. Public disclosure before a fix is available puts all
> users at risk.

Please report vulnerabilities **privately** using the GitHub Security Advisory:

[➡️ Create a New Security Advisory](https://github.com/homelab-alpha/shell-script/security/advisories/new)

After submitting the advisory, notify the maintainers by
[opening a Security Issue](https://github.com/homelab-alpha/shell-script/issues/new?template=security_report.yml)
and pasting only the advisory URL — **do not include any vulnerability details
in the public issue**.

### What to Include

A good vulnerability report includes:

- A clear description of the vulnerability and its potential impact.
- Step-by-step reproduction instructions.
- The affected version(s) or branch(es).
- Any relevant logs, stack traces, or proof-of-concept code.
- Suggested remediation steps, if known.

### What to Expect

- **Initial response**: Within **72 hours** of receiving your report.
- **Progress updates**: We will keep you informed as we investigate and develop
  a fix.
- **Coordinated disclosure**: We ask that you do not disclose the vulnerability
  publicly until we have released a fix, or for a maximum of **90 days** from
  the date of your report — whichever comes first — unless we mutually agree on
  a different timeline.

## Disclosure Policy

- Advisory details remain **confidential** until a fix is released.
- Once resolved, the advisory will be **publicly disclosed on GitHub**.
- The advisory will only be visible to repository maintainers and invited
  collaborators until publication.
- Reporters are **automatically credited** in the published advisory and in the
  MITRE Credit System.

## General Security Guidelines

- **Dependencies**: All dependencies are monitored and updated automatically by
  [Renovate](https://docs.renovatebot.com/). OSV vulnerability alerts are
  enabled.
- **Secret Detection**: [Gitleaks](https://github.com/gitleaks/gitleaks) runs on
  every push to detect accidentally committed secrets. False positives can be
  allowlisted in [.gitleaksignore](./.gitleaksignore).
- **Code Review**: All changes to `main` are reviewed by a maintainer before
  merging to catch potential security issues early.
- **Infrastructure Scanning**: [Checkov](https://www.checkov.io/) scans GitHub
  Actions workflows and configuration files for misconfigurations.
- **No Sensitive Data in Code**: Never commit API keys, passwords, tokens, or
  any sensitive credentials. Use environment variables or a secrets manager.
- **Dependency Review**: The
  [Dependency Review workflow](./.github/workflows/dependency_review.yml) scans
  new dependencies introduced in pull requests for known CVEs and denied
  licenses.

---

Thank you for helping keep shell-script secure. Responsible disclosure makes the
project safer for everyone. 🙏
