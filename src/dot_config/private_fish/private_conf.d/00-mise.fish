# conf.d runs alphabetically; mise must be on PATH before other tool hooks.
fish_add_path "$HOME/.local/bin"
if command -q mise
    mise activate fish | source
    mise hook-env --force -s fish | source
end
