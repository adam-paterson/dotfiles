# Pi delegation policy

These instructions apply to the parent session. Children follow their assigned task and agent definition.

## Dispatch

- Delegate when the task benefits from independent review, parallel work or a separate context. Follow skills that require delegation.
- Before delegating, call `subagent({ action: "list", capabilities: true })` to discover available agents. Choose an executable, enabled agent by its description and capabilities, not a remembered role name.
- Inspect each selected agent with `subagent({ action: "get", agent: "<name from list>" })`. Use its configured model and thinking level. Report the resolved model, thinking and launch context before starting it.
- Read the installed pi-subagents skill for execution syntax. Pass context explicitly. Use `fresh` for independent review and evidence gathering, or `fork` when the task needs the parent conversation. Use `profile` to follow the agent's declared `defaultContext`; it requires that default to exist.
- Ask before changing a model or thinking level, escalating a failed task, or replacing an unavailable agent. Ask even if a skill suggests a fallback.

## Skill integration

- For large or conflicting source collections, assign evidence gathering and analysis to separate agents. The parent can answer straightforward questions from the evidence and writes any requested report.
- Run Standards and Spec code reviews as separate tasks, each with its own evidence and fresh context. The parent gathers the diff and runs checks, then gives the results to both reviewers.
- High-risk work needs an independent correctness review using a different model from the writer. Check that the configured models differ. If they match, ask the user. Each additional review should address a different risk.
- If a skill names an unavailable agent, use the agent list to propose a replacement and ask for approval. Preserve the skill's scope and output requirements.
- Council mode must report the actual agents, models and contexts. Check the models, not just the agent names.

## Handoffs and completion

Give each child its task, supporting files or passages, constraints and completion criteria. State which files it may change. Give reviewers the requirements and diff, and give agents doing analysis the gathered evidence. Keep one writer per worktree. Agents gathering evidence or giving advice must not edit project files.

Inspect returned evidence and changes before reporting completion. Report anything that prevents completion, including unavailable models, missing tools or results, and unanswered questions that affect correctness. Never treat a missing result as success or silently retry with another model. Check project overrides because they can change the effective configuration.
