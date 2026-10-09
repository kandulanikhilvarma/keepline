# Keepline design

## Direction

The user delegated the visual identity. The chosen direction uses the clarity of a desk memo.
The line is the main content. Controls remain secondary to the saved words.

The explored sources included a sticky note, a calendar, and a field guide.
Other sources included a library slip, an editorial page, a desk memo, and transit signs.
The desk memo supports the brief through direct text, a quiet surface, and an obvious period label.
The design uses no dashboard metrics or invented activity.

## Native app

Use SwiftUI navigation, lists, forms, pickers, sheets, alerts, and tab bars.
Use San Francisco for controls. Use the system serif for the main line.
Text follows Dynamic Type. The widget permits text to wrap within its rectangle.

The three tabs are In sight, Library, and Settings.
The line editor appears as a sheet. Unsaved changes need a discard confirmation.
Library swipe actions expose Archive and Delete. Its context menu also exposes Pin and Edit.

Shared color assets define the accent and widget paper in light and dark appearance.
The widget only supports the medium home-screen family.

## Website

Use parchment `#f4f2e9`, forest ink `#223b31`, leaf `#dce2c6`, and muted text `#536259`.
Newsreader supplies display type. The system sans supplies controls and body text.
The site self-hosts Newsreader under its OFL license.

The opening places the product statement beside a rectangular widget preview.
The browser draft form follows the opening. Setup and privacy content follow the form.
Narrow screens stack the content in the same order.
The preview uses the user's text with no HTML interpretation.

## States

- Empty: invite a first line and show an explicit example in the website preview.
- Disabled: prevent a blank or oversized save.
- Error: name the invalid text, dates, storage, or backup.
- Recovery: retry shared storage, restore a previous save, or import a valid backup.
- Success: show the saved native line or confirm the browser draft.
- Save progress: disable the website save control during its storage request.
- No active lines: explain the period and archive filters.

Focus uses a visible outline. Website controls have generous touch targets.
Native controls follow the iOS touch target size. Color never supplies the only state cue.
Reduced motion removes website transitions and smooth scroll.
