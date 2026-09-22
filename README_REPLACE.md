# Lori's Voice v7 icon validation fix

Replace/add these exact paths in the GitHub repository:

- `/project.yml` -> replace
- `/codemagic.yaml` -> replace
- `/App/Info.plist` -> replace
- `/App/Assets.xcassets/AppIcon.appiconset/` -> replace the folder contents
- `/App/LegacyIcons/` -> add this new folder and all files in it

Do not put any of these files or folders at the repository root except `project.yml` and `codemagic.yaml`.

This version deliberately packages conventional loose iPhone/iPad icon PNGs in addition to the AppIcon asset catalog. The Codemagic verification step will fail before publishing unless the finished IPA contains both the 120x120 and 152x152 PNGs with the expected dimensions.
