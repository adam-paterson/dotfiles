status is-interactive; or return

# The PTY proxy hides foreground agents from Herdr and Rex.
if test "$HERDR_ENV" = 1; or test -n "$REX_SESSION"
    set -gx ATUIN_PTY_PROXY_FAILED 1
end

# Initialize before the first command so history capture and bindings stay intact.
function __dotfiles_atuin_init --on-event fish_prompt
    functions --erase __dotfiles_atuin_init
    if command -q atuin
        source (atuin init fish | psub)
        if test "$HERDR_ENV" != 1; and test -z "$REX_SESSION"
            source (atuin pty-proxy init fish | psub)
        end
    end
end
