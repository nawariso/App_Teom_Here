# Agent Workspace

This folder defines the end-to-end agent workspace for Toem Here!.

Use these files as the source of truth when assigning work to Codex, Claude Code, Pixel Agents, or a future custom agent orchestrator.

## How To Use

1. Start with `operating-model.md`.
2. Pick the right role from `agent-roster.md`.
3. Copy the matching role prompt from `roles/`.
4. Create the task with `templates/agent-task.md`.
5. Require every agent to finish with `templates/handoff.md`.

## Core Rule

Agents do not make product, architecture, data, infrastructure, or release decisions silently. They either follow the approved docs or leave a decision record for PM, SA, EA, DBA, Infra, DevOps, or QA to review.

## Workspace Files

- `operating-model.md`: how agents collaborate.
- `agent-roster.md`: role list and ownership.
- `task-routing.md`: which agent handles which task.
- `roles/`: reusable role prompts.
- `templates/`: task and handoff templates.
- `runs/`: active and historical agent work orders.

## Current Run

- Real project roadmap: `docs/agents/runs/2026-06-07-real-project-roadmap.md`
- MVP backlog: `docs/agents/runs/2026-06-07-mvp-backlog.md`
- Agent cycle summary: `docs/agents/runs/2026-06-07-agent-cycle-summary.md`
