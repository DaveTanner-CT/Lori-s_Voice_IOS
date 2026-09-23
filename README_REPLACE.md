# Lori's Voice Build 16 - Sub-tile save workflow fix

Replace only these files in the GitHub repository:

- `App/Web/index.html`
- `App/LorisVoiceWebView.swift`
- `project.yml`

## What changed

- Removed the artificial 450 ms delay from the Done button.
- A sub-tile editor now uses a clearly labeled **Save sub-tile** button.
- The editor now waits for confirmation from native iOS storage before closing.
- If native saving fails, the editor stays open and shows a save error.
- On successful sub-tile save, the parent tile editor refreshes immediately and shows **Sub-tile saved ✓**.
- Photo selection now reports **Photo added — saving…** and only changes to **Photo saved ✓** after native storage confirms the save.
- The current text fields are explicitly committed before a save request.
- Build number updated to 16.

No PIN timeout or communication-board locking behavior was added.
