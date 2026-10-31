# Governance

This document describes how **shell-script** is governed: how decisions are
made, how maintainers are organized, and how the project is steered over time.
It is intended to provide transparency to contributors and users alike.

<details>
  <summary>Table of Contents (click to expand)</summary>
  <p>

1. [Governance](#governance)
   1. [Project Structure](#project-structure)
      1. [Project Founder](#project-founder)
      2. [Senior Maintainers](#senior-maintainers)
      3. [Maintainers](#maintainers)
      4. [Junior Maintainers](#junior-maintainers)
      5. [Contributors](#contributors)
   2. [Decision-Making](#decision-making)
      1. [Day-to-Day Decisions](#day-to-day-decisions)
      2. [Significant Decisions](#significant-decisions)
      3. [Final Authority](#final-authority)
   3. [Roadmap and Priorities](#roadmap-and-priorities)
   4. [Contribution and Review](#contribution-and-review)
   5. [Conflict Resolution](#conflict-resolution)
   6. [Changes to This Document](#changes-to-this-document)

  </p>
</details>

## Project Structure

shell-script uses a **maintainer-led governance model**. Authority and
responsibility are distributed across a small number of roles, with a clear
chain of accountability. Full role definitions, responsibilities, and the list
of current maintainers are documented in [MAINTAINERS.md](./MAINTAINERS.md).

### Project Founder

The Project Founder is the original creator of shell-script and holds ultimate
decision-making authority. The Founder sets the strategic direction, appoints
and removes maintainers, and retains veto rights on all project decisions.

### Senior Maintainers

Senior Maintainers are highly experienced contributors with deep knowledge of
the codebase and project goals. They are responsible for technical architecture,
release coordination, and mentoring other maintainers. They participate actively
in roadmap planning and make binding technical decisions within their areas.

### Maintainers

Maintainers handle day-to-day project operations: reviewing and merging pull
requests, managing issues and discussions, implementing features and bugfixes,
and maintaining documentation. They operate within the direction set by Senior
Maintainers and the Project Founder.

### Junior Maintainers

Junior Maintainers are newer contributors with formal maintainer status. They
assist with code reviews, bugfixes, documentation, and community support, under
the guidance of more experienced maintainers.

### Contributors

Anyone who submits a pull request, opens an issue, participates in a discussion,
or otherwise contributes to the project is a Contributor. Contributors do not
hold formal roles but are the lifeblood of the project.

## Decision-Making

### Day-to-Day Decisions

Routine decisions — such as merging a pull request, closing an issue, or
applying a label — are made independently by any Maintainer or Senior
Maintainer, in accordance with the project's contribution and review guidelines.

### Significant Decisions

Decisions that affect the project's direction, architecture, public API,
community guidelines, or governance require **consensus** among the active
Senior Maintainers and the Project Founder. Significant decisions include, but
are not limited to:

- Major feature additions or architectural changes.
- Changes to the Code of Conduct, contribution guidelines, or governance.
- Appointment or removal of maintainers at any level.
- Changes to supported versions or the release cadence.
- Deprecation or removal of existing functionality.

Consensus is sought through open discussion in GitHub Issues, Pull Requests, or
Discussions. If consensus cannot be reached, the matter is escalated to the
Project Founder for a final binding decision.

### Final Authority

The **Project Founder retains ultimate veto rights** on all project decisions.
This is not intended to override collaborative decision-making in practice, but
ensures that the project's long-term vision and integrity are preserved.

## Roadmap and Priorities

The project's direction is documented in [ROADMAP.md](./ROADMAP.md). The roadmap
is a living document maintained primarily by Senior Maintainers and the Project
Founder. Community members may propose additions or changes through
[GitHub Discussions](https://github.com/homelab-alpha/shell-script/discussions/categories/feature-request).

Roadmap items are not commitments and are subject to change based on available
resources, community feedback, and shifting priorities.

## Contribution and Review

All contributions are governed by [CONTRIBUTING.md](./CONTRIBUTING.md) and
reviewed according to
[`.github/policies/review_process.md`](./.github/policies/review_process.md).
Contributors are expected to follow the [Code of Conduct](./CODE_OF_CONDUCT.md)
and the
[Code Style and Standards Guide](./.github/docs/code_style_and_standards_guides.md).

## Conflict Resolution

Disagreements are resolved using the following escalation path:

1. **Open discussion** — The parties involved attempt to resolve the
   disagreement through respectful, good-faith dialogue in the relevant GitHub
   thread.
2. **Mediation** — If no resolution is reached, a Senior Maintainer not directly
   involved in the conflict mediates the discussion.
3. **Final decision** — If mediation fails, the Project Founder makes the final
   binding decision.

All parties are expected to abide by the outcome. Persistent bad-faith behavior
may result in enforcement actions under the Code of Conduct.

## Changes to This Document

Proposed changes to this governance document must be submitted as a pull request
and require approval from at least one Senior Maintainer and the Project Founder
before merging. Substantive changes are announced in the
[Announcements discussion category](https://github.com/homelab-alpha/shell-script/discussions/categories/announcements).
