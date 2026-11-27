# Accessibility

Homelab-Alpha wants its documentation and tools to be usable by everyone,
including people who rely on assistive technology. This is a hobby project that
is maintained on a best-effort basis.

This statement covers the public repositories of Homelab-Alpha: `adguard-home`,
`docker`, `docs`, `dotfiles`, `homelab-alpha`, `kairos`, `openssl`, and
`shell-script`.

## Our goals

We aim for [WCAG 2.2](https://www.w3.org/TR/WCAG22/) Level AA where it applies.
This is a goal, not a claim of verified conformance.

## What is in place

### Documentation site (`docs`)

- Content in English and Dutch.
- A skip link to the page content.
- A reading menu to change the font (including Atkinson Hyperlegible and
  OpenDyslexic), text size, spacing, column width, and motion.
- Development tests with axe-core and Lighthouse. These tests are run manually
  and are not part of CI.

### Kairos card (`kairos`)

- ARIA labels and states on interactive elements.
- A table with all prices as an alternative to the chart.
- Support for user preferences such as reduced motion, increased contrast, and
  forced colors.
- Interface in English and Dutch.

## Supported environments

| Project          | Environment                              |
| :--------------- | :--------------------------------------- |
| `docs`           | Current desktop and mobile browsers.     |
| `kairos`         | Home Assistant dashboards in a browser.  |
| Scripts, configs | A text terminal and a text editor.       |
| All repositories | GitHub web interface and Markdown files. |

We have not yet systematically tested with screen readers such as NVDA, JAWS,
VoiceOver, or TalkBack.

## Known limitations

- The shell prompts and command color settings in `dotfiles` do not check the
  `NO_COLOR` environment variable.
- The statistics cards on the Homelab-Alpha profile are images. A text version
  is linked at the bottom of the profile, but it has no section headings.
- The OpenDyslexic font on the documentation site supports Latin script only.
- Not all content has been reviewed against WCAG 2.2.
- Third-party software and embedded content are outside our control.

## Reporting a barrier

Open an Accessibility Barrier issue in the repository where you found the
problem. Please include:

- What you were trying to do.
- What happened, and what you expected.
- The page, file, or script involved.
- Your operating system, browser or terminal, and assistive technology.

You never need to share a diagnosis or other medical information.

## What you can expect

We aim to respond to bug reports within 5 business days. This is a target, not a
guarantee. We do not promise a fixed resolution time. If we cannot fix a
barrier, we will explain why and suggest a workaround where possible.

## Contributing

When you change documentation or an interface:

- Use headings in a logical order.
- Write descriptive link text.
- Add alternative text to images.
- Do not use color as the only way to convey information.
- Keep interactive elements usable with a keyboard.
