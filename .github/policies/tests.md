# Tests

- **Policy ID:** ENG-TEST-001
- **Version:** 1.0.0
- **Status:** Active
- **Effective Date:** 2026-10-29
- **Owner:** Homelab-Alpha
- **Applies To:** All repositories using GitHub Actions within the organization

> [!IMPORTANT]
>
> This is a living document and may be adjusted based on feedback and project
> priorities.

This document describes the testing standards, structure, and expectations for
the Blueprint repository. All contributors are expected to follow these
guidelines when adding or modifying code.

<details>
  <summary>Table of Contents (click to expand)</summary>
  <p>

1. [Tests](#tests)
   1. [Purpose](#purpose)
   2. [Test Location](#test-location)
   3. [Test Types](#test-types)
      1. [Unit Tests](#unit-tests)
      2. [Integration Tests](#integration-tests)
   4. [Writing Tests](#writing-tests)
      1. [General Principles](#general-principles)
      2. [Naming Conventions](#naming-conventions)
      3. [Test Structure](#test-structure)
   5. [Running Tests](#running-tests)
   6. [Test Coverage](#test-coverage)
   7. [Tests in Pull Requests](#tests-in-pull-requests)
   8. [Linting and Static Analysis](#linting-and-static-analysis)
   9. [Revision History](#revision-history)

  </p>
</details>

## Purpose

Tests are the primary mechanism for verifying that the Blueprint behaves
correctly and continues to do so as the codebase evolves. A well-tested codebase
makes refactoring safer, bugs easier to catch, and reviews more confident.

Every contribution that changes behavior — whether a new feature or a bugfix —
is expected to include appropriate test coverage.

## Test Location

All tests live in the `tests/` directory at the root of the repository.

```treeview
tests/
├── unit/          # Unit tests for individual functions and modules
├── integration/   # Integration tests for combined components
└── fixtures/      # Shared test data and mock files
```

> [!NOTE]
>
> The `tests/` directory currently contains only a `.placeholder` file while the
> project is in its early stages. This structure will be populated as the core
> logic in `core/` is developed.

## Test Types

### Unit Tests

Unit tests verify the behavior of individual functions, classes, or modules in
isolation. External dependencies (file system, network, databases) are mocked or
stubbed.

Use unit tests for:

- Core logic in `core/` (storage, retrieval, categorization).
- Utility functions and helpers.
- Edge cases and error handling paths.

### Integration Tests

Integration tests verify that multiple components work correctly together. They
may interact with real files in the `data/` directory using a temporary or
sandboxed environment.

Use integration tests for:

- End-to-end flows (e.g., storing a memory and retrieving it).
- Interactions between the core logic and the data layer.
- Command-line tool behavior in `scripts/`.

## Writing Tests

### General Principles

- **Test behavior, not implementation**: Write tests that verify _what_ the code
  does, not _how_ it does it internally. This makes tests more resilient to
  refactoring.
- **One assertion per test** (where practical): Keep each test focused on a
  single behavior or outcome. Multiple assertions are acceptable when they
  collectively verify one logical behavior.
- **Test edge cases**: Include tests for empty inputs, null values, boundary
  conditions, and expected failure scenarios.
- **Keep tests independent**: Tests must not depend on the execution order of
  other tests. Each test must set up and tear down its own state.
- **Avoid hardcoded paths**: Use relative paths or temporary directories to
  ensure tests work across different environments.
- **Mock external dependencies**: Do not make real network calls or write to
  production data directories in tests.

### Naming Conventions

Test files and test cases must use descriptive names that clearly communicate
what is being tested and what the expected outcome is.

| Item           | Convention                            | Example                                      |
| :------------- | :------------------------------------ | :------------------------------------------- |
| Test files     | `<module>.test.<ext>`                 | `retrieval.test.py`                          |
| Test functions | `test_<behavior>_<condition>`         | `test_retrieve_returns_empty_on_missing_key` |
| Fixture files  | Descriptive name in `tests/fixtures/` | `sample_memory.json`                         |

### Test Structure

Follow the **Arrange – Act – Assert** (AAA) pattern for all tests:

```python
def test_store_saves_memory_to_data_directory():
    # Arrange
    archive = MemoryArchive(data_dir=tmp_path)
    memory = {"id": "abc123", "content": "Test memory", "type": "fact"}

    # Act
    archive.store(memory)

    # Assert
    assert (tmp_path / "abc123.json").exists()
```

- **Arrange**: Set up the inputs, state, and any mocks required.
- **Act**: Execute the function or behavior under test.
- **Assert**: Verify the outcome is as expected.

## Running Tests

> [!NOTE]
>
> Specific test commands will be documented here as the testing framework is
> established. The section below outlines the expected conventions.

Tests should be runnable with a single command from the root of the repository.
The exact command depends on the language and framework chosen for the project.

**Expected pattern:**

```bash
# Run all tests
<test-runner> tests/

# Run only unit tests
<test-runner> tests/unit/

# Run only integration tests
<test-runner> tests/integration/

# Run a specific test file
<test-runner> tests/unit/retrieval.test.<ext>
```

All tests must pass locally before submitting a pull request. Do not rely on CI
to catch test failures that could have been caught locally.

## Test Coverage

Test coverage measures how much of the codebase is exercised by the test suite.
While 100% coverage is not a strict requirement, the following guidelines apply:

- **Core logic** (`core/`): Aim for **high coverage**. Critical storage and
  retrieval paths must be thoroughly tested.
- **Scripts** (`scripts/`): Cover the main execution paths and error handling.
- **Examples** (`examples/`): Not required to have automated test coverage, but
  example scripts must be manually verified to work correctly.

Coverage reports should be generated as part of the test run and reviewed during
pull request review for any significant regressions.

> [!IMPORTANT]
>
> Coverage percentage alone is not a reliable measure of test quality. Prefer
> meaningful tests over tests written solely to increase coverage numbers.

## Tests in Pull Requests

When submitting a pull request that changes behavior:

- [ ] Include new or updated tests that cover the changed behavior.
- [ ] Ensure all existing tests continue to pass.
- [ ] Describe how you tested your changes in the pull request template under
      the **Testing** section.

Pull requests that introduce behavioral changes without corresponding tests may
be asked to add coverage before the review is completed.

## Linting and Static Analysis

In addition to functional tests, the following automated quality checks run on
every pull request and are considered part of the overall testing posture:

| Check                     | Tool                    | Scope                     |
| :------------------------ | :---------------------- | :------------------------ |
| Code style and formatting | Super Linter / Prettier | All file types            |
| Markdown structure        | markdownlint            | `.md` files               |
| YAML validity             | yamllint                | `.yml` / `.yaml` files    |
| Secret detection          | Gitleaks                | All files                 |
| Infrastructure security   | Checkov                 | Workflow and config files |
| Grammar and terminology   | textlint                | `.md` files               |
| Workflow syntax           | GitHub Actions linter   | `.github/workflows/`      |
| Dependency config         | Renovate validator      | `.github/renovate.json`   |

These checks are configured in
[`.github/super_linter.env`](./../super_linter.env) and the corresponding linter
config files in `.github/linters/`. All checks must pass before a pull request
can be merged.

For more details on the linting setup, see
[code_style_and_standards_guides.md](../../docs/code_style_and_standards_guides.md#linting).

## Revision History

| Version | Date       | Author        | Changes          |
| :------ | :--------- | :------------ | :--------------- |
| 1.0.0   | 2026-10-29 | Homelab-Alpha | Initial release. |
