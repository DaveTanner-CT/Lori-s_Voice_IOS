# Lori's Voice Build 13 - Speaking Speed Fix

Replace exactly these files in GitHub:

1. `App/SpeechController.swift`
2. `App/Web/index.html`
3. root `project.yml`

Do not replace any other files.

## What changed
- Native iOS speech now uses three clearly separated AVSpeechSynthesizer rates:
  - Very slow: 0.30
  - Slower: 0.40
  - Normal: 0.52
- Tapping a speed setting immediately speaks: "This is the selected speaking speed."
- The selected speed button is visibly highlighted.
- Speed buttons expose `aria-pressed` state for accessibility.
- Build number is 13.
