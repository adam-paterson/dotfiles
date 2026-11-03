local modes = {
  review = { title = "Plannotator: Review changes", label = "Plannotator review", command = { "plannotator", "review" } },
  annotate = { title = "Plannotator: Annotate files", label = "Plannotator annotate", command = { "plannotator", "annotate", "." } },
  pr = {
    title = "Plannotator: Review pull request",
    label = "Plannotator PR review",
    command = { "sh", "-c", 'printf "PR URL: "; IFS= read -r target; [ -n "$target" ] || exit 0; exec plannotator review "$target"' },
  },
  url = {
    title = "Plannotator: Annotate URL",
    label = "Plannotator annotate URL",
    command = { "sh", "-c", 'printf "URL: "; IFS= read -r target; [ -n "$target" ] || exit 0; exec plannotator annotate "$target"' },
  },
}

for name, mode in pairs(modes) do
  rex.action{
    name = "plannotator_" .. name,
    title = mode.title,
    run = function(ctx)
      local process, err = rex.block.call("com.superlogical.terminal", "process", { block_id = ctx.block_id })
      if err then error(err, 0) end
      local cwd = process.foreground and process.foreground.cwd
      if not cwd then error("Cannot determine the focused terminal's working directory", 0) end

      local result, layer_err = rex.session.new_layer{
        bounds = { 0.1, 0.1, 0.8, 0.8 },
        focus = true,
        layout = rex.layout.block{
          flavor = "com.superlogical.terminal.shell",
          label = mode.label,
          options = { cwd = cwd, command = mode.command, exit = { on_completion = false } },
        },
      }
      if layer_err then error(layer_err, 0) end
      return result
    end,
  }
end
