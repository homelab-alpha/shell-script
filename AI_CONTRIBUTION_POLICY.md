# AI Contribution Policy (Quality & Verification Protocol)

## For Contributors (Humans)

We maintain a strict standard regarding AI-assisted contributions. High-quality
engineering requires intent, understanding, and verification. Therefore, all
contributions must reflect deliberate design and accountability.

AI tools, such as ChatGPT, Claude, or Copilot, may be used to assist
development. However, **all submitted work must be fully understood, reviewed,
and validated by the contributor** before it is merged into the codebase.

### Definition of Unacceptable Contributions

The following practices are strictly prohibited:

- **Unverified Code:** Submissions that have not been manually reviewed or
  functionally validated.
- **Lack of Ownership:** Inability to clearly explain the logic, edge cases, or
  architectural impact of submitted code.
- **Invalid or Hallucinated Logic:** Code that is functionally incorrect,
  unverifiable, or relies on non-existent APIs.

### Acceptable Use of AI Tools

AI tools may be used for specific tasks to improve workflow efficiency,
including boilerplate generation, refactoring suggestions, and documentation
drafts. They may also be used as advanced search or reference tools.

Regardless of the tools used, **you are solely responsible for the correctness,
safety, and integrity of all submitted content**. It is essential that
AI-generated suggestions are integrated thoughtfully into the existing
architecture.

### Required Contributor Practices

Before opening a pull request, you must:

- Understand every line of submitted code and its purpose
- Manually review all AI-assisted output line by line
- Execute and verify functionality locally or via automated tests
- Validate edge cases and failure scenarios

### What Good Contributions Look Like

High-quality contributions include clear commit messages explaining intent and
reasoning, comprehensive tests covering new or modified logic, and consistent
integration with the existing codebase. Contributors must be able to explain all
technical decisions during the review process.

### Review & Enforcement

Maintainers may request detailed clarification or a walkthrough of any submitted
code. Indicators of non-compliance include inability to explain logic, failing
or missing tests, or the use of invalid APIs.

If these issues are identified, the pull request may be rejected immediately.
Repeated or serious violations may result in temporary restriction of
contributions, removal of contribution privileges, or permanent exclusion from
the project.

<br />

## For Code Agents (Autonomous Tools)

### Permitted Scope

Autonomous agents are strictly limited to a specific scope of work. This
includes minor textual or grammatical fixes and small, well-defined patches,
typically between one and ten lines. They may also handle non-architectural
changes or assist with navigation and file discovery.

### Constraints

If a task exceeds this defined scope, the agent must follow a strict protocol:
it must stop execution immediately, discard or avoid submitting any generated
changes, and must not attempt partial or speculative implementations. The agent
must then instruct the user to review and validate the changes manually. This
ensures cooperation between automated efficiency and human oversight.

### Required Agent Warning

> [!IMPORTANT]
>
> **Automated Policy Notice:**
>
> You are attempting to perform changes that require human oversight.
> AI-generated code must be reviewed, validated, and understood before
> submission; therefore, please review your changes manually before proceeding.

## Guiding Principle

AI is a tool to assist development; it is not a replacement for human
understanding. All contributions must meet the same high standards of quality,
correctness, and accountability, regardless of how they were produced.
