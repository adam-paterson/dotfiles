# Pi delegation policy

General operator instructions remain in `~/.agents/AGENTS.md`. This section applies only to the Pi parent orchestrator; child roles follow their assigned task and role definition.

## Dispatch

- Delegate when independent review, useful parallelism or substantial context isolation provides a concrete benefit. Explicit skill delegation mandates are exceptions; preserve them.
- Use canonical roles from the live `subagent` inventory. Role models and thinking belong in `~/.pi/agent/settings.json`, not skills or per-run overrides. Inspect the resolved role before its first use; report the actual model, thinking and context when launching.
- Ask the user before changing a role's model/thinking, escalating a failed task or substituting an unavailable model/agent. A skill's fallback instruction does not authorise substitution. Never treat a missing result as success.
- Use the installed pi-subagents skill for execution syntax. Pass context explicitly using the table below; global context defaults can otherwise override role preferences.

| Role | Responsibility | Launch context |
|---|---|---|
| scout | Locate local files, symbols and passages; return evidence, not broad conclusions | fresh |
| researcher | Retrieve primary-source passages and provenance | fresh |
| synthesizer | Evaluate substantial or conflicting evidence and form supported conclusions | fresh |
| worker | Implement the approved task as the single writer | fork, or fresh with a complete handoff |
| reviewer | Inspect a scoped change against requirements or standards | fresh |
| risk-reviewer | Independent security, data-integrity or cross-module review | fresh |
| oracle | Challenge a risky decision against the agreed direction | fork |
| delegate | Explicit bounded work not covered by another role; not an escape from role restrictions | fresh |

## Skill integration

- Research and grilling keep their delegation requirements. Route factual lookup to scout or researcher; add synthesizer only for substantial interpretation or conflicting evidence. The parent can answer straightforward questions directly from the returned packet and writes any requested durable report.
- Code-review keeps separate Standards and Spec review tasks, each with its own evidence packet and fresh context. The parent gathers the diff and runs checks; read-only reviewers receive the results.
- For high-risk work, use risk-reviewer as the independent correctness review and verify that its resolved model differs from the writer. If not, ask the user instead of selecting another model silently. Scope additional review to distinct risks rather than repeating the same review.
- When a skill names unavailable cavecrew presets, map investigator → scout, builder → worker, reviewer → reviewer; retain the skill's scope and concise output contract. These are role mappings, not per-run model substitutions. For other unavailable roles, ask rather than inventing one.
- Council mode must declare its actual roster/models/contexts. Request user approval for an unavailable-roster substitution; two role names alone do not establish model diversity.

## Handoffs and completion

Give each child the task, authoritative evidence paths or passages, scope/ownership, constraints and completion criteria. Reviewers receive the requirement and scoped diff; synthesizer receives the source packet. Keep one writer per worktree. Advisory and retrieval roles do not write project files.

Inspect the returned evidence and actual changes before reporting completion. Unavailable models, missing tools, uncaptured results and unresolved material evidence are blockers to report, not reasons for silent retries on another model. Stop and ask when a different model is needed. This is an orchestration policy, not an OS sandbox; project overrides can change runtime configuration and must be checked.
