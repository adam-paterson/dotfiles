# ╭──────────────────────────────────────────────────────────╮
# │ 1Password Secret References                              │
# ╰──────────────────────────────────────────────────────────╯
#
# This file documents 1Password secret paths used in this configuration.
# NO ACTUAL SECRETS ARE STORED HERE - only the paths/references.
#
# Usage:
# - CI/CD: Secrets are loaded via 1password/load-secrets-action
# - Local: Use `op run -- <command>` to inject secrets

{
  # ── VPS Deployment ────────────────────────────────────────────────────────
  vps = {
    host = "op://nix-config/vps/host";
    user = "op://nix-config/vps/user";
    sshKey = "op://nix-config/vps/ssh-key";
    knownHosts = "op://nix-config/vps/known-hosts";
  };

  # ── Git Signing ───────────────────────────────────────────────────────────
  git = {
    signingKey = "op://Personal/SSH Key/public key";
  };

  # ── API Keys ──────────────────────────────────────────────────────────────
  # Add API key references here as needed
  # api = {
  #   anthropic = "op://Personal/Anthropic/credential";
  #   openai = "op://Personal/OpenAI/api key";
  # };
}
