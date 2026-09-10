if test -r "$HOME/.config/1Password/environments/global.env"
    set -l op_env_attempt
    set -l op_env_loaded false
    for op_env_attempt in 1 2 3
        "$HOME/.local/share/mise/shims/direnv" dotenv fish "$HOME/.config/1Password/environments/global.env" 2>/dev/null | source
        if test $pipestatus[1] -eq 0
            set op_env_loaded true
            break
        end
        sleep 0.1
    end
    if not $op_env_loaded
        echo "1Password environment could not be loaded." >&2
    end
end
