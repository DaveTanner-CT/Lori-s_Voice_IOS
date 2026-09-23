# Lori's Voice Build 12 compile fix

Replace only these two files in the GitHub repository:

- `App/BoardStore.swift`
- `project.yml`

No other files should be changed.

## Fix
Build 11 used `CocoaError(.fileWriteCorruptFile)`, but that `CocoaError.Code` member does not exist in the current Swift/Foundation SDK used by Codemagic. Build 12 replaces it with a small app-specific `BoardStoreError.invalidBoardData` error and increments the build number to 12.
