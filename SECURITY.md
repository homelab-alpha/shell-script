# Security Policy

This document outlines the security policy for the `shell-script` repository.

## Supported Branch and Versions

The following versions of this project are currently supported with security
updates. Users on unsupported branches or versions are strongly encouraged to
upgrade to the `main` branch and the `latest` stable release to ensure they
receive security updates.

| Branch         | Supported | Notes                                                                                                                                      |
| :------------- | :-------- | :----------------------------------------------------------------------------------------------------------------------------------------- |
| Main           | Yes       | This is the primary stable branch and receives all security updates.                                                                       |
| Dev            | No        | This branch is used for active development and may contain unstable code, therefore it does not receive dedicated security updates.        |
| Other Branches | No        | Any other branches created (e.g., feature branches, release candidates, personal forks) are not officially supported for security updates. |

| Version      | Supported | Notes                                                                                                                                                          |
| :----------- | :-------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Latest       | Yes       | The `latest` version refers to the most recently tagged stable release (e.g., v1.0.0, v1.1.0). Only the most current stable release receives security updates. |
| Above Latest | No        | Versions newer than the latest official release (e.g., prerelease versions or untagged commits) are not officially supported for security updates.             |
| Below Latest | No        | Older stable versions are not supported. Please upgrade to the `latest` version to receive security patches.                                                   |

## Reporting a Vulnerability

We appreciate responsible disclosure of vulnerabilities. If you discover a
security vulnerability in this project, please follow the guidelines below.

**Report the vulnerability privately:** Please report the vulnerability through
the **GitHub Security Advisory** feature:
[https://github.com/homelab-alpha/shell-script/security/advisories/new]. Provide as
many details as possible, including reproduction steps and the potential impact.

**Give us time to respond:** We aim to respond to your report within **72
hours** and keep you updated on the progress of our investigation. We kindly ask
you not to disclose the vulnerability publicly until we have had a chance to
address it, or for a period of **90 days**, whichever comes first, unless
otherwise agreed upon.

**Collaboration:** We will work with you to understand and resolve the issue.
Once the issue is resolved, we will acknowledge your contribution.

**Confidentiality**: The information you provide in the GitHub Security Advisory
will initially remain confidential. However, once the vulnerability is
addressed, the advisory will be publicly disclosed on GitHub.

**Access and Visibility**: Until the advisory is published, it will only be
visible to the maintainers of the repository and invited collaborators.

**Credit**: You will be automatically credited as a contributor for identifying
and reporting the vulnerability. Your contribution will be reflected in the
MITRE Credit System, which is a standardized system for recognizing individuals
for their cybersecurity contributions.

## General Security Guidelines

- **Dependencies:** Keep all project dependencies up-to-date to minimize known
  vulnerabilities. We regularly monitor for and apply dependency updates.
- **Code Review:** New code is reviewed by team members where possible to
  identify potential security issues before merging into `main`.
- **Regular Updates:** The repository is updated regularly to ensure the
  codebases are current and secure. We strive for frequent updates to
  incorporate the latest security patches and best practices.
- **No Sensitive Information:** Avoid committing sensitive information (e.g.,
  API keys, passwords) directly into the repository. Use environment variables
  or secure configuration management practices instead.

## License

This project is licensed under the **Creative Commons
Attribution–NonCommercial–ShareAlike 4.0 (CC BY-NC-SA 4.0)** license. See the
[LICENSE] file for more details.

Thank you for helping to keep this project secure!

[https://github.com/homelab-alpha/shell-script/security/advisories/new]: https://github.com/homelab-alpha/shell-script/security/advisories/new
[LICENSE]: https://github.com/homelab-alpha/shell-script/blob/main/LICENSE.md
