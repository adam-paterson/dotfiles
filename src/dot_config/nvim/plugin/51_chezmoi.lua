-- Keep edits in chezmoi's source, including files opened through their destination.
if vim.fn.executable("chezmoi") ~= 1 then return end
local group = vim.api.nvim_create_augroup("ConfigChezmoi", { clear = true })

local function path_for(command, path)
  local args = { "chezmoi", command }
  if path then vim.list_extend(args, { "--", path }) end
  local result = vim.system(args, { text = true }):wait(2000)
  if result.code ~= 0 then return nil end
  return vim.trim(result.stdout)
end

local source_dir = path_for("source-path")
if not source_dir then return end

local function watching(buf)
  return #vim.api.nvim_get_autocmds({ event = "BufWritePost", buffer = buf, group = "chezmoi" }) > 0
end

local function attach(buf, source)
  if vim.b[buf].chezmoi_source then return end
  vim.b[buf].chezmoi_source = source
  vim.api.nvim_create_augroup("chezmoi", { clear = false })
  local edit = require("chezmoi.commands.__edit")
  if require("chezmoi").config.edit.watch then edit.watch(buf, false) end

  local function map(key, callback, description)
    vim.keymap.set("n", "<leader>c" .. key, callback, { buffer = buf, desc = "Chezmoi: " .. description })
  end

  map("a", function()
    local auto_apply = watching(buf)
    vim.cmd.write()
    if not auto_apply then
      local result = vim.system({ "chezmoi", "apply", "--source-path", "--", source }, { text = true }):wait()
      vim.notify(result.code == 0 and "Applied chezmoi file" or result.stderr,
        result.code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR)
    end
  end, "Save and apply")

  map("w", function()
    if watching(buf) then
      vim.api.nvim_clear_autocmds({ event = "BufWritePost", buffer = buf, group = "chezmoi" })
      vim.notify("Chezmoi apply-on-save disabled for this buffer")
    else
      edit.watch(buf, false)
    end
  end, "Toggle apply-on-save")

  map("d", function()
    local result = vim.system({ "chezmoi", "diff", "--no-pager", "--source-path", "--", source }, { text = true }):wait()
    if result.code ~= 0 then
      vim.notify(result.stderr, vim.log.levels.ERROR)
      return
    end
    if result.stdout == "" then
      vim.notify("No saved chezmoi changes to apply")
      return
    end
    vim.cmd("botright new")
    local diff = vim.api.nvim_get_current_buf()
    vim.bo[diff].buftype = "nofile"
    vim.bo[diff].bufhidden = "wipe"
    vim.bo[diff].swapfile = false
    vim.api.nvim_buf_set_lines(diff, 0, -1, false, vim.split(result.stdout, "\n"))
    vim.bo[diff].filetype = "diff"
    vim.bo[diff].modifiable = false
  end, "Diff saved source against destination")
end

vim.api.nvim_create_autocmd("BufEnter", {
  group = group,
  callback = function(event)
    vim.schedule(function()
      local buf = event.buf
      if not vim.api.nvim_buf_is_valid(buf) or vim.api.nvim_get_current_buf() ~= buf
        or vim.bo[buf].buftype ~= "" or vim.bo[buf].modified or vim.wo.diff
        or vim.b[buf].chezmoi_source then return end
      local path = vim.api.nvim_buf_get_name(buf)
      if path == "" then return end
      local source
      if vim.startswith(path, source_dir .. "/") then
        local target = path_for("target-path", path)
        source = target and path_for("source-path", target)
        if source ~= path then return end
      else
        source = path_for("source-path", path)
      end
      if not source or vim.fn.filereadable(source) ~= 1 then return end
      if source ~= path then
        local ok, err = pcall(vim.cmd.edit, { args = { source } })
        if not ok then
          vim.notify("Could not open chezmoi source: " .. tostring(err), vim.log.levels.ERROR)
          return
        end
        buf = vim.api.nvim_get_current_buf()
        vim.notify("Chezmoi: opened source instead of " .. path)
      end
      attach(buf, source)
    end)
  end,
})
