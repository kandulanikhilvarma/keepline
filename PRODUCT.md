# Keepline

<!-- impeccable:product-schema 1 -->

## Platform

ios

## Stack

The user delegated the stack choice. SwiftUI supplies native iPhone controls. WidgetKit supplies the rectangular home-screen widget.
A Foundation package holds the model, validation, storage, and timeline rules. A static Vite site supplies setup help and a browser preview.

## Users

Anyone who wants frequent reminders of their own words and goals can use Keepline.

## Product Purpose

Save a short line. Keep that line visible on the iPhone home screen. Rotate active lines throughout the day.

## Capabilities and Constraints

- Create, edit, archive, restore, pin, and delete personal lines.
- Set a period: today, this month, this year, always, or custom dates.
- Use one rectangular medium widget. Tap the widget to open its line.
- Select a rotation interval of 30, 60, or 180 minutes.
- Export a backup. Validate and replace records from a backup after confirmation.
- Keep all records in the local App Group container. Use no cloud account, analytics, or payment service.
- iOS controls actual widget updates. A new line on every unlock is not available.
- iPhone installation needs Apple signing. App Store distribution needs the owner's Apple account and review.

## Assumptions

- The first release needs no remote database or account. The iPhone sandbox defines the data boundary.
- A day ends at local midnight. Month and year goals end with the current calendar period.
- A custom period includes both dates. Expired lines stay in the library until the user changes or deletes them.
- Lines contain at most 140 characters. One line can wrap visually in the widget.
- The browser preview keeps its own local draft. The preview does not install or synchronize an iPhone widget.

## Brand Commitments

The user delegated the name and design. The chosen name is Keepline. The app uses calm, direct copy.

## Evidence on Hand

The user's examples are “Be calm.”, “Read 5 books in a month”, and an annual goal of 10 lakhs.
Examples appear only as labeled previews. Production records start empty.
The user has neither a Mac nor an Apple Developer account.

## First Release Acceptance

1. A new installation starts with no personal records.
2. A saved line survives an app restart.
3. Invalid text, dates, files, and duplicate backup identifiers fail without data loss.
4. Archived, future, and expired lines do not appear in new widget timelines.
5. A pin keeps one active line visible. An inactive pin falls back to active rotation.
6. The app and extension build for an iPhone simulator.
7. The native interface supports VoiceOver, Dynamic Type, and dark appearance.
8. The website states the installation limits and works on desktop and mobile.

## Pricing and Services

The app source is free under Apache-2.0. The release has no paid app features.
GitHub hosts the public repository and CI. Vercel hosts the static site.
Apple controls signing, distribution, and store acceptance. The owner must approve enrollment costs and personally accept Apple agreements.

## Roadmap

Later releases can add multiple widget configurations, optional iCloud sync, translations, and notification reminders.
Cloud accounts, subscriptions, generated advice, and financial integrations are outside this release.
