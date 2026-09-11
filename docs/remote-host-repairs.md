# Remote host repairs — 2026-09-11

## Ansible change to carry back to the local provisioning repository

This host is Ubuntu 26.04. The compiler (`cc`), make, and unzip were missing.
Installed `build-essential` and `unzip` on the host. Add this task to the Ubuntu
base/development role, before running chezmoi or starting Neovim:

```yaml
- name: Install native build tools and Neovim archive support
  become: true
  ansible.builtin.apt:
    name:
      - build-essential
      - unzip
    state: present
    update_cache: true
    cache_valid_time: 3600
```

`build-essential` supplies GCC/G++, make and development headers. Tree-sitter
was already installed through mise; its parser builds failed because `cc` was absent.
All 16 configured parser languages were installed and Tree-sitter and nvim.zip
health checks passed. No Neovim configuration changes were needed.

Remaining health findings are separate: roslyn-language-server is absent;
clipboard support is unavailable in this headless check; no URL opener is
installed; Tailwind's upstream filetype list includes unregistered filetypes.
Graphics/terminfo findings from a headless terminal do not establish an SSH
terminal problem. For remote clipboard use, test Neovim OSC52 in the actual
SSH terminal; desktop clipboard packages alone will not provide a local display.

## Chezmoi changes

Both live files and their chezmoi sources were updated:

- `src/dot_config/mise/conf.d/ai.toml`: replace
  `npm:@mariozechner/pi-coding-agent` with `npm:@earendil-works/pi-coding-agent`.
  The old scope stopped at 0.73.1; current extensions import the new scope.
  Installed and verified Pi 0.85.1.
- Same file: replace the ineffective `trust_policy_excludes = ["1.4.1"]`
  with `trust_policy_excludes = ["@pierre/theme@2.0.0"]` for Plannotator only.
- `src/dot_pi/private_agent/settings.json`: replace Plannotator's npm source
  with `~/.local/share/mise/installs/npm-plannotator-pi-extension/latest/node_modules/@plannotator/pi-extension`.
  Mise installs npm tools in isolated directories, whereas Pi's npm package
  lookup uses its own package directory or the legacy global npm directory.
  This local source uses mise's existing `latest` symlink, avoids a second npm
  installation, and retains mise's reviewed dependency trust policy.
  Assumes the default mise data directory, as used on this host.

The existing `run_after_90-install-mise-tools.sh` installs these tools on
chezmoi apply. Existing staged and unstaged changes were preserved; no commit
or push was made. Carry these changes back to the local source repository.

## Exact-version trust review

Reviewed @pierre/theme 2.0.0 directly from registry.npmjs.org, compared with
0.0.20 and 1.1.0. Version 0.0.20 has provenance; 2.0.0 does not. Thus this is
upstream publication metadata, not evidence of a mirror stripping provenance.

- Published 2026-07-24T22:01:50Z by npm user `amadeusdemarzi`.
- Source version-bump commit: `644bb307d9af7bd403f1ef02e8165e511dc82dbc`,
  authored by Amadeus Demarzi at 2026-07-24T22:00:26Z with matching email.
- Repository moved from pierrecomputer/theme into pierrecomputer/pierre.
  No theme release tag was returned; the version-bump commit was inspected.
- Tarball SHA-512 matched the registry integrity field:
  `sha512-yNDd9GYLQl1mEUJR8AneJ5e4ohLIHQd/wZLWr4fagt78vS2RwwZNW530vVgHqXFAyFVcFlRmGUD5ramXH46OXw==`.
- Tarball contains theme JSON, JSON-only module exports, declarations,
  documentation/license files and an icon. Every JavaScript module was
  checked to contain only JSON data exports. No runtime dependencies or
  lifecycle scripts. Source/published manifests differ only in resolved
  development dependency catalog values and removal of the publishing script.

This supports a narrowly scoped exception; it does not restore provenance or
constitute a reproducible build audit. Global trust enforcement remains enabled;
`npm.shell_out` was not enabled. Re-review if another version is flagged.

Sources:
- https://pi.dev/news/2026/5/7/pi-has-a-new-home
- https://registry.npmjs.org/@pierre%2ftheme/2.0.0
- https://registry.npmjs.org/@pierre%2ftheme/0.0.20
- https://github.com/pierrecomputer/pierre/commit/644bb307d9af7bd403f1ef02e8165e511dc82dbc

Suggested upstream report (not sent): @pierre/theme 2.0.0 lacks the provenance
present on 0.0.20, so aube's no-downgrade policy blocks dependent installs.
Please restore provenance publishing for future releases. This belongs with
the pierrecomputer/pierre maintainers. No external message was sent.

Additional provisioning observation: `.pi/agent/AGENTS.md` is a broken symlink
pointing to `/Users/adampaterson/.agents/AGENTS.md`. Its chezmoi source contains
that Mac-specific absolute path. Change it to a chezmoi template containing
`{{ .chezmoi.homeDir }}/.agents/AGENTS.md` if this link should work on all hosts.

## Final verification

`mise install` succeeded: all 102 configured tools installed. `mise which pi`
selects the Earendil package; `pi --version` reports 0.85.1. Pi resource-loader
validation loaded all nine configured packages plus the local moshi-hooks
extension (10 total), with zero extension errors. No model request was made.
