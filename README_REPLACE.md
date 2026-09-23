Lori's Voice v10 replacement files

Replace these files in the GitHub repository:
1. /project.yml -> project.yml
2. /codemagic.yaml -> codemagic.yaml
3. /App/Info.plist -> Info.plist in this package (optional if your current App/Info.plist already matches v8/v9)

Do not move or rename App/LegacyIcons or App/Assets.xcassets.

The key v10 fix is that XcodeGen resources are declared inside `sources:` with `buildPhase: resources`. The prior `resources:` block was not creating the expected Copy Bundle Resources entries for the legacy icon PNG files.
