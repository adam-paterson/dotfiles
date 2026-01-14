# ╭──────────────────────────────────────────────────────────╮
# │ Tmux Module                                              │
# ╰──────────────────────────────────────────────────────────╯
#
# Tmux terminal multiplexer configuration.

{
  config,
  lib,
  ...
}:

let
  cfg = config.tools.tmux;
in
{
  options.tools.tmux = {
    enable = lib.mkEnableOption "Tmux configuration";
  };

  config = lib.mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      mouse = true;
      prefix = "C-a";
      terminal = "screen-256color";
      historyLimit = 50000;
      escapeTime = 0;
      baseIndex = 1;

      extraConfig = ''
        # Enable true color
        set -ga terminal-overrides ",*256col*:Tc"

        # Split panes using | and -
        bind | split-window -h -c "#{pane_current_path}"
        bind - split-window -v -c "#{pane_current_path}"
        unbind '"'
        unbind %

        # Vim-style pane navigation
        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R

        # Reload config
        bind r source-file ~/.config/tmux/tmux.conf \; display "Config reloaded!"

        # Status bar
        set -g status-position top
        set -g status-style 'bg=default fg=white'
        set -g status-left '#[fg=blue,bold]#S '
        set -g status-right '#[fg=white]%Y-%m-%d %H:%M'
      '';
    };
  };
}
