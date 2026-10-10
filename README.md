# project-template

A [copier](https://copier.readthedocs.io) template that creates a new project already
set up for the [agent-config](https://github.com/rickyb30/agent-config) pipeline.

- **New to the pipeline? Read [examples/README.md](examples/README.md) first.** It
  follows one small job from idea to reviewed code and shows every file produced.
- This template is generic. It ships no stack and an empty knowledge area. Everything
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

1. Fill in the TODOs in `CLAUDE.md`: stack, commands, layout, constraints. Project
   facts only.
2. Write what the project must do in `docs/requirements.md`.
3. Put conventions someone could get wrong into
   `.claude/skills/project-conventions/SKILL.md`: naming, environments, data rules.
4. Talk your first design through with Claude, then run `/rb-design <name>` to have
   it written to `docs/architecture/001-<name>.md` as a draft. (Or copy
   `000-template.md` and write it by hand.)
5. Run the pipeline on it.

## The pipeline at a glance

| Step | You type | Result |
| --- | --- | --- |
| Write up the design you discussed | `/rb-design <name>` | `docs/architecture/NNN-name.md` (draft) |
| Check the design is complete | `/rb-intake <design>` | a gap report |
| Have it challenged | `/rb-research <design>` | `docs/research/NNN-assessment.md` |
| **Gate 1** | you set `status: approved` in the design | |
| Turn it into a plan | `/rb-draft-plan <design>` | `docs/plans/NNN-name.md` |
| **Gate 2** | you set `status: approved` in the plan | |
| Build one milestone | `/rb-implement <plan> [M1]` | code, tests, `docs/plans/NNN-log.md` |
| Review independently | `/rb-review-diff` | `docs/reviews/NNN-review.md` |
| Record a lesson | `/rb-lesson <text>` | a proposal in `docs/knowledge/inbox/` |
| Verify | `scripts/verify.sh` | lint, types, tests, secret scan |

Source code cannot be written until both gates are passed. The worked example in
[examples/](examples/README.md) shows what each step looks like, including what
happens when a gate is closed and when a plan cannot be followed.

## What a generated project contains

```
CLAUDE.md                      project facts only: stack, commands, constraints
.claude/
  pipeline.json                switches the approval gate on; see docs/pipeline-config.md
  settings.json                project permissions
  skills/project-conventions/  where project conventions go
  agents/                      empty; add a same-named agent only to override a global one
docs/
  requirements.md
  pipeline-config.md           what .claude/pipeline.json can contain, with examples
  architecture/000-template.md mirrors the intake checklist
  adr/  research/  plans/  reviews/
  knowledge/                   INDEX.md, patterns/, lessons/, references/, inbox/
scripts/verify.sh              lint, types, tests, secret scan, pipeline document check
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
