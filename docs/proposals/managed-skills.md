# Proposal: managing global agent skills

For Planinator card **Managed skills** (crd_01M7Q74Y3KZYF0AKHBRTVMMQN9), 2026-11.

## Where we are

`src/skills-lock.json` (169 selections) + `run_onchange_after_95-install-skills.sh.tmpl`
already restore missing skills via `npx skills@1.7.0 experimental_install` into a
staging directory, copy them to `~/.agents/skills` (Amp's canonical dir), and link
them for Claude, Codex, Cursor, Gemini, Copilot, OpenCode, Pi, Continue, Factory
and Kiro. APM was tried in September (`src/dot_apm`) and replaced on 26 Oct
because it only covered a handful of skills and didn't fit the loose,
repo-level skill sources the inventory actually pulls from.

## Options considered

| Option | Reproducibility | Coverage of our 169 skills | Extra runtime | Verdict |
| --- | --- | --- | --- | --- |
| **npx skills (current, upgraded)** | v2 lock: `computedHash` + `commit` per skill; `install --frozen-lockfile` | Native — it is the tool that wrote the lock | Node 22.20+ (already via mise on Seraph) | **Recommended** |
| **Microsoft APM** (`apm-cli`, pip) | Good: `apm.lock.yaml` with resolved commits + SHA-256 content hashes | Weak: installs APM *packages*; most of our sources (`cursor/plugins/pstack`, `mattpocock/skills`, personal repos) aren't APM packages | Python | Drop — no Pi/Amp targets either |
| **Maintain all skills in-repo** | Perfect (bytes in git) | Needs vendoring + manual updates for 169 skills, ~all of which we don't author | None | Only for skills we author |
| pixi-skills / CocoaSkill / dotagents etc. | Varies | Small ecosystems, extra tooling | Pixi/conda or nothing standard | No benefit over skills CLI |

## Recommendation

1. **Keep the npx skills approach — it already does what the card asks** (library
   + generated lockfile + Seraph-compatible). Upgrade it:
   - Bump the pinned CLI from `skills@1.7.0` to the current release (`1.9.0`).
   - Regenerate the lock as **version 2** so every skill gets a `commit` pin and
     a `computedHash`; the hook can then use `install --frozen-lockfile` semantics
     (hash-verified restore) instead of the current partial-failure workaround
     staging. Keep the staging/check pattern until restore proves stable on v2.
   - Update `npx skills` on Seraph just works: the hook only needs `npx` and the
     lockfile, both supplied by chezmoi.
2. **Move authored skills into the repo.** Skills we write (`chezmoi-workflows`,
   poteto mode, personal principle skills, etc.) belong in
   `src/dot_agents/private_skills/<name>` managed by chezmoi directly — no CLI,
   perfect reproducibility, trivially edited. Remove them from the lock.
3. **Keep APM out.** It can't express our sources without authoring wrapper
   packages, and `~/.agents/skills` (which APM converges on anyway) is already
   our canonical dir. Revisit only if an APM package we want appears.
4. **Add a drift check** to `tests/test_skills.py`: assert every lock entry has a
   non-empty `commit` (except download/Notion sources), so future additions stay
   pinned.
5. Update `docs/skills.md` accordingly.

## Sources

- vercel-labs/skills README + docs/commands.md (v2 lock, commit pinning,
  `--frozen-lockfile`, global scope) @ 57217cf
- microsoft.github.io/apm targets matrix (no Pi/Amp target; skills converge to
  `.agents/skills`) and apm.lock.yaml format; our own `src/dot_apm` history
  (commit 7997e50, removed in adc13a1)
- Local inventory: `src/skills-lock.json` v1, 169 entries, 56 sources
