set -l nvim_bin (env "$HOME/.local/bin/mise" which nvim 2>/dev/null)
if test -x "$nvim_bin"
    fish_add_path --path --move --prepend (path dirname "$nvim_bin")
end
