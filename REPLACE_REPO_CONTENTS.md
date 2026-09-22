# Replace the current GitHub repository with this clean copy

This package is a complete Lori's Voice iOS repository. Do not upload the ZIP itself into the repository.

The repository root should contain only these top-level items:

- App/
- AppStore/
- Scripts/
- .gitignore
- README.md
- REPLACE_REPO_CONTENTS.md
- codemagic.yaml
- project.yml

There should NOT be a root-level `AppIcon.appiconset` folder and there should NOT be a root-level `LorisVoice_Info_v4.plist` file.

The required plist is exactly:

`App/Info.plist`

The required app icon catalog is exactly:

`App/Assets.xcassets/AppIcon.appiconset/`
