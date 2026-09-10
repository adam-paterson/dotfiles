# Fish completions for Plannotator.
complete -c plannotator -f

# Global options and commands
complete -c plannotator -n __fish_use_subcommand -s v -l version -d 'Show version'
complete -c plannotator -n __fish_use_subcommand -l help -d 'Show help'
complete -c plannotator -n __fish_use_subcommand -l browser -x -d 'Browser to open'

complete -c plannotator -n __fish_use_subcommand -a review -d 'Review local changes or a pull request'
complete -c plannotator -n __fish_use_subcommand -a annotate -d 'Annotate a file, URL, or folder'
complete -c plannotator -n __fish_use_subcommand -a annotate-last -d 'Annotate the last assistant message'
complete -c plannotator -n __fish_use_subcommand -a copilot-last -d 'Annotate the last Copilot CLI message'
complete -c plannotator -n __fish_use_subcommand -a setup-goal -d 'Open a goal-setup workflow'
complete -c plannotator -n __fish_use_subcommand -a last -d 'Alias for annotate-last'
complete -c plannotator -n __fish_use_subcommand -a archive -d 'Browse saved plan decisions'
complete -c plannotator -n __fish_use_subcommand -a sessions -d 'List active sessions'
complete -c plannotator -n __fish_use_subcommand -a improve-context -d 'Run the plan-mode hook integration'

# review
complete -c plannotator -n '__fish_seen_subcommand_from review' -l git -d 'Force Git as the VCS'
complete -c plannotator -n '__fish_seen_subcommand_from review' -l gitbutler -d 'Force GitButler as the VCS'
complete -c plannotator -n '__fish_seen_subcommand_from review' -l local -d 'Prepare a local PR checkout'
complete -c plannotator -n '__fish_seen_subcommand_from review' -l no-local -d 'Review a PR diff without a local checkout'

# annotate
complete -c plannotator -n '__fish_seen_subcommand_from annotate' -F
complete -c plannotator -n '__fish_seen_subcommand_from annotate' -l markdown -d 'Convert HTML input to Markdown'
complete -c plannotator -n '__fish_seen_subcommand_from annotate' -l no-jina -d 'Fetch URLs without Jina Reader'
complete -c plannotator -n '__fish_seen_subcommand_from annotate' -l gate -d 'Add an Approve button'
complete -c plannotator -n '__fish_seen_subcommand_from annotate' -l json -d 'Emit structured decision JSON'
complete -c plannotator -n '__fish_seen_subcommand_from annotate' -l hook -d 'Emit hook-native JSON'
complete -c plannotator -n '__fish_seen_subcommand_from annotate' -l require-approval -d 'Fail unless the reviewer approves'
complete -c plannotator -n '__fish_seen_subcommand_from annotate' -l result-file -r -F -d 'Write result JSON atomically'

# annotate-last and last
complete -c plannotator -n '__fish_seen_subcommand_from annotate-last last' -l stdin -d 'Read message content from stdin'
complete -c plannotator -n '__fish_seen_subcommand_from annotate-last last' -l gate -d 'Add an Approve button'
complete -c plannotator -n '__fish_seen_subcommand_from annotate-last last' -l json -d 'Emit structured decision JSON'
complete -c plannotator -n '__fish_seen_subcommand_from annotate-last last' -l hook -d 'Emit hook-native JSON'

# copilot-last
complete -c plannotator -n '__fish_seen_subcommand_from copilot-last' -l gate -d 'Add an Approve button'
complete -c plannotator -n '__fish_seen_subcommand_from copilot-last' -l json -d 'Emit structured decision JSON'
complete -c plannotator -n '__fish_seen_subcommand_from copilot-last' -l hook -d 'Emit hook-native JSON'

# setup-goal
complete -c plannotator -n '__fish_seen_subcommand_from setup-goal; and not __fish_seen_subcommand_from interview facts' -a 'interview facts'
complete -c plannotator -n '__fish_seen_subcommand_from setup-goal; and __fish_seen_subcommand_from interview facts' -F
complete -c plannotator -n '__fish_seen_subcommand_from setup-goal' -l json -d 'Emit compact JSON'

# sessions
complete -c plannotator -n '__fish_seen_subcommand_from sessions' -l open -a 1 -d 'Reopen a session by number'
complete -c plannotator -n '__fish_seen_subcommand_from sessions' -l clean -d 'Remove stale session entries'
