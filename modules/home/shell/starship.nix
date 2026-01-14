# ╭──────────────────────────────────────────────────────────╮
# │ Starship Prompt                                          │
# ╰──────────────────────────────────────────────────────────╯

{ ... }:
{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      directory.truncation_length = 4;

      git_branch.symbol = " ";

      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
      };

      # Disable some modules for cleaner prompt
      aws.disabled = true;
      gcloud.disabled = true;
      azure.disabled = true;
    };
  };
}
