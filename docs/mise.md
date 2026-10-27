# Mise tool ownership

`src/dot_config/mise/config.toml` contains settings and environment configuration.
Every active tool is declared once under `conf.d`, with its purpose beside the
declaration. These files are plain TOML, not chezmoi templates.

| File | Owns |
| --- | --- |
| `ai.toml` | Coding agents, code/document search, and review integrations |
| `cli.toml` | Shell, terminal sessions, files, structured data, and system utilities |
| `development.toml` | Git, diffs, project automation, CI, HTTP testing, and release tools |
| `editors.toml` | Terminal editors |
| `infrastructure.toml` | Cloud, SSH, Kubernetes, and Terraform tools |
| `languages.toml` | Language servers, compilers, parsers, formatters, and linters |
| `media.toml` | Document, image, and diagram conversion/rendering |
| `runtimes.toml` | Language runtimes, toolchains, and package managers |
| `security.toml` | 1Password and file encryption |

The existing `entertainment.toml` contains only a commented-out Spotatui selection.
It remains disabled and is not part of the active tool inventory. This does not
uninstall an existing copy.

## Headless does not mean noninteractive

The audited inventory has 113 active tools. None requires a graphical desktop
for its core operation. The same declarations apply to GUI and headless hosts.
An interactive terminal, credentials, a compiler, or a headless browser is a
different prerequisite from a local display.

- Plannotator TUI and Gentle Shell run in terminals. Plannotator's Pi extension
  uses browser review, with remote mode and port forwarding available.
- Mermaid CLI requires Chromium/Puppeteer and its system libraries, but launches
  a headless browser. ImageMagick, Ghostscript, Tectonic, and Img2art support
  command-line rendering/conversion.
- QMD's semantic search downloads local models and can run on CPU. GPU support
  is optional. CodeGraph does not require a local LLM service.
- Todoist can authenticate with `TODOIST_API_TOKEN`; browser login is optional.
- Act needs a container engine; Sesh needs Tmux and Zoxide; the selected Unix
  Cloc artifact needs Perl. Tree-sitter parser builds need a C compiler.

No direct dotfile reference was found for some manually invoked utilities.
That does not establish that they are unused. Overlapping tools remain when
they have distinct contracts: Difftastic renders file comparisons, Delta renders
patches, and Treefmt orchestrates individual formatters. Fzf is also used by
Zoxide's interactive mode, even though Television provides another fuzzy finder.

## Versions and installation ownership

- OpenCode uses explicit `aqua:anomalyco/opencode` on both hosts. The installed
  mise registries disagree about the shorthand's preferred backend, so using
  `opencode` alone would not select the same source everywhere.
- Copilot's language server uses the existing workstation pin `1.561.0` on both
  profiles. The former `1.558.0` server pin had no documented compatibility reason.
  This is a version-policy change, not a claim that both versions behave identically.
- Plannotator TUI keeps `latest`, the effective value before cleanup. Its duplicate
  `0.9.4` entry in the main file was overridden by `conf.d/ai.toml`.
- Other version pins and tool options remain unchanged, including Cloc's platform
  assets, Azure's postinstall command, and Plannotator's narrow trust exception.
- Mise owns the Plannotator Pi extension installation. Pi references its existing
  `latest/node_modules/@plannotator/pi-extension` directory rather than requesting
  a second npm installation. This uses the default mise data directory already
  used by both machines. Agent model settings are unchanged by this cleanup.

`chezmoi apply` runs the existing `mise install` hook. A config-only review can
exclude scripts; it does not establish that every package installs or runs on
the target system. Do not use `mise upgrade` or `mise prune` as audit commands.
Some mise versions process deferred removals even on ordinary inspection commands;
use disposable HOME, data, cache, and state directories for parser checks.

## Verification

Run `python3 tests/test_platforms.py`. It renders all domain files for Linux and
macOS GUI/headless profiles, rejects duplicate declarations, and checks that
the CLI inventory and pinned options agree. It also checks SQLFluff configuration
availability and Pi's use of the mise-owned extension.

Neovim's TypeScript language server prefers a usable workspace JS SDK and falls
back to the editor-owned SDK shared with Astro. Mise's TypeScript 7 compiler
remains independent. The [editor integration checks](nvim-astro.md#checks)
exercise SDK selection, diagnostics, and completion with real language servers.

## Audit sources

Tool purposes were checked against local consumers, installed mise registry
metadata, and upstream package documentation. This was not an execution test
of all packages. Relevant distinctions are documented upstream:

- [Plannotator remote review](https://github.com/backnotprop/plannotator#remote--ssh--devcontainer)
- [Plannotator TUI](https://crates.io/crates/plannotator-tui)
- [Gentle Shell](https://github.com/Gentleman-Programming/gentle-shell)
- [Todoist authentication](https://github.com/Doist/todoist-cli#authentication)
- [QMD CPU and GPU operation](https://github.com/tobi/qmd)
- [CodeGraph](https://github.com/colbymchenry/codegraph)
- [Mermaid rendering](https://github.com/mermaid-js/mermaid-cli)
- [Mise config precedence implementation, v2026.10.18](https://github.com/jdx/mise/blob/8369bc78dc4761660337a2518b1445447438159d/src/cli/config/ls.rs)
