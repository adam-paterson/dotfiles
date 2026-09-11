set -Ux CARAPACE_BRIDGES 'zsh,fish,bash,inshellisense'
if command -q carapace
    carapace _carapace | source
end
