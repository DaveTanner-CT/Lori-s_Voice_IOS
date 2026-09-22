# Lori's Voice iOS

This is the first native iPhone/iPad build of Lori's Voice.

The project keeps the existing HTML/JavaScript communication board as the primary interface, but bundles it inside the app so it works offline. When running inside the iOS app, the board uses native iOS services for speech, storage, photo selection, backup sharing, and backup import.

## Native features added

- **Offline app:** `index.html` is bundled in the application; the production app does not load the board from GitHub.
- **Native speech:** phrases are spoken with `AVSpeechSynthesizer`.
- **Native voice list:** installed Apple speech voices are exposed to the existing Voice setting.
- **Persistent app storage:** the board is saved to the app's Application Support directory as `board.json`.
- **Web fallback:** localStorage remains enabled so the same HTML file still works when hosted on the web.
- **Native photo picker:** tile photos use Apple's `PHPickerViewController` in the iOS app.
- **Native backup:** Save Board opens the standard iOS share sheet.
- **Native restore:** Load Board opens the iOS document picker for JSON backup files.
- **External links:** website links open in the user's browser instead of navigating the communication board away from the app.

## Bundle identifier

`org.scriptingforschools.LorisVoice`

Change this in `project.yml` only if a different identifier is required before the App ID is created in Apple Developer.

## Generate the Xcode project on a Mac

This repository uses XcodeGen so that the Xcode project can be regenerated cleanly from source.

1. Install Xcode from the Mac App Store.
2. Install XcodeGen if it is not already installed:

   ```bash
   brew install xcodegen
   ```

3. In Terminal, open this project folder and run:

   ```bash
   xcodegen generate --spec project.yml
   open LorisVoice.xcodeproj
   ```

4. In Xcode, select the **LorisVoice** target, choose your Apple Developer Team under **Signing & Capabilities**, and verify that the bundle identifier is `org.scriptingforschools.LorisVoice`.
5. Select an iPhone or iPad and press **Run**.

## Codemagic

A starter `codemagic.yaml` is included. It follows the same XcodeGen approach:

1. Connect this GitHub repository to Codemagic.
2. Configure Apple Developer / App Store Connect credentials in Codemagic.
3. Make sure the App ID `org.scriptingforschools.LorisVoice` exists in Apple Developer.
4. Run the **Lori's Voice - App Store** workflow.

The workflow generates `LorisVoice.xcodeproj`, applies the signing profiles, and builds an App Store IPA.

## Existing Lori's Voice code

The adapted production board is:

`App/Web/index.html`

The native integration is intentionally small. The main files are:

- `App/LorisVoiceApp.swift` - application entry point
- `App/ContentView.swift` - SwiftUI host view
- `App/LorisVoiceWebView.swift` - WKWebView and JavaScript/native bridge
- `App/BoardStore.swift` - persistent local board storage
- `App/SpeechController.swift` - native speech

## Moving an existing customized web board into the iOS app

Browser storage cannot automatically move into the installed iOS app. To transfer an existing customized board:

1. Open the current web version.
2. Unlock editing and open Settings.
3. Choose **Save board to a file (backup)**.
4. Install/open the iOS app.
5. Unlock editing and open Settings.
6. Choose **Load board from a file** and select the JSON backup.

After import, the board is stored in the iOS app container.

## First-device test list

Before TestFlight, verify these on a real iPhone and iPad:

- Starter board launches with Airplane Mode enabled.
- Each tile speaks once when tapped.
- Tremor/debounce behavior still prevents accidental double speaking.
- Sub-tiles open and return correctly.
- Normal and Slower speech speeds work.
- Changing voices changes the spoken voice and survives relaunch.
- Edit PIN works.
- Add/edit/delete/reorder tile behavior works.
- Photo selection works and the image survives force-quit/relaunch.
- Backup produces a JSON file through the iOS share sheet.
- Restore can load that backup.
- Four-tile and six-tile modes work in portrait and landscape.
- The built-in typing keyboard speaks typed text.
- The Scripting for Schools link opens externally.
- VoiceOver navigation is understandable.

## App icon

A temporary Lori's Voice icon is included so development/TestFlight builds have a valid icon asset. Replace it with final branding before App Store submission if desired.

## Privacy

A draft public privacy policy is included at `AppStore/PrivacyPolicy.md`. It should be published on a public Scripting for Schools webpage before App Store submission so App Store Connect has a privacy-policy URL.

## Validation already completed

The included build has been statically checked for:

- JavaScript syntax
- Required native bridge markers
- Swift parser errors
- Info.plist validity
- Asset catalog JSON validity

A full iOS build and runtime test still needs Xcode/Codemagic because this build environment does not contain Apple's iOS SDK or simulator.
