#!/usr/bin/env fish
# Run the skills CLI for the global skills inventory. The CLI reads the lock
# from the cwd, so commands run from $HOME where the lock is symlinked in;
# skills themselves live in ~/.agents/skills.
# `skill sync` runs the chezmoi-managed reconciler (install + prune);
# every other command passes straight through and never deletes.
function skill --description "Manage global agent skills"
    if test (count $argv) -eq 0
        echo "usage: skill <add|update|remove|install|check|list|find|sync|…>" >&2
        return 2
    end

    if test "$argv[1]" = sync
        bash $HOME/.local/bin/skills-sync $argv[2..]
        return $status
    end

    pushd $HOME
    npx --yes skills@1.9.0 $argv
    set -l code $status
    popd
    return $code
end
