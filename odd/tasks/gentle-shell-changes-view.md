# Gentle Shell changes-view exploration

## Goal
Create a local, throwaway visual prototype inspired by Gentle Shell's Git changes overlay, plus a pointer from existing Git workflow documentation.

## Tasks
1. Inspect workspace documentation and Gentle Shell changes-view implementation. **Done**
2. Add standalone HTML prototype and link it from the existing Git workflow guide. **Done**
3. Review changed files and validate the prototype opens locally. **Done**

## Allowed edit surfaces
- `docs/git-and-chezmoi-diffs.md`
- `docs/gentle-shell-changes-view-prototype.html`
- `odd/tasks/gentle-shell-changes-view.md`

## Scope
Prototype is static and self-contained; no production code or live Git access.

## Evidence
- Added `docs/gentle-shell-changes-view-prototype.html` as a standalone static HTML/CSS prototype with sample file-list and diff-preview data only.
- Linked the prototype from `docs/git-and-chezmoi-diffs.md` under “Gentle Shell changes overlay prototype.”
- Ran `python3 - <<'PY' ... PY` to parse the HTML and verify it has no scripts, no external HTTP(S) references, and includes the expected sample overlay content.
- Confirmed the local file URI is `file:///Users/adampaterson/.local/share/chezmoi/docs/gentle-shell-changes-view-prototype.html`.
- No commit was created.
