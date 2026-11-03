rex.action{
  name = "lazygit",
  title = "Open Lazygit",
  run = function(ctx)
    local process, err = rex.block.call("com.superlogical.terminal", "process", { block_id = ctx.block_id })
    if err then error(err, 0) end
    local cwd = process.foreground and process.foreground.cwd
    if not cwd then error("Cannot determine the focused terminal's working directory", 0) end

    local layer, layer_err = rex.session.new_layer{
      bounds = { 0.05, 0.05, 0.9, 0.9 },
      focus = true,
      layout = rex.layout.block{
        flavor = "com.superlogical.terminal.shell",
        label = "Lazygit",
        options = { cwd = cwd, command = { "lazygit" } },
      },
    }
    if layer_err then error(layer_err, 0) end
    return layer
  end,
}
