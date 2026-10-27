# The workflow, by example

One small, fictional project taken from idea to working code. The two files it produces
are in [expensive-queries/](expensive-queries/docs/).

The project: a weekly report of the ten most expensive queries in a shared log store,
posted to a chat channel.

## 1. Discuss and research

In a Claude Code session inside the project you talk it through: what you want, which
data the platform keeps about query costs, how its workflows are scheduled, whether the
chat integration already exists. Ask Claude to look things up as you go. This is where
research belongs, before anything is written down.

## 2. `/rb-design expensive-queries`

Claude writes what you settled on to
[docs/architecture/001-expensive-queries.md](expensive-queries/docs/architecture/001-expensive-queries.md),
with `status: draft`. It has five sections: purpose, high-level architecture, tech
stack, identity, security and governance.

This project runs inside the platform with its built-in permissions, so identity and
security both say `Not applicable` with a one-line reason. Something you didn't discuss
would appear as `TODO: not discussed`. Points that came from research keep their link.

## 3. You review and approve

Read it against the conversation. When everything is captured, edit the front matter
yourself:

```yaml
status: approved
```

Claude can't do this step. If it tries, a hook blocks the write.

## 4. `/rb-intake docs/architecture/001-expensive-queries.md`

Claude breaks the design into phases in
[docs/plans/001-expensive-queries.md](expensive-queries/docs/plans/001-expensive-queries.md).
Each phase has what gets built, the files, a "done when" you can check, and a checkbox.
The deploy step is marked "(you run this)".

Run before approval, it stops: "Not approved yet: set `status: approved` in ... yourself".

## 5. `/rb-implement docs/plans/001-expensive-queries.md`

Claude builds the first phase not yet done, runs `scripts/verify.sh`, ticks the phase,
and tells you what changed and what you need to run. Run it again for the next phase,
or once with `all` at the end to do every remaining phase.

If a phase can't be done as the design says, Claude stops and asks rather than
improvising. When every phase is ticked, it closes the gate again.

## What you did

Four things: the discussion, reading the design, approving it, and running the deploy.
