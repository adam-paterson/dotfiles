# Git and chezmoi diffs

Use Diffview for Git changes and conflicts, native Neovim diff for chezmoi merges,
and delta for read-only terminal diffs. Fugitive is not required; `:Git` is provided
by mini.git. `Space gg` opens LazyGit.

## Neovim keys

Press Space, then the listed letters. For diff and history views, lowercase means
the repository and uppercase means the current file.

| Keys after Space | Action |
| --- | --- |
| `gd` / `gD` | Diffview working changes, repository / file |
| `ga` / `gA` | Diffview staged changes, repository / file |
| `gh` / `gH` | Diffview history, repository / file |
| `gc` / `gC` | Commit / amend commit |
| `gl` / `gL` | Git log, repository / file |
| `gq` | Close Diffview |
| `gf` / `gF` | Toggle / focus Diffview's file panel |

`gf` and `gF` are local to Diffview. Explorer shortcuts under `Space e` and buffer
shortcuts under `Space b` remain available there. History bindings now follow the
same repository/file convention as diff bindings; this reverses the old `gh`/`gH`.

Within Diffview:

- `j` / `k`, then Enter select a file in the panel.
- Tab / Shift-Tab move between files.
- Ctrl-w followed by h, j, k, or l moves between windows.
- `]c` / `[c` move between diff hunks; `]x` / `[x` move between conflicts.
- `g?` shows contextual help; `q` closes the view.
- `s` in the file panel stages or unstages the selected file.
- `X` restores a file and discards changes. Avoid it unless that is intended.

## Resolve a Git conflict

After a merge or rebase stops, open Neovim in the repository and press `Space gd`.
The top panes show OURS and THEIRS. Edit the bottom working-file pane.

1. Navigate to a conflict with `]x`.
2. Use `Space co` for ours, `Space ct` for theirs, or edit manually.
3. `Space cb` selects the common ancestor; `Space ca` keeps all versions' content.
   Review combined content for duplicates and ordering.
4. Save the result with `:w`, review it, then stage with `s` in the file panel.
5. Close the view and run `git merge --continue` or `git rebase --continue`.

During a rebase, OURS is the branch being rebased onto and THEIRS is the commit
being replayed. Inspect the contents rather than assuming OURS is your feature.

## Merge a chezmoi file

Run `chezmoi merge PATH`, using the home-directory path of a managed file.
This intentionally opens native Neovim diff, not Diffview.

| Panel | Contents |
| --- | --- |
| 1 | Destination: actual home-directory file |
| 2 | Source: managed file or template to edit |
| 3 | Target: temporary rendered output, not a Git common ancestor |

- `Space gm1`, `gm2`, `gm3` focus the numbered panels.
- `]c` / `[c` navigate differences; `Space gmn` / `gmp` are aliases.
- `Space gml` / `gmr` copy a hunk from the first / last panel into the current one.
- `Space gmg1`, `gmg2`, `gmg3` copy a hunk from a specific panel.

To import a home-directory change, focus source with `Space gm2`, navigate to the
hunk, and press `Space gml`. Preserve template expressions. Save source with `:w`
and exit with `:qa`. Review `chezmoi diff PATH`, then run `chezmoi apply PATH`.
Saving source files no longer automatically applies them. Numbered-panel shortcuts
are only active in native diff windows, not Diffview's Git layouts.

## Terminal diffs

`git diff`, `git diff --cached`, `git show`, and `chezmoi diff` use delta on this
machine. In delta's pager, `n` / `N` navigate differences and `q` quits.
The Git pager settings currently live in unmanaged `~/.config/git/config`;
`~/.config/git/local.gitconfig` no longer overrides the pager.

## Verification

Run `python3 tests/test_diff_workflow.py` with Neovim and the configured plugins
installed. It loads the repository config against temporary files, checks the
bindings, resolves a Git conflict, and copies a native diff hunk without saving
or applying real dotfiles.
