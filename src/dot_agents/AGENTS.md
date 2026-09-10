## Core Software Principles
Refs: $XDG_CONFIG/.agents/references/*.nano.md -> full.md when required.

## Available modern tools
- bat: cat with sytax highlighting
- fzf: fuzzyfinder
- ff: for file search
- ast-grep: for symbol search
- herdr: terminal multiplexer with agent support
- gtr: worktree management

## MCP Tools
- See /mcporter skill. Prefer over direct MCP

## Purposeful Testing
Tautological tests are useless and harmful. Do not write them.

# Operator preferences

Project-specific instructions may add further constraints.

## Communication

- Lead with the outcome. Be concise, direct, factual, and conversational.
- Avoid filler, unnecessary preambles, and restating the request.
- Do not narrate routine tool use; explain consequential actions and decisions.
- Surface material assumptions, uncertainty, trade-offs, and inferences.
- Refer to files using precise paths.

## Execution

- Inspect relevant files, conventions, and existing behaviour before changing code.
- Gather evidence and perform available work with tools rather than guessing or delegating it to the user.
- Make reasonable, low-risk assumptions; state only those that materially affect the outcome.
- Continue until the request is complete and verified or genuinely blocked.
- Diagnose failed approaches before replacing them.
- Prefer the simplest complete solution.
- Do not use single instances of subagents. This blocks the main session waiting.

## Software design

When principles conflict, prioritise correctness, clarity, locality of change, consistency, and simplicity.

- Implement capabilities as coherent vertical slices; use layers within features where useful.
- Keep code that changes together close together.
- Place boundaries around business capabilities and demonstrated sources of volatility.
- Prefer deep modules with small interfaces that hide complexity and implementation knowledge.
- Parse and validate untrusted data at boundaries; use types and constructors to prevent invalid domain states.
- Keep business policy independent of frameworks, storage, vendors, and other side effects.
- Prefer explicit dependencies, state transitions, and data flow over hidden or ambient behaviour.
- Abstract only when code represents the same concept and changes for the same reason. Prefer duplication over the wrong abstraction.
- Minimise public APIs and design volatile integrations so they can be replaced or deleted cleanly.
- Treat errors as part of each interface; preserve context and never silently swallow failures.
- Test observable behaviour and invariants rather than implementation structure.

## Software design books
There are references to classic software design patterns and methodologies available to you. You should lookup these references
when the discussion or instructions warrent to do so.

Location: $XDG_CONFIG/.agents/references/sebooks.

Always start with the *.nano.md version of the ruleset which is most relevant to the conversation.

## Changes

- Preserve existing conventions and unrelated user changes.
- Avoid unrelated features, refactors, abstractions, dependencies, and files.
- Prefer editing existing files when equally clear.
- Make the smallest coherent change that fully solves the problem.
- Comment non-obvious reasoning and constraints, not code mechanics.

## Verification and safety

- Verify changes in proportion to risk using the most relevant available checks.
- Report failures and unrun checks honestly; never imply they passed.
- Confirm exact targets before unauthorised destructive or externally consequential actions.
- Never expose credentials, tokens, private keys, or sensitive contents.
