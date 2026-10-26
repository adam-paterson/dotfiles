# Skills

Chezmoi manages `~/skills-lock.json` from `src/skills-lock.json`. APM is no longer
declared or invoked. The install hook filters out existing skills and runs the
CLI's native restore in a temporary project:

```sh
npx skills@1.7.0 experimental_install
```

The hook runs on first apply and when the lockfile or hook changes. It checks
that every requested skill was restored before copying missing directories to
`~/.agents/skills`, which Amp discovers directly. It then adds missing links for
Claude Code, Codex, Cursor, Gemini CLI, GitHub Copilot, OpenCode, Pi, Continue,
Factory, and Kiro. Amp needs no additional links under `~/.config/agents/skills`.
The hook respects `XDG_CONFIG_HOME`, `CLAUDE_CONFIG_DIR`, and `CODEX_HOME`.
Existing canonical skills, custom files, and links are preserved, including
dangling links. Fix dangling links explicitly if needed.

Do not run native restore directly in your home directory to synchronize this
inventory. It replaces selected skill directories and can return success after
a partial failure. The hook isolates those writes and checks completeness.

## Pstack

All 58 skills from `cursor/plugins/pstack/skills` are selected at revision
`c5149ef275fa7be41e3ffe5e79c8fc16efcaeedc`. Full skill directories include
playbooks, scripts, and references. The corresponding README, guide, harness
adapter, and subagent reference files are fetched by chezmoi into `~/.agents`
so relative documentation links resolve. Keep that archive revision aligned
with the pstack entries in the lockfile when updating.

`tdd` and `teach` select pstack's versions rather than Matt Pocock's. During the
initial reconciliation, conflicting copies were backed up before replacement;
normal applies remain additive. Harness-specific pstack copies were replaced
with links to the shared installation so they cannot shadow it.

No model settings are synchronized by this installer. It does not run
`setup-pstack` or write `pstack-models.mdc`, `pstack-models.md`, or harness
configuration. The setup skill and upstream model recommendations remain in
the skill content; installing them does not apply those recommendations.

This is a skills installation, not a pstack plugin installation. Making the
files available does not register plugin subagent types or provide Cursor-only
features in other harnesses. Those workflows still depend on harness support.

## Add and update

Run these commands from your home directory, without `-g`:

```sh
cd "$HOME"
npx skills@1.7.0 add ast-grep/agent-skill --skill ast-grep -a universal -y
npx skills@1.7.0 update -p
chezmoi re-add ~/skills-lock.json
chezmoi apply
```

Updates replace local changes in the selected skill. Back them up first.
For one update, use `npx skills@1.7.0 update ast-grep -p`. Save the updated lockfile
before applying chezmoi, or chezmoi will restore the previously saved metadata.
The apply also creates missing harness links for newly added skills.

To remove a skill, run `npx skills remove name -y` from home and save the lockfile.
The hook does not prune old harness links or uninstall entries removed by
hand from the lockfile.

## Migration and limits

The project lockfile contains 168 selections, including the full pstack set.
Twelve retired upstream names were removed from the earlier 125-name inventory;
removing their selections did not delete installed skills.
`implement-spec` stays with `adam-paterson/skills`; `show-me` stays with
`dmmulroy/.dotfiles`. Existing installations are not replaced to change providers.
Initial `computedHash` fields are empty because global Git tree hashes are not
project content hashes. The hook leaves the managed manifest unchanged.

Pstack, the Plannotator extras, and `show-me` use `source` and `skillPath` without
a `.git` URL. In Skills 1.7.0, that URL takes precedence and prevents path-targeted
restoration. Other entries select by name from the repository, so moving a skill
within its repository does not break restoration.

The retired names are `batch-grill-me`, `decision-mapping`, `design-an-interface`,
`edit-article`, `resolving-merge-conflicts`, `to-issues`, `to-prd`,
`ubiquitous-language`, `write-a-skill`, `writing-great-skills`, `zoom-out`, and
`to-gherkin`. Their documented successors are already selected. Upstream removed
`edit-article`, `resolving-merge-conflicts`, and `zoom-out` without replacements.

Pstack is revision-pinned; the other selections are not frozen installs.
Native restore fetches each source at its recorded Git ref, or its current
default branch when no ref is recorded. Hashes support
update detection; they do not pin restoration to those bytes. The CLI's restore
command is experimental. Updates remain explicit rather than running on each apply.

`~/.agents/.skill-lock.json` is no longer managed by chezmoi. The old global
metadata, APM data, and existing agent-specific skills are left in place.
Do not use `skills update -g` for this inventory.
