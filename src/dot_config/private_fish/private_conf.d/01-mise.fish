# Run after PATH setup, before tool hooks. Activation refreshes the environment.
if command -q mise
    mise activate fish | source
end
