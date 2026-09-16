# Remote host repairs — 2026-09-11

## Ansible changes to apply together

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

### Provision the machine SSH key under its standard name

The existing key is Ed25519 and GitHub accepts it as `adam-paterson`.
Update the existing Ansible private-key provisioning task to write the same
secret to `/home/adam/.ssh/id_ed25519` instead of
`/home/adam/.ssh/chezmoi_deploy_key`. Do not generate a replacement key.
Use the role's existing username/home variables where available.

- Ensure `/home/adam/.ssh` is owned by `adam:adam` with mode `0700`.
- Set the private-key destination to `id_ed25519`, owner/group `adam`,
  mode `0600`, and `no_log: true` on the task handling secret content.
  Disable task diffs with `diff: false`.
- If provisioning the public key, use `id_ed25519.pub` with mode `0644`.
- Update all Ansible references to `chezmoi_deploy_key`, including clone
  tasks' `key_file`, `GIT_SSH_COMMAND`, templates, and bootstrap scripts.
  An explicit key path in bootstrap tasks must now use `id_ed25519`.
- Keep the key secret in the existing secret store, outside chezmoi/Git.

SSH discovers `~/.ssh/id_ed25519` automatically. No global `IdentityFile`
entry or repository `core.sshCommand` override is needed for this setup.
This changes the filename, not which public key is registered with GitHub.

Migration on this already-provisioned host, in order:

1. Check for an existing `id_ed25519` before provisioning; stop if it is a
   different key rather than overwriting it. Provision the existing secret
   at the new path and verify its public-key fingerprint matches the old key.
2. Remove the temporary `Host *` / `IdentityFile ~/.ssh/chezmoi_deploy_key`
   stanza from `~/.ssh/config`, preserving any unrelated SSH configuration.
   That stanza was added manually during diagnosis, not by blockinfile;
   removing an Ansible managed block alone will not remove it.
3. Remove any dotfiles-repository `core.sshCommand` override if still present
   (already removed on this host).
4. Verify `ssh -T -o BatchMode=yes git@github.com` reports successful account
   authentication (GitHub normally returns exit status 1 for this successful
   shell-access test), then run `git push --dry-run origin main` from the
   dotfiles checkout. This tests access without publishing changes.
5. Once verification succeeds and all provisioning references are updated,
   remove the obsolete `chezmoi_deploy_key` file.

Current host state: the old key filename and temporary SSH config still work;
this standard-filename migration is documented here but has not been applied.
The earlier advice to retain the custom filename and provision a global SSH
config stanza is superseded by this section.

### Preserve service-account authentication

Ansible already provisions `/home/adam/.config/op/service-account-token`.
Keep that directory at `0700` and the token file at `0600`, owned by `adam`.
The file should contain the token followed by a newline. Keep secret-writing
tasks under `no_log: true` and `diff: false`; do not put the value into Git.

The Fish change in this dotfiles repository exports `OP_SERVICE_ACCOUNT_TOKEN`
from that file when no token is already set. Apply the chezmoi changes after
Ansible provisions the file; new Fish sessions can then use plain `op`.
For Ansible tasks invoking `op`, explicitly supply the environment or retain
the existing `op-service` wrapper: non-Fish tasks do not inherit Fish startup
configuration. The wrapper is also still referenced by mise authentication.

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
chezmoi apply. Also carry back the Fish service-account environment change in
`src/dot_config/private_fish/private_conf.d/1password.fish.tmpl`. See
[1Password Environments](1password-environments.md) for the beta CLI and required
Environment access. These dotfiles
changes accompany the Ansible tasks above; the Ansible repository is on the
local machine and has not been edited from this host.

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
