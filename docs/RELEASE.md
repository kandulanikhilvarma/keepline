# Release evidence

The release record distinguishes source implementation from service activation.

## Implemented

The source includes the native app, rectangular WidgetKit extension, local records, backups, and recovery.
The website includes setup, privacy, and a persistent browser draft.
The repository uses Apache-2.0.

## Personal iPhone test route

The personal editor adds local records, backups, offline support, and a downloadable Scriptable widget file.
Users can install its host from the App Store and configure the medium rectangle using only an iPhone.
Browser changes require a new export. Personal words do not enter hosting requests.
The generated script uses documented Scriptable APIs and makes no network requests.
Automated host tests use mocks. Physical iPhone installation and rendering remain user acceptance steps.
See `IPHONE-ONLY.md` for instructions.

## Personal route checks

TypeScript and the production build passed. Twenty-eight browser checks passed across desktop and mobile.
The checks cover personal records, dates, pins, export, clipboard recovery, offline use, and accessibility.
Exported JavaScript passed host API tests with isolated mocks. These tests do not confirm physical widget rendering.
The final CI and deployment evidence belongs in the source release record.

## Original 1.0.0 checks

- TypeScript checks and the Vite production build passed.
- Twelve Playwright tests passed across desktop and mobile.
- The browser suite included axe checks for WCAG 2 AA and WCAG 2.1 AA.
- Git whitespace checks passed before the first feature commit.

Two README diagrams passed Mermaid parse and render checks.
Four YAML files passed parser checks.
The STE linter reported no errors. Advisory findings need judgment and do not establish dictionary compliance.

The github-hygiene archive contained no helper scripts. Direct checks covered required files, license, manifests, author identity, and commit messages.
The release used the actual Mermaid parser rather than an absent helper.
The independent website design review ended with `disposition: ship` after all three findings closed.

The owner supplied the GitHub workflow permission. The native checks run on macOS CI.
Six core tests passed. The app and widget compiled on Xcode 16.4 for an iPhone simulator.
Initial simulator runs passed edit, persistence, and invalid-text workflows.
The pin recording showed a test tap at the switch's rounded edge. The test now taps its center and checks its state before saving.
The editor also supplies a Done button to dismiss the keyboard.
The complete suite must pass on the final PR head before merge.
The final head, check runs, and merged commit appear in [PR 1](https://github.com/kandulanikhilvarma/keepline/pull/1).

## Provider state

The public repository exists at `kandulanikhilvarma/keepline`.
The connected Vercel project exists with the public domain `keepline-weld.vercel.app`.
Production must use the verified merged commit.
The final deployment result and public smoke checks belong in the release evidence attached to the source release.

## Apple activation

The owner has no Mac or Apple Developer account yet.
No signed device build, TestFlight release, App Store submission, or Apple acceptance exists.
Follow `APPLE-SETUP.md` for the exact next steps.

The owner must approve costs before paid enrollment.
The owner must accept Apple's legal agreements personally.
