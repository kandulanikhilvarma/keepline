# Install Keepline on an iPhone

The repository contains an iPhone app and a WidgetKit extension.
The public site is active only as a setup guide and browser preview.
An App Store or TestFlight release needs separate Apple activation.

## Requirements

- A Mac with Xcode 16 or newer.
- An iPhone with iOS 17 or newer.
- XcodeGen to generate the project.
- An Apple team that supports App Groups for device signing.

The owner currently has neither a Mac nor an Apple Developer account.
The repository has no Apple signing certificate, provisioning profile, or store credentials.
CI builds simulator software. CI does not produce a signed iPhone installation file.

Review [Apple's membership comparison](https://developer.apple.com/support/compare-memberships/) before enrollment.
App Store and TestFlight distribution need Apple Developer Program membership.
Apple controls capabilities available to each membership.
Do not expect a free personal team to provision the App Group for this release.
The owner must approve any paid enrollment and accept Apple's agreements personally.

## Generate the project

1. Install Xcode on the Mac.
2. Install XcodeGen with Homebrew.
3. Clone the repository.
4. Generate the project.

```sh
brew install xcodegen
git clone https://github.com/kandulanikhilvarma/keepline.git
cd keepline/ios
xcodegen generate
open Keepline.xcodeproj
```

The project file comes from `ios/project.yml`. Regenerate the project after changes to that file.

## Configure Apple signing

1. Open Xcode Settings.
2. Add your Apple account.
3. Select the Keepline app target.
4. Select your team under Signing and Capabilities.
5. Select the same team for the KeeplineWidget target.
6. Register the App Group identifier with your Apple team.
7. Enable that App Group for both bundle identifiers.
8. Check the same identifier in both targets' App Groups capability.

Default identifiers:

| Item | Identifier |
| --- | --- |
| App | `studio.kandula.keepline` |
| Widget | `studio.kandula.keepline.widget` |
| Shared group | `group.studio.kandula.keepline` |

For another owner, change both bundle identifiers in `ios/project.yml`.
Change `APP_GROUP_IDENTIFIER` in that file.
Regenerate the project before you configure signing.
The generated Info files and entitlements use the shared build setting.

See [Apple's App Group guide](https://developer.apple.com/documentation/xcode/configuring-app-groups) for capability setup.

## Run on your iPhone

1. Connect your iPhone to the Mac.
2. Enable Developer Mode if iOS requests it.
3. Select the iPhone as the run destination.
4. Run the Keepline scheme.
5. Save your first line in the app.
6. Return to the home screen.
7. Touch and hold an empty area.
8. Tap Edit, then Add Widget.
9. Search for Keepline.
10. Select the medium rectangular widget.

On an older iOS version, use the plus button to open the widget gallery.
The release supports only the medium home-screen widget.

## Check on a real device

1. Save two active lines.
2. Select a rotation interval.
3. Check that the widget shows an active saved line.
4. Pin one line from its Library context menu.
5. Check that the widget displays that line after iOS reloads it.
6. Edit the line through a tap on the widget.
7. Archive the line.
8. Check that the next timeline excludes the archived line.
9. Check a goal at local midnight and at the end of its period.
10. Export a backup from Settings.
11. Import that backup after the replacement confirmation.

Apple controls widget timing. Updates cannot occur on every unlock.
See [Apple's timeline guidance](https://developer.apple.com/documentation/widgetkit/keeping-a-widget-up-to-date).

## Recover shared storage

If the app reports unavailable storage, check signing for both targets.
Check that both targets use the same App Group identifier.
Reinstall the build only after you preserve a backup of your lines.

If the app cannot read a saved file, use Restore previous save.
If the previous save is unavailable, import an exported backup from Settings.
The app does not replace an unreadable file with an empty library.

## Publish through Apple

1. Approve enrollment cost before you enroll.
2. Accept Apple's legal agreements yourself.
3. Create the app record in App Store Connect.
4. Archive the Keepline scheme with device signing.
5. Upload the archive from Xcode Organizer.
6. Complete Apple's privacy and export questions.
7. Test a signed build through TestFlight.
8. Submit the app for review.
9. Add the accepted store link to the public site.

The app has no external networking or analytics code.
The included privacy manifest declares no collected data or tracking.
Review those declarations against the final signed build before submission.
