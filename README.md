# project-template

A [copier](https://copier.readthedocs.io) template for projects that use the
[agent-config](https://github.com/rickyb30/agent-config) pipeline: design, research,
plan, implement, review, with two human approval gates.

The template is generic. It ships an empty knowledge area and no stack; everything
specific to a project is filled in after generation and stays in that project's own
repository.

## Use

Requires `copier` 9 or newer, and `agent-config` bootstrapped on the machine.

```bash
copier copy gh:rickyb30/project-template my-project
cd my-project
git init && git config core.hooksPath .githooks
scripts/verify.sh
```

To pin a version, add `--vcs-ref v0.1.0`. To pull later template changes into an
existing project:

```bash
copier update
```

The template runs no tasks, so copier never needs `--trust`.

## What a generated project contains

```
CLAUDE.md                      project facts only: stack, commands, constraints
.claude/
  pipeline.json                opts the project into the approval gate
  settings.json                project permissions
  skills/project-conventions/  where project conventions go
  agents/                      empty; add a same-named agent only to override a global one
docs/
  requirements.md
  architecture/000-template.md mirrors the intake checklist
  adr/  research/  plans/  reviews/
  knowledge/                   INDEX.md, patterns/, lessons/, references/, inbox/
scripts/verify.sh              lint, types, tests, secret scan, pipeline doc check
.githooks/pre-commit           secret scan on staged changes
.github/workflows/ci.yml       runs scripts/verify.sh (optional)
```

## Develop

```bash
tests/test.sh        # renders the template and runs the generated verify.sh
```

This repository is public. Nothing derived from an employer's or a client's work may
enter it; see `docs/PUBLIC-SAFETY.md` in agent-config. Commits here are scanned by the
agent-config hooks once `git config core.hooksPath .githooks` is set.
