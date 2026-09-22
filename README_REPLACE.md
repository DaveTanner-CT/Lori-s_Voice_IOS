Lori's Voice iOS - v8 replacement files

Replace these files/folders in GitHub:

1. root/project.yml
2. root/codemagic.yaml
3. App/Info.plist
4. App/LegacyIcons/ (keep/replace with the folder included here)
5. App/Assets.xcassets/AppIcon.appiconset/ (keep/replace with the folder included here)

Do not add any of these folders at the repository root.

The key v8 fix is a post-build Xcode script that explicitly copies the required loose iPhone/iPad icon PNG files into the root of the finished .app bundle before signing/export. The Codemagic verifier then checks the finished IPA for the exact 120x120 and 152x152 PNGs and validates the code signature before publishing.
