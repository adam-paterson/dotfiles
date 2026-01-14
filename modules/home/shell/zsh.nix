# ╭──────────────────────────────────────────────────────────╮
# │ Zsh Configuration                                        │
# ╰──────────────────────────────────────────────────────────╯

{ config, ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    dotDir = "${config.xdg.configHome}/zsh";

    history = {
      size = 50000;
      save = 50000;
      ignoreDups = true;
      ignoreAllDups = true;
      share = true;
    };

    shellAliases = {
      # Git
      g = "git";
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git pull";
      gd = "git diff";
      gco = "git checkout";
      glog = "git log --oneline --graph --decorate";

      # Modern replacements
      ls = "eza";
      l = "eza -la";
      ll = "eza -la";
      la = "eza -a";
      lt = "eza -T --level=2";
      cat = "bat --paging=never";
      tail = "tspin";

      # Editors
      v = "nvim";
      vim = "nvim";

      # Navigation
      ".." = "cd ..";
      "..." = "cd ../..";
    };

    initContent = ''
      # Better directory navigation
      setopt AUTO_CD
      setopt AUTO_PUSHD
      setopt PUSHD_IGNORE_DUPS

      # FZF integration
      if command -v fzf >/dev/null 2>&1; then
        eval "$(fzf --zsh)"
      fi

      # Direnv integration
      if command -v direnv >/dev/null 2>&1; then
        eval "$(direnv hook zsh)"
      fi
    '';
  };
}
