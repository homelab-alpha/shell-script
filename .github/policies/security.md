# Security Policy

- **Policy ID:** ENG-SECURITY-001
- **Version:** 1.0.0
- **Status:** Active
- **Effective Date:** 2026-10-29
- **Owner:** Homelab-Alpha
- **Applies To:** All repositories using GitHub Actions within the organization

This document describes how the **shell-script** maintainers handle security
vulnerabilities internally. For the public-facing security policy, see
[`SECURITY.md`](../../SECURITY.md) in the repository root.

<details>
  <summary>Table of Contents (click to expand)</summary>
  <p>

1. [Security Policy](#security-policy)
   1. [Scope](#scope)
   2. [Receiving a Report](#receiving-a-report)
   3. [Triage](#triage)
   4. [Severity Classification](#severity-classification)
   5. [Response SLA](#response-sla)
   6. [Remediation Process](#remediation-process)
   7. [Disclosure](#disclosure)
   8. [Post-Incident Review](#post-incident-review)
   9. [Revision History](#revision-history)

  </p>
</details>

## Scope

This policy applies to all security vulnerabilities reported against:

- Code and configuration in the `main` branch.
- Published releases and their associated artifacts.
- GitHub Actions workflows and CI/CD infrastructure in this repository.

Out of scope: vulnerabilities in third-party dependencies should be reported
directly to the upstream project. If a dependency vulnerability directly affects
this project, it is in scope.

## Receiving a Report

All vulnerability reports must arrive through one of the two private channels
described in [`SECURITY.md`](../../SECURITY.md):

1. A **GitHub Security Advisory** submitted via the repository's
   [Security tab](https://github.com/homelab-alpha/shell-script/security/advisories/new).
2. A **Security Issue** containing only the advisory URL — no sensitive details
   in the public issue body.

Reports sent through public issues, pull requests, or discussions must be closed
immediately with a pointer to the correct channel. Do not acknowledge any
vulnerability details in a public thread.

## Triage

Upon receiving a report, the assigned maintainer must:

1. **Acknowledge** the report within **72 hours** via a private reply on the
   advisory.
2. **Reproduce** the issue in an isolated environment.
3. **Assess** scope, impact, and affected versions.
4. **Assign a severity** using the classification below.
5. **Notify** all Senior Maintainers via a private channel.

If the report cannot be reproduced or is determined to be out of scope, the
reporter must be informed within **5 business days** with a brief explanation.

## Severity Classification

Severity is assigned using the
[CVSS v4.0](https://www.first.org/cvss/calculator/4.0) base score as a guide,
mapped to the following levels:

| Severity        | CVSS Score | Description                                                                                             |
| :-------------- | :--------- | :------------------------------------------------------------------------------------------------------ |
| 🔴 **Critical** | 9.0 – 10.0 | Remote code execution, full privilege escalation, or complete data exposure. Immediate action required. |
| 🟠 **High**     | 7.0 – 8.9  | Significant impact on confidentiality, integrity, or availability. Fix required before next release.    |
| 🟡 **Medium**   | 4.0 – 6.9  | Limited impact or requires specific conditions to exploit. Address in the next planned release.         |
| 🟢 **Low**      | 0.1 – 3.9  | Minimal impact, informational, or theoretical. Address in a future release.                             |

## Response SLA

| Severity    | Initial Acknowledgement | Fix Target         | Disclosure            |
| :---------- | :---------------------- | :----------------- | :-------------------- |
| 🔴 Critical | 72 hours                | 7 days             | After fix is released |
| 🟠 High     | 72 hours                | 30 days            | After fix is released |
| 🟡 Medium   | 72 hours                | 90 days            | After fix is released |
| 🟢 Low      | 72 hours                | Next release cycle | After fix is released |

> [!NOTE]
>
> These are target timelines maintained on a best-effort basis. shell-script is
> maintained voluntarily. If a deadline cannot be met, the reporter must be
> proactively informed with an updated estimate.

## Remediation Process

1. **Create a private fork** or use GitHub's
   [private vulnerability patching](https://docs.github.com/en/code-security/tutorials/fix-reported-vulnerabilities/collaborate-in-a-fork)
   feature to develop the fix without public exposure.
2. **Write a regression test** that fails before the fix and passes after.
3. **Prepare a patch release** following the versioning conventions in
   [`CONTRIBUTING.md`](../../CONTRIBUTING.md).
4. **Draft the advisory** on GitHub with full CVSS details, affected versions,
   patched versions, and remediation steps.
5. **Request a CVE** via the GitHub Security Advisory if the vulnerability meets
   the threshold for public assignment.
6. **Merge and release** the fix. Tag the release following the project's
   release process described in
   [`release_manager.yml`](../workflows/release_manager.yml).
7. **Publish the advisory** immediately after the release is live.

## Disclosure

shell-script follows a **coordinated disclosure** model:

- Vulnerabilities are not disclosed publicly until a fix is available.
- The reporter is credited in the advisory and `CHANGELOG.md` unless they
  request anonymity.
- If a fix cannot be delivered within the SLA, a mitigation or workaround is
  published to allow users to protect themselves, followed by the full advisory
  when the fix is ready.
- Zero-day disclosures or active exploitation in the wild may accelerate the
  timeline at the discretion of the Senior Maintainers.

## Post-Incident Review

After every **Critical** or **High** severity fix, the maintainers conduct a
brief post-incident review covering:

- Root cause and how it was introduced.
- How it was detected and by whom.
- Whether existing controls (linting, CodeQL, Gitleaks, Dependabot) could have
  caught it earlier.
- Process improvements to prevent similar issues.

Findings are documented internally and, where appropriate, result in updates to
CI configuration, contribution guidelines, or this policy.

## Revision History

| Version | Date       | Author        | Changes          |
| :------ | :--------- | :------------ | :--------------- |
| 1.0.0   | 2026-10-29 | Homelab-Alpha | Initial release. |
