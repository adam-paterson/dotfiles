# Astro and TypeScript editing in Neovim

Astro completion uses `astro-ls` installed through mise. Its TypeScript SDK is
installed separately under `~/.config/nvim/tools`: TypeScript 7 is a native
compiler and does not ship the JavaScript SDK required by the Astro server.
This editor-only SDK does not change a project's compiler or dependencies.

JavaScript and TypeScript use the same editor-owned SDK as a fallback through
`typescript-language-server`'s `tsserver.fallbackPath` option. A usable workspace
SDK takes precedence, including one hoisted to a monorepo's parent directory.
Projects without a JS SDK, including native-only TypeScript 7 projects, use the
editor SDK. Diagnostics in that case reflect the editor SDK's TypeScript version,
not the project's native compiler. Astro continues to use the editor SDK directly.

Manual formatting is **Space l f** in normal mode (or with a selection):

- Astro: editor-owned Prettier with `prettier-plugin-astro`.
- JavaScript, TypeScript, TSX and Markdown: oxfmt.
- Oxlint is a linter, not the formatter.

Project-local Oxfmt takes precedence over the executable on PATH. Manual
formatting is asynchronous and allows up to three seconds for the formatter.

Chezmoi installs the locked editor dependencies when their manifest or lockfile
changes. To repair a missing installation without applying other dotfiles:

```sh
cd ~/.config/nvim/tools
npm ci --ignore-scripts --no-audit --no-fund
```

Restart Neovim after applying config changes. Import-path suggestions are
provided by Astro through the configured completion UI; **Ctrl-x Ctrl-o**
requests completion manually.

## Checks

From the chezmoi repository, with the config applied and tools installed:

```sh
nvim --headless -u NONE -l tests/test_nvim_typescript.lua
nvim --headless -u NONE -l tests/test_nvim_formatting.lua
nvim --headless /absolute/project/src/pages/index.astro \
  '+lua dofile("tests/test_nvim_astro.lua")'
```

The TypeScript check uses temporary projects and the actual language server.
It verifies SDK selection, type-error diagnostics, and string-method completions
with no SDK, a native-only SDK layout, a project-local JS SDK, and a hoisted JS SDK.

The integration check edits only the in-memory buffer and exits without saving.
It verifies that Astro initializes, suggests the actual containing directory in
an import (including the automatic popup while typing), and that the manual
format mapping reformats frontmatter and markup.
Point it at the affected worktree to exercise that project's SDK layout.

The original failure was reproduced with a workspace-local TypeScript 7 SDK:
Astro initialization failed because `typescript.js`/`tsserverlibrary.js` were
absent. The project also had no resolvable `prettier-plugin-astro`, leaving Astro
formatting unavailable. Both dependencies now belong to the editor tool bundle.
