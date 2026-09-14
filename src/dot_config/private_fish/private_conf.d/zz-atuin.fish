set -l atuin_bin (env "$HOME/.local/bin/mise" which atuin 2>/dev/null)
if test -x "$atuin_bin"
    fish_add_path --move --prepend (path dirname "$atuin_bin")
end
# The PTY proxy hides foreground agents from Herdr's process detection.
if test "$HERDR_ENV" = 1
    set -gx ATUIN_PTY_PROXY_FAILED 1
end
if command -q atuin
   source (atuin init fish | psub)
end
