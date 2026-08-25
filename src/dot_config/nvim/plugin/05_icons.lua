now, later, gh = Config.now, Config.later, Config.gh

-- ─ Icons ───────────────────────────────────────────────────
-- This is outside of the UI plugin configuration so we can
-- use icons in plugin config.
now(function()
    vim.pack.add({ gh 'nvim-mini/mini.icons' })
    require('mini.icons').setup()

    -- Mock 'nvim-tree/nvim-web-devicons' for plugins without 'mini.icons' support.
    later(MiniIcons.mock_nvim_web_devicons)

    -- Add LSP kind icons.
    later(MiniIcons.tweak_lsp_kind)
end)
