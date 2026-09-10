set fish_greeting

set -gx EDITOR 'nvim'

set -gx MANPAGER 'nvim +Man!'

# Restore mise's PATH after conf.d scripts, including Homebrew, modify it.
mise hook-env --force -s fish | source

if status is-interactive
  atuin pty-proxy init fish | source
end
