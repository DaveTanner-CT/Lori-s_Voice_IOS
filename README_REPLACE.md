# Lori's Voice iOS - Build 11 replacement files

Replace the matching files in the GitHub repository with the files in this package.

## Replace these exact paths
- `project.yml`
- `codemagic.yaml`
- `App/Info.plist`
- `App/BoardStore.swift`
- `App/LorisVoiceWebView.swift`
- `App/SpeechController.swift`
- `App/Web/index.html`

## Leave these alone
- `App/Assets.xcassets/`
- `App/LegacyIcons/`
- `App/ContentView.swift`
- `App/LorisVoiceApp.swift`
- provisioning profiles / certificates

## Build 11 changes
- Accessibility labels and keyboard focus improvements for VoiceOver/assistive access.
- Communication board remains immediately available on launch. No automatic locking or re-PIN behavior was added.
- Safer native board storage with a local previous-good copy for recovery.
- Versioned backup format with validation and compatibility with older raw JSON backups.
- Restore-success feedback and clearer invalid-backup messages.
- Extra "Very slow" speech option and smoother native speech-rate mapping.
- Save-on-background/page-hide lifecycle protection.
- Help screen now shows app version/build and confirms local device storage.
- Optional "Start a new blank board" action in Settings; it never interrupts normal startup.

## Test after installing Build 11
1. Open app and confirm the communication board is immediately usable.
2. Tap several tiles and test Normal, Slower, and Very slow speech.
3. Make a board edit, force-quit, reopen, and confirm the edit remains.
4. Save a backup, make another change, then restore the backup.
5. Confirm an old backup from the current app can still be imported.
6. Turn on VoiceOver and navigate the top controls and several tiles.
7. Test on iPad landscape and portrait.
