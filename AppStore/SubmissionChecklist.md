# Lori's Voice - App Store Submission Checklist

## Apple developer setup

- Create/register App ID: `org.scriptingforschools.LorisVoice`.
- Create a new app in App Store Connect with the bundle ID above.
- Confirm the final public app name is available. The project display name is currently **Lori's Voice**.
- Connect the repository to Codemagic or open the generated Xcode project locally.

## Build and device testing

Test on both iPhone and iPad before external TestFlight review:

- App launches completely offline.
- All starter tiles display correctly.
- Tile speech works with Normal and Slower rates.
- Voice selection persists after relaunch.
- PIN edit mode works.
- Add, edit, delete, reorder, and sub-tile workflows work.
- A photo can be selected for a tile and persists after relaunch.
- Four-tile and six-tile layouts work in portrait and landscape.
- Backup opens the iOS share sheet.
- Backup JSON can be restored through the iOS document picker.
- A restored board persists after force-quitting and relaunching the app.
- The Scripting for Schools link opens outside the app.
- VoiceOver labels and focus order are reviewed.

## App Store Connect content still needed

- Final app icon/branding approval.
- iPhone screenshots.
- iPad screenshots.
- App description, subtitle, keywords, and support URL.
- Public privacy-policy URL. A draft is included in `AppStore/PrivacyPolicy.md`.
- Age-rating questionnaire.
- Pricing and availability.
- App Review contact information.
- App Review notes explaining that Lori's Voice is an offline communication board and does not require login.

## App privacy expectation

The current build does not include accounts, analytics, advertising, remote board storage, or a Lori's Voice backend. Based on the implementation, the expected App Privacy selection is **Data Not Collected**, but confirm the final production build before submitting the privacy questionnaire.
