# 📝 Pull Request Template

⚠️ **Please read this before submitting your pull request:**

Since we do not accept all types of pull requests, ensure that you have reviewed
the pull request rules: [Pull Request Rules]

---

## 📋 Overview \*

Provide a clear summary of the purpose and scope of this pull request:

- What problem does this pull request address?
- Why is it necessary?
- What functionality or features does it add or improve?

---

## 🔄 Changes

### 🛠️ Type of Change \*

Please select all options that apply:

- [ ] 🐛 Bugfix (non-breaking change that fixes an issue)
- [ ] 🎨 User Interface (UI) updates
- [ ] ✨ New feature (non-breaking change that adds functionality)
- [ ] ⚠️ Breaking change (a fix or feature that changes existing functionality
      in an unexpected way)
- [ ] 🌍 Internationalization (i18n) improvements
- [ ] 📄 Documentation update
- [ ] 🔧 Other (please specify):
  - _Enter additional details here_

### 🔗 Related Issues \*

Reference any related GitHub issues or tasks that this pull request addresses.
Use proper issue links or numbers, for example:

- Resolves #123
- Fixes #456
- Relates to #789

---

## 📦 Dependencies Added/Updated

- **New Dependencies:** List newly added libraries, frameworks, or tools, along
  with a short description.
- **Updated Dependencies:** List any updates to existing dependencies and
  describe why the update was necessary.

---

## 🌍 Internationalization (i18n)

If this pull request affects language support or translations, describe the
changes:

- New languages added or removed.
- Updates to existing translations.
- Steps to verify the translations.

---

## ✅ Testing \*

Describe how the changes were tested:

- **New Tests:** Outline any unit, integration, or end-to-end tests added.
- **Modified Tests:** Specify changes made to existing test cases.
- **Manual Testing:** Provide clear steps to verify the functionality manually.
- **Test Coverage:** Ensure relevant code is adequately tested.

---

## ⚡ Performance Considerations

- Have you analyzed the performance impact of this change? If so, explain your
  findings.
- If applicable, describe any benchmarks or profiling results.

---

## 🔒 Security Impact

- Does this change introduce or address any security concerns?
  - If yes, please describe the risk and the mitigation approach.

---

## 🚀 Deployment Considerations

Discuss any aspects related to deploying these changes:

- **Pre-deployment Steps:** Mention database migrations, configuration updates,
  or other steps.
- **Impact Assessment:** Highlight how these changes may affect existing
  systems.
- **Backward Compatibility:** Does this change break backward compatibility? If
  so, explain why and how to address it.
- **Rollback Plan:** Provide steps for reverting the changes if needed.

---

## 📄 Checklist \*

Before submitting your pull request, ensure the following tasks are completed:

- [ ] 🔍 My code adheres to the style guidelines of this project.
- [ ] ✅ I ran code linters for modified files.
- [ ] 🛠️ I have reviewed and tested my code.
- [ ] 📝 I have commented my code, especially in hard-to-understand areas (e.g.,
      using JSDoc).
- [ ] ⚠️ My changes generate no new warnings.
- [ ] 🧪 I have added automated tests, if required.
- [ ] 📄 Documentation updates (if applicable) are included.
- [ ] 🔒 I have considered potential security impacts and mitigated risks.
- [ ] 🌍 I have verified any internationalization (i18n) changes are correct.
- [ ] 🧰 Dependency updates are listed and explained.
- [ ] I have read and understood the [Pull Request Rules].

---

## 📰 Release Notes (if applicable)

Provide a short summary of how this change should be described in the release
notes:

- Example: "Fixed a bug causing X to fail under Y conditions."

---

## 📷 Screenshots or Visual Changes (if applicable)

If this pull request introduces visual changes, provide the following:

- **Before and After:** Screenshots or comparisons, if applicable.
- **UI Changes:** Highlight modifications to the user interface.

---

## ℹ️ Additional Context

Provide any additional information to help reviewers:

- Design decisions or trade-offs made during development.
- Alternative solutions considered but not implemented.
- Relevant links, such as specifications, discussions, or resources.
- Dependencies or related pull requests that must be addressed before merging.

[Pull Request Rules]:
  https://github.com/homelab-alpha/shell-script/blob/main/CONTRIBUTING.md#pull-requests
