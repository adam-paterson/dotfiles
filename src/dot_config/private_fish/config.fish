set fish_greeting

set -gx EDITOR 'nvim'

set -gx MANPAGER 'nvim +Man!'

# Restore mise's PATH after conf.d scripts, including Homebrew, modify it.
if command -q mise
    mise hook-env --force -s fish | source
end

if status is-interactive; and command -q atuin
  atuin pty-proxy init fish | source
end
