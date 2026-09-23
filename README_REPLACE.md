# Lori's Voice Build 15

Replace only these files in the repository:

1. `App/Web/index.html`
2. `project.yml`

Build 15 adds clear save feedback to the tile/sub-tile editor:
- Selecting a photo shows `Photo added and saved ✓`.
- Tapping Done changes the button to `Saved ✓` briefly before closing.
- A short confirmation appears after closing: `Tile saved ✓` or `Sub-tile saved ✓`.
- The confirmation uses an ARIA live status for VoiceOver users.
- Speaking-speed labels are aligned with the current native rates: Slow, Normal, Fast.

No lock, PIN timeout, or communication-board access behavior was changed.
