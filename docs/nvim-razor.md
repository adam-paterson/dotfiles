# C# and Razor in Neovim

`plugin/41_dotnet.lua` registers `seblyng/roslyn.nvim` for C# and Razor. It replaces the plain `roslyn_ls` configuration; `rzls.nvim` is deprecated and is not installed.

## Activation

- Roslyn starts for `cs` and `razor` buffers only when an ancestor contains a `.csproj`, `.sln` or `.slnx` file. Source-generated documents reuse the active Roslyn client.
- Both `.razor` and `.cshtml` already map to `razor` in the installed Neovim.
- The HTML server starts only for Razor's `__virtual.html` buffers inside those projects. It does not attach to ordinary HTML files.
- Plugin registration happens at startup, but opening unrelated files does not start these servers. Roslyn uses stdio, not a persistent daemon.

## Installation

Seraph currently has no .NET runtime. Its profile excludes this plugin and the
Roslyn install hook. The Mac keeps the existing C# and Razor setup.

Chezmoi's `run_onchange_after_92-install-roslyn.sh.tmpl` installs Roslyn `5.12.0-1.26453.19` from Microsoft's public Azure feed into `~/.config/nvim/tools/roslyn`. This avoids changing the global/mise Roslyn version. A compatible .NET SDK/runtime must be installed and `dotnet` must be on PATH. The HTML executable comes from the existing mise `npm:vscode-langservers-extracted` entry.

The plugin is pinned to `bf1bd4e70bc7068d1b4aebf4ce03cc19a86615be`. Update the plugin and server pins together after checking upstream requirements.

Restart Neovim after applying. Open a restored .NET project and use `:checkhealth roslyn` or `:Roslyn target` for solution troubleshooting. Existing LSP mappings and Conform's LSP formatting fallback remain in place. No custom Razor Tree-sitter parser is added.

## Verification

Create a disposable fixture outside the dotfiles repository:

```sh
dotnet new webapp --output /tmp/razor-fixture
a=tests/test_nvim_razor.lua
nvim --headless /tmp/razor-fixture/Pages/Index.cshtml \
  "+lua dofile('$a')"
```

The integration test checks real Razor model hover, on-demand HTML attachment, absence of a duplicate `roslyn_ls`, and exclusion of standalone C#/Razor/HTML files even after solution selection. It passed on this machine with Neovim `0.13.0-dev-1915`. Completion, formatting and diagnostics in the user's actual project still need a project-specific smoke test.
