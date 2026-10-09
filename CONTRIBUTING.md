# Contribute to Keepline

Use a feature branch. Keep each change small enough for review.

## Local checks

1. Run `swift test` from the repository root on a Mac.
2. Run `npm ci` from `site`.
3. Run `npm run build`.
4. Run `npx playwright install chromium`.
5. Run `npm test`.
6. Generate the iOS project with `xcodegen generate` from `ios`.
7. Run the Keepline scheme on an iPhone simulator.

Test changes to periods at local midnight. Test month boundaries and time-zone changes.
Use isolated records in tests. Keep personal backups out of Git.

## Pull requests

Describe the problem and the resulting behavior. Include the checks that you ran.
Use a concise Conventional Commit subject. Use a message file for local commits.
Do not add automated co-author trailers.

For this repository, commits use `Nikhilvarma Kandula <267753970+kandulanikhilvarma@users.noreply.github.com>`.
External contributors must use their own verified identity.

Changes must pass the website and iPhone workflows before merge.
The owner backs up the base branch, then squash-merges the verified head.

## Design

Keep native system controls. Respect Dynamic Type, VoiceOver, dark appearance, and reduced motion.
Use the design rules in `DESIGN.md`. Test keyboard focus and narrow layouts on the website.

## License

Contributions use the repository's Apache-2.0 license.
