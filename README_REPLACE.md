# Lori's Voice Build 24

Fixes the Help & Info button.

Replace only:
- `App/Web/index.html`
- root `project.yml`

The Info handler now uses the correct `currentVoice()` helper and opens the panel before refreshing diagnostics, so a diagnostics error cannot prevent Help & Info from opening.
