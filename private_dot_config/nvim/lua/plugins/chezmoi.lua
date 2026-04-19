return {
  -- chezmoi.nvim is a Neovim plugin that provides an interface to the chezmoi dotfile manager.
  -- It allows you to edit and apply your dotfiles directly from Neovim, with support for notifications and integration with Telescope.
  {
    "xvzc/chezmoi.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("chezmoi").setup({
        {
          edit = {
            watch = false,
            force = false,
            ignore_patterns = {
              "run_onchange_.*",
              "run_once_.*",
              "%.chezmoiignore",
              "%.chezmoitemplate",
            },
          },
          events = {
            on_open = {
              notification = {
                enable = true,
                msg = "Opened a chezmoi-managed file",
                opts = {},
              },
            },
            on_watch = {
              notification = {
                enable = true,
                msg = "This file will be automatically applied",
                opts = {},
              },
            },
            on_apply = {
              notification = {
                enable = true,
                msg = "Successfully applied",
                opts = {},
              },
            },
          },
          telescope = {
            select = { "<CR>" },
          },
        },
      })
    end,
  },
  {
    "alker0/chezmoi.vim",
    lazy = false,
    init = function()
      -- This option is required.
      vim.g["chezmoi#use_tmp_buffer"] = true
    end,
  },
}
