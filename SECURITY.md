# Security

## Supported version

Report security defects in version 1.0 through the contact below.

## Report a defect

Send a private report to [kandulanikhilvarma@gmail.com](mailto:kandulanikhilvarma@gmail.com).
Include the affected version, steps to reproduce, and the possible data exposure.
Do not include private lines, credentials, or personal backup files.
Do not publish a data exposure report in a public issue before the owner reviews it.

## Data boundary

The app has no server or user accounts. iOS controls access to its sandbox and App Group.
Only the app and its widget target use the configured App Group identifier.
The app writes records as an atomic JSON file. The widget only reads the file.
The app preserves the previous valid save for recovery.

On iOS, files use protection until the first device unlock after restart.
That protection permits the widget to read its timeline after the first unlock.
Use the device passcode to protect access to the iPhone.
Keepline has no separate app lock.

The widget exposes its text to anyone who can see the home screen.
Do not save secrets in a visible widget.
Exported backups contain plain text. Store backups in a private location.

The website keeps one preview draft in browser storage. The site has no synchronization API.
Vercel receives normal website requests. The site adds no analytics or advertising scripts.

## Validation

The app rejects oversized files, unsupported versions, duplicate identifiers, invalid dates, and invalid text.
An import replaces records only after validation and user confirmation.
The site inserts user text with `textContent`. The site does not parse user text as HTML.
