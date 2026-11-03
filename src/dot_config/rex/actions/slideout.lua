local edges = {
  right = { label = "Slide-out right", bounds = { 0.55, 0, 0.45, 1 } },
  bottom = { label = "Slide-out bottom", bounds = { 0, 0.6, 1, 0.4 } },
}

rex.action{
  name = "slideout",
  title = "Toggle Slide-out Terminal",
  args = { edge = "string" },
  run = function(ctx, args)
    local edge = edges[args.edge]
    if not edge then error("Slide-out edge must be right or bottom", 0) end

    local view, err = rex.session.view{}
    if err then error(err, 0) end
    for _, window in ipairs(view.windows or {}) do
      if window.window_id == view.active_window_id then
        for _, layer in ipairs(window.layers or {}) do
          if layer.kind == "floating" then
            for _, block in ipairs(layer.blocks or {}) do
              if block.label == edge.label then
                local state = layer.state == "minimized" and "normal" or "minimized"
                local result, state_err = rex.session.set_layer_state{
                  layer_id = layer.layer_id,
                  state = state,
                  focus = state == "normal",
                }
                if state_err then error(state_err, 0) end
                return result
              end
            end
          end
        end
      end
    end

    local process, process_err = rex.block.call("com.superlogical.terminal", "process", { block_id = ctx.block_id })
    if process_err then error(process_err, 0) end
    local cwd = process.foreground and process.foreground.cwd
    if not cwd then error("Cannot determine the focused terminal's working directory", 0) end

    local result, layer_err = rex.session.new_layer{
      bounds = edge.bounds,
      focus = true,
      layout = rex.layout.block{
        flavor = "com.superlogical.terminal.shell",
        label = edge.label,
        options = { cwd = cwd },
      },
    }
    if layer_err then error(layer_err, 0) end
    return result
  end,
}
