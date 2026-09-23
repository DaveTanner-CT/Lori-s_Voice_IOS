# Lori's Voice Build 14 replacement files

Replace these files in the repository:

- `App/BoardStore.swift`
- `App/SpeechController.swift`
- `App/Web/index.html`
- `project.yml`

## Build 14 changes

- Renames speaking speeds to **Slow / Normal / Fast** without changing the rates that were working in Build 13.
- Keeps the immediate spoken speed preview.
- Moves persisted tile photos out of `board.json` into `Application Support/LorisVoice/Photos`.
- Existing Base64 photos migrate automatically the next time the board is saved.
- Board backups remain self-contained because photos are hydrated back into the in-memory board as data URLs.
- Keeps the prior-board recovery copy and retains photos referenced by that recovery copy.

No PIN timeout or automatic communication-board lock has been added.
