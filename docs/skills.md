# Skills

The global skills inventory is a skills CLI *project*: the lockfile is
`~/.agents/skills-lock.json` (chezmoi-managed from `src/dot_agents/skills-lock.json`,
symlinked into `$HOME` as `~/skills-lock.json`), and the canonical install
directory is `~/.agents/skills`, which Amp reads directly. Harness links
(Claude Code, Codex, Cursor, Gemini CLI, Copilot, OpenCode, Pi, and the rest the
CLI detects) are created by the CLI itself on every install, honoring
`XDG_CONFIG_HOME`, `CLAUDE_CONFIG_DIR`, and `CODEX_HOME`.

The lock is schema v2: every entry carries the git `commit` it came from and a
`computedHash` of the installed files, so restores are exact and hash-verified:

```sh
cd "$HOME"
npx skills@1.9.0 install --frozen-lockfile
```

The reconciler wraps that as `~/.local/bin/skills-sync` (chezmoi-managed from
`src/dot_local/bin/skills-sync`); the chezmoi hook
`run_onchange_after_95-install-skills.sh` runs it whenever the lockfile or the
hook changes. On a fresh machine the first apply installs all 169 selections at
their pinned commits — no interactive steps.

## Pruning

The lockfile is the source of truth: `skills-sync` also deletes directories in
`~/.agents/skills` with no lock entry, except ones chezmoi manages directly
(vendored/authored skills). Safety rails:

- Without `~/.agents/.skills-prune-armed`, pruning is a dry run: it lists
  candidates and deletes nothing. `touch ~/.agents/.skills-prune-armed` to arm.
- `skills-sync --no-prune` or `SKILLS_PRUNE=0` skips pruning entirely.
- `skills-sync --dry-run` never deletes.

## Daily commands

The fish `skill` function runs the CLI from `$HOME` (where the lock is symlinked)
and never deletes:

```sh
skill add ast-grep/agent-skill --skill ast-grep -y
skill update -p          # refresh locked skills, move pins forward
skill remove <name> -y   # removes files, lock entry, and harness links
skill check              # report available updates
skill sync               # the reconciler: frozen install + prune
skill sync --dry-run
```

After `skill add`/`update`/`remove`, save the lock into the repo:
`chezmoi re-add ~/.agents/skills-lock.json`. Unsaved local changes are pruned on
the next lock-changing apply — that is the contract.

## Git authentication

`~/.config/git/config` routes `https://github.com` through
`gh auth git-credential`, giving git the authenticated 5000/hour quota.
Unauthenticated git traffic shares 60/hour per IP, which the CLI's clone bursts
exhaust (HTTP 429). Keep `gh auth login` current on every machine, including
Seraph.

## Pstack

All 58 pstack skills from `cursor/plugins/pstack/skills` are selected at revision
`c5149ef275fa7be41e3ffe5e79c8fc16efcaeedc` and now carry per-skill commit pins in
the lockfile itself. The corresponding README, guide, harness adapter, and
subagent reference files are fetched by `.chezmoiexternal.toml` into `~/.agents`;
keep that archive revision aligned with the lockfile's pstack entries when
updating. `tdd` and `teach` select pstack's versions rather than Matt Pocock's.
Installing skills does not apply model settings (`setup-pstack` is a separate,
explicit step).

## History

Microsoft APM (`src/dot_apm`, September 2026) was replaced on 26 October 2026:
it only installs APM packages, which does not fit the loose GitHub sources here,
and it has no Pi/Amp targets. Skills CLI global scope (`-g`) was also rejected:
it keeps its lock in `~/.agents/.skill-lock.json` but has no restore command, so
reproducibility on Seraph would still need a staging workaround. The project
layout above gives the same lockfile guarantees with supported commands only.
`~/.agents/.skill-lock.json` is CLI bookkeeping, not managed by chezmoi.
