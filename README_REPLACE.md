# Lori's Voice - Build 17 replacement files

Replace only these files in the repository:

- `App/Web/index.html`
- `project.yml`

Build 17 fixes the Add Sub-tile save workflow. After a successful native save, **Save sub-tile** now closes the tile editor completely and returns to the communication board. It no longer switches silently back to the parent tile editor, which made the photo preview appear to disappear and left users unsure what to do next.

No PIN, locking, speech, or storage format behavior was changed in this build.
