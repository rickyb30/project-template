# Pipeline configuration

`.claude/pipeline.json` switches the approval gate on for this project and tunes it.
Only a person edits it: agents are blocked from creating or changing it. Edit it in
your editor, not by asking Claude.

The file is plain JSON, so it cannot hold comments. This page is its documentation.

## Settings

| Key | Type | Meaning | When absent |
| --- | --- | --- | --- |
| `source_paths` | list of folders | The folders agents may write to only while an approved plan is active | Every path except `docs/` and `.claude/` is protected |
| `allow_deploy` | list of command prefixes | Commands that change a live environment and that agents may run here | Agents may run none; a person runs them |

Deleting the file switches the approval gate off for the project.

## Examples

Protect everything except `docs/` and `.claude/`. The strictest setting, and the
default for a new project:

```json
{}
```

Protect only the code, so agents can still edit the README, configuration and
scripts without a plan. A good starting point for an existing project:

```json
{
  "source_paths": ["src", "tests"]
}
```

An infrastructure and data project. Infrastructure code, SQL models and job
definitions need an approved plan, and agents may run development builds but never
an apply:

```json
{
  "source_paths": ["infra", "models", "jobs", "tests"],
  "allow_deploy": ["dbt build --target dev", "dbt run --target dev"]
}
```

A sandbox project where agents may apply infrastructure to a throwaway environment:

```json
{
  "source_paths": ["infra"],
  "allow_deploy": ["terraform apply", "terraform destroy"]
}
```

## How the two settings behave

**`source_paths`** entries are folder names relative to the project root. `"src"`
covers `src/` and everything under it, and does not cover `src-old/`. While no plan is
active, or the active plan or its design is not `approved`, writes there are blocked.
`docs/plans/.active` names the active plan; `/rb-implement` sets it. Delete that file
when a plan is finished to close the gate again.

**`allow_deploy`** entries are matched from the start of the command, so
`"dbt build --target dev"` allows `dbt build --target dev --select orders` and does not
allow `dbt build --target prod`. Put the fixed arguments first when you write the
entry, and have agents write the command the same way. Without an entry, commands
that apply, deploy, destroy, or write to a warehouse are blocked for agents, while
reading, validating and planning commands are allowed.

Keep `allow_deploy` short. Each entry is something an agent can now do to a real
environment without asking you. Prefer giving agents read-only credentials and
leaving production changes to CI.
