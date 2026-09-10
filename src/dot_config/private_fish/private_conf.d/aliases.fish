# Navigation
function ..
    cd ..
end
function ...
    cd ../..
end
function ....
    cd ../../..
end
function .....
    cd ../../../..
end

alias c clear
alias code vim
alias pbc pbcopy
alias pbp pbpaste
alias scratch 'nvim -c "setlocal buftype=nofile"'
alias vimdiff 'nvim -d'
alias wr wrangler

# zoxide
alias z zoxide

alias ls='eza --classify=auto --color --group-directories-first --sort=extension -A'
alias la='eza --classify=auto --color --group-directories-first --sort=extension -a -l --octal-permissions --no-permissions'

alias cat 'bat --paging=never'
alias grep 'rg --color=always'
alias find 'fd --color=always'
alias du dust
alias df duf
alias ps procs
alias top btm
alias bench hyperfine

# vim
alias v nvim
alias vi nvim
alias vim nvim

alias dotfiles 'nvim ~/.config/'
