# Test your personal widget with only an iPhone

Use [My Keepline](https://keepline-weld.vercel.app/personal.html) to make your widget file.
The [Scriptable app](https://apps.apple.com/in/app/scriptable/id1405459188) provides the native home-screen widget host.
This route needs no Mac or personal developer membership.
The standalone SwiftUI app still needs its separate Apple setup.

## Save your own lines

1. Open My Keepline in Safari.
2. Enter your own short line.
3. Choose Always, Today, This month, This year, or Custom dates.
4. Select Save line.
5. Add other lines if you want rotation.
6. Select Pin beside a line to keep it visible.

Your personal library starts empty. It can hold up to 50 lines, with 140 characters per line.
Use Widget settings and backups to add your name or change the interval.
The editor preserves existing period dates during an edit. Use the current period renews a dated line when you save.
Archive, restore, and delete controls change your saved records.

## Copy route

1. Install Scriptable from the App Store yourself.
2. Select Copy widget code in My Keepline.
3. Open Scriptable.
4. Tap + to create a script.
5. Paste the copied code.
6. Name the script `Keepline`.
7. Tap its play button to preview the medium rectangle.

If clipboard access fails, My Keepline shows the code and explains manual copying.
Select all the shown code, then copy it yourself.

## File route

1. Select Download Keepline.js.
2. Find the file in Safari Downloads or the Files app.
3. Move it into iCloud Drive → Scriptable, if that folder exists.
4. Open Scriptable and run Keepline.

If the Scriptable folder is unavailable, use the copy route.
If Safari displays the file, use Share → Save to Files.
Scriptable stores scripts as JavaScript files. Its [App Store description](https://apps.apple.com/in/app/scriptable/id1405459188) documents Files and iCloud support.

## Add the actual widget

1. Touch and hold an empty part of your home screen.
2. Tap Edit, then Add Widget.
3. Search for Scriptable.
4. Select its medium rectangular widget.
5. Add the widget.
6. Touch and hold the added widget.
7. Select Edit Widget.
8. Select the Keepline script.

Older iOS versions use a plus button to open the widget gallery.
Use the medium family. Other sizes show a prompt to choose the rectangle.
Tap the widget to open the script's preview in Scriptable.

## Update your words

1. Edit your saved lines or widget settings in My Keepline.
2. Copy the updated widget code.
3. Replace the code in the same Keepline script.
4. Run that script again.

The browser and Scriptable do not synchronize automatically.
The widget file contains a snapshot of your saved personal library.
Only active lines enter rotation. An inactive pin falls back to active lines.
The script requests the next interval or local midnight, whichever comes first.
Actual refresh timing belongs to iOS. See [Scriptable's widget timing documentation](https://docs.scriptable.app/listwidget/#refreshafterdate).

## Add the browser editor

1. Open My Keepline in Safari while online.
2. Wait for the Offline ready message.
3. Tap Share, then Add to Home Screen.
4. Open that shortcut to use the personal editor.

The shortcut opens the browser editor. Scriptable supplies the actual widget.
After setup, the editor can load offline and keep its local records.
If the shortcut opens an empty library, import a personal backup from Safari.
Browser settings or the operating system can remove browser storage. Export a personal backup before you remove it.

## Privacy and recovery

The page stores your library in this browser. It does not upload your words.
The generated script contains your words and makes no network requests.
Widget files and backups contain plain text. Keep them private.
Scriptable can synchronize scripts through iCloud if you enable that feature.

Export my lines creates a personal JSON backup.
Import personal backup checks the file before it requests replacement confirmation.
Native app backups use a different format. The personal editor does not import native backups.
An unreadable browser library requires an explicit import or reset before another save.
A failed save preserves your existing records and editor text.

## Acceptance on your iPhone

1. Preview your own line in Scriptable.
2. Check it in the medium home-screen widget.
3. Pin a different active line and copy the updated code.
4. Run the script and check the widget after iOS refreshes it.
5. Export and restore a personal backup.

Automated checks validate browser workflows and the generated script's documented API contract.
They do not establish installation or rendering in Scriptable on your physical iPhone.
That last acceptance check needs your device.
