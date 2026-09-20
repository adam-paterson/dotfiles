local safely = require("mini.misc").safely
local gh = Config.gh

-- ─ Icons ───────────────────────────────────────────────────
-- This is outside of the UI plugin configuration so we can
-- use icons in plugin config.
safely("now", function()
    vim.pack.add({ gh 'nvim-mini/mini.icons' })
    require('mini.icons').setup()

    -- Mock 'nvim-tree/nvim-web-devicons' for plugins without 'mini.icons' support.
    safely("later", MiniIcons.mock_nvim_web_devicons)

    -- Add LSP kind icons.
    safely("later", MiniIcons.tweak_lsp_kind)
end)
