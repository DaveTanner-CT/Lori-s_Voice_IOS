# Lori's Voice - Build 18 replacement files

Replace only these files in the repository:

1. `App/Web/index.html`
2. `project.yml`

Build 18 fixes two related sub-tile interaction bugs:

- The tap debounce now applies only to repeated taps on the same tile. Opening a parent tile no longer causes the first tap on a sub-tile to be ignored.
- The delayed parent "speaking" render no longer rebuilds the newly opened sub-board. This prevents a newly uploaded sub-tile image from being briefly replaced/interrupted before it finishes displaying.

Expected behavior:

- Save a new sub-tile with a photo.
- Open the parent tile.
- The sub-tile photo should be visible immediately.
- The first tap on the sub-tile should speak immediately.
