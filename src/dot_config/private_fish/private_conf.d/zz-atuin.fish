set -l atuin_bin (env "$HOME/.local/bin/mise" which atuin 2>/dev/null)
if test -x "$atuin_bin"
    fish_add_path --move --prepend (path dirname "$atuin_bin")
end
atuin init fish | source
