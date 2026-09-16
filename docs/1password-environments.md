# Machine environments from 1Password

Chezmoi selects one 1Password Environment by hostname. Matching is case-insensitive
and ignores the domain suffix.

Host records live in [`src/.chezmoidata/onepassword.yaml`](../src/.chezmoidata/onepassword.yaml).
Each record contains an `environment` ID and an `auth` method: `desktop` or
`service-account`. The Fish template selects a record and branches on `auth`,
never on a particular hostname.

To add a machine, add a record under `onepassword.hosts` using its lowercase short
hostname. Replace the placeholder with its 26-character Environment ID:

```yaml
    workstation:
      environment: <environment-id>
      auth: desktop
```

No template change is needed for either supported authentication method. Chezmoi
loads this static data automatically. Unknown hosts, invalid IDs and unsupported
authentication methods stop template rendering instead of choosing a fallback.

## Setup

Mise pins `op` to `2.39.0-beta.02` in
`src/dot_config/mise/conf.d/security.toml`. The stable CLI lacks Environment support.
The existing chezmoi tool-install hook installs this pin on a full apply.
For a targeted deployment:

```sh
chezmoi apply --include files ~/.config/mise/conf.d/security.toml ~/.config/fish/conf.d/1password.fish
mise install op
```

Open a new Fish session after setup.

### MacBook

In the 1Password desktop app, enable **Settings > Developer > Integrate with
1Password CLI**. The account must have access to the MacBook Environment. If you
have multiple accounts, select the correct one with `op signin` first, or configure
`OP_ACCOUNT` outside the Environment. Authentication is required before it can load.

The loader excludes inherited service-account and Connect credentials from its
Mac CLI invocation. It no longer reads `~/.config/1Password/environments/global.env`.
The existing desktop mount is left untouched; disable it in the app only after
checking that no other applications use it.

### Seraph

Ansible must provision `~/.config/op/service-account-token`, owned by the login
user with mode `0600` in a private directory. The token must grant read access to
the Seraph Environment. A vault-only service account is not sufficient.

1Password service-account access is immutable. If the existing account lacks
Environment access, create a replacement with the required Environment and vault
access, then update the provisioned token. Do not put the token in chezmoi or Git.

## Loading and scope

Interactive Fish startup calls `op run --environment ID` and captures the child
environment as NUL-separated data in memory. Changed variables become exported
Fish variables; unchanged exports keep their existing Fish array representation.
Quotes, empty strings and multiline values remain literal. Nothing is evaluated
as shell code or written to a plaintext environment file.

The loader discards failed command output and rejects invalid or Fish-reserved
variable names before import. It refuses to fetch secrets while `fish_trace` is
enabled and reports generic errors without printing secret values. It closes stdin so hidden terminal prompts cannot consume input;
desktop approval and network requests can still delay startup. Diagnose login
problems with `op signin` or `op whoami`, not by printing the environment.

Non-interactive shells do not fetch environments. Seraph still exports its
provisioned service-account token for automation. For a service, scheduled job or
script, supply that token securely and use:

```sh
op run --environment wqadrv3ix5cxwrv642dxae6puy -- your-command
```

Each new interactive shell fetches the current Environment. Existing shells do
not automatically refresh or remove previously exported values. Every child of
an interactive shell inherits its secrets, including editors and build tools.
Only trusted users should have permission to edit these Environments.

## Verification

`python3 tests/test_1password_environment.py` loads the actual chezmoi data file
and tests both configured hosts plus data-only additions for both authentication
methods. It also tests invalid host records, quoting/newlines/empty values, preserved arrays, failed
and malformed responses, reserved names, tracing, and non-interactive behaviour
with a fake `op` executable.
It never reads real secrets. Actual account access must be verified on each machine.

Sources, checked for CLI `2.39.0-beta.02`:

- [Beta release notes](https://releases.1password.com/developers/cli-beta/)
- [Load environment variables](https://www.1password.dev/cli/secrets-environment-variables)
- [Desktop app integration](https://www.1password.dev/cli/app-integration)
- [Service accounts and immutable Environment access](https://www.1password.dev/service-accounts/get-started)
