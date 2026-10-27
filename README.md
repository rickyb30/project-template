# project-template

A [copier](https://copier.readthedocs.io) template that creates a new project already
set up for the [agent-config](https://github.com/rickyb30/agent-config) pipeline.

- **New to the pipeline? Read [examples/README.md](examples/README.md) first.** It
  follows one small job from idea to reviewed code and shows every file produced.
- This template is generic. It ships no stack. Everything
  specific to a project is filled in after generation and stays in that project's own
  repository.

## What you get from it

Starting a project by hand means remembering which folders the agents expect, which
file switches the approval gate on, and what a design document must contain. This
template does that in one command, so every project you start has the same layout and
the agents behave the same way in each.

## Create a project

You need `copier` 9 or newer, and `agent-config` bootstrapped on the machine.

```bash
copier copy gh:rickyb30/project-template my-project
```

Copier asks a few questions:

| Question | What it is for | If you leave it empty |
| --- | --- | --- |
| Project name | Title in `CLAUDE.md` and `README.md` | required |
| Slug | Short identifier | derived from the name |
| Description, stack | Go into `CLAUDE.md` | a TODO is left for you |
| Lint, type-check, test commands | What `scripts/verify.sh` runs | that check is skipped until you set it |
| Source paths | Folders the approval gate protects | everything except `docs/` and `.claude/` |
| Allowed deploy commands | Environment-changing commands agents may run | agents may run none |
| CI | GitHub Actions workflow, or none | GitHub Actions |

Then:

```bash
cd my-project
git init && git config core.hooksPath .githooks   # scan every commit for secrets
scripts/verify.sh                                 # should print "verify: ok."
```

## First hour in a new project

1. Fill in the TODOs in `CLAUDE.md`: stack, commands, conventions, constraints.
   Project facts only.
2. Discuss and research your first idea with Claude, then run `/rb-design <name>`.
3. Review the design, approve it, then `/rb-intake` and `/rb-implement`.

## The workflow at a glance

| Step | You type | Result |
| --- | --- | --- |
| Discuss and research the idea | (conversation) | |
| Write it up | `/rb-design <name>` | `docs/architecture/NNN-name.md` (draft) |
| **Approve** | you set `status: approved` in the design | |
| Break into phases | `/rb-intake <design>` | `docs/plans/NNN-name.md` |
| Build | `/rb-implement <plan>` (or `<plan> all`) | code and tests; the phase is ticked |

Source code can't be written until you approve the design. The worked example in
[examples/](examples/README.md) shows each step.

## What a generated project contains

```
CLAUDE.md                      project facts: stack, commands, conventions, constraints
.claude/
  pipeline.json                switches the approval gate on; see docs/pipeline-config.md
  settings.json                project permissions
docs/
  pipeline-config.md           what .claude/pipeline.json can contain, with examples
  architecture/000-template.md the design doc layout
  plans/                       phases written by /rb-intake
scripts/verify.sh              lint, types, tests, secret scan, workflow document check
.githooks/pre-commit           secret scan on staged changes
.github/workflows/ci.yml       runs scripts/verify.sh (only if you chose GitHub CI)
```

## Updating a project when the template changes

```bash
copier update
```

Copier re-applies the template and keeps your edits, showing a conflict where both
changed the same lines. To pin a project to a template version, create it with
`--vcs-ref v0.1.0`.

The template runs no tasks, so copier never asks for `--trust`.

## Working on the template itself

```bash
git config core.hooksPath .githooks   # once: scan commits here for secrets and denylisted terms
tests/test.sh                         # renders the template and runs the generated verify.sh
```

Nothing derived from an employer's or a client's work may enter this repository, and
every example must be fictional. See `docs/PUBLIC-SAFETY.md` in agent-config.
