# Public Pi agent configurations

Research based on two researcher evidence packets inspecting public agent files. These are static configurations, not verified runtime deployments. Model identifiers and custom frontmatter may require the owner's extensions or provider access.

## Personal configurations

| Repository | Agents | Useful distinction |
|---|---|---|
| [dilljens/pi-dotfiles](https://github.com/dilljens/pi-dotfiles/tree/f250b20aa400209fce2b787496bf83a001ef5d83/agents) | planner, executor, task-runner | Planning/execution mode switching plus a background shell runner |
| [mogassama/pi-agent-config](https://github.com/mogassama/pi-agent-config/tree/ea20c964b5440156ad51ed268193971d14d039b0/subagent-only/agents) | worker, reviewer, scout | Separate models, tight tool sets, bounded turns, structured submission |
| [s1lver091/pi-agent-config](https://github.com/s1lver091/pi-agent-config/tree/704712419f30a690f5362896afe1409f23e81584/agents) | scout, planner, worker, reviewer | Simple model-neutral handoff pipeline |
| [bruno-garcia/pi-config](https://github.com/bruno-garcia/pi-config/tree/544e01ce8e60c132bed7e8c98dd05ecee5659922/agents) | scout, worker, reviewer, visual-tester | Browser QA specialist alongside implementation roles |

## Representative prompt excerpts

### Scoped implementation

[mogassama worker](https://github.com/mogassama/pi-agent-config/blob/ea20c964b5440156ad51ed268193971d14d039b0/subagent-only/agents/worker.md):

> Stay inside the stated scope. A change you believe necessary but were not asked for goes in `deviations`, described, not made.

### Retrieval without interpretation

[mogassama scout](https://github.com/mogassama/pi-agent-config/blob/ea20c964b5440156ad51ed268193971d14d039b0/subagent-only/agents/scout.md):

> You locate things in a codebase and report where they are. You modify nothing, and you do not judge what you find.

### Background execution

[dilljens task-runner](https://github.com/dilljens/pi-dotfiles/blob/f250b20aa400209fce2b787496bf83a001ef5d83/agents/task-runner.md):

> You are a background task runner. Your job is to execute a shell command, monitor it, and report completion with clear evidence.

### Browser QA

[bruno-garcia visual-tester](https://github.com/bruno-garcia/pi-config/blob/544e01ce8e60c132bed7e8c98dd05ecee5659922/agents/visual-tester.md):

> You are a visual QA tester. Your job is to explore web UIs, find visual and interaction issues, and produce a structured report.

Configured tools: `bash, read, mcp:playwriter`. Model: `claude-sonnet-4`. Output: `visual-test-report.md`.

## Shared collections

- [nicobailon/pi-subagents](https://github.com/nicobailon/pi-subagents/tree/b72714de95e612406b3461e63dfc182856333a7e/agents): native roles include scout, researcher, evidence-auditor, worker, reviewer, oracle, delegate. Separately includes external CLI profiles.
- [furbyhaxx/pi-agent-roles](https://github.com/furbyhaxx/pi-agent-roles/tree/4784dfdc46a47c49480f6290c42548ee6011b856/examples/roles): 15 example session roles, including debugger, beta-tester, extension-architect, skill-architect, UI/UX designers and release-manager. These switch the main session's role rather than spawning children. The inspected npm files allowlist omits the example role directory.
- [Official Pi subagent examples](https://github.com/earendil-works/pi/tree/d1230ea2000d876b479a69b8b061f9d670f262f5/packages/coding-agent/examples/extensions/subagent/agents): scout, planner, reviewer, worker. Official examples, not another user's configuration.

## Caveats

- Role-switching configurations are not necessarily child-subagent definitions.
- Tool names and frontmatter are extension-specific, not universally portable Pi settings.
- Some prompts forbid all file writes while requesting report/plan artifacts. Clarify that distinction before reuse.
- Shell access is not made read-only by prompt wording alone.
- No packages were installed and none of these configurations were executed.
