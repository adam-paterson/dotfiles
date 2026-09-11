if command -q direnv
    direnv hook fish | source
end

set -g direnv_fish_mode eval_on_arrow
