# The pipeline, by example

This folder follows one small piece of work from idea to reviewed code, showing
exactly what you type, what Claude does, and which file appears at each step. Every
file mentioned is in [daily-orders-load/](daily-orders-load/) so you can open it.

The work: a fictional shop exports its orders as a CSV file every night, and you want
them loaded into a warehouse table each morning. The scenario and every name in it are
invented.

## The idea in one paragraph

"Pipeline" here means the fixed sequence of stages a change passes through. It is not
a data pipeline or a CI pipeline. You write a design. One agent challenges it. You
approve it. A second agent turns it into a plan. You approve that. A third agent
builds one milestone. A fourth agent, which has not seen the third agent's reasoning,
reviews the result. Each stage reads the previous stage's file and writes its own, and
source code cannot be written until both of your approvals are in place.

```
you: design ──> /rb-intake ──> /rb-research ──> YOU APPROVE ──> /rb-draft-plan
                                                                      │
       scripts/verify.sh <── /rb-review-diff <── /rb-implement <── YOU APPROVE
```

## Before you start

The project was created from this template, so it already contains
`.claude/pipeline.json`. That file switches the approval gate on for the project.

## Step 1: You write the design

You think the problem through, in chat or on paper, and save the result as
`docs/architecture/001-daily-orders-load.md`, copied from `000-template.md`, with
`status: draft`.

This is the only stage with no agent. The design is yours.

## Step 2: Check it is complete

You type:

```
/rb-intake docs/architecture/001-daily-orders-load.md
```

Claude prints a table and changes nothing:

```
Intake: docs/architecture/001-daily-orders-load.md  (status: draft)

| Section | Result | Note |
| --- | --- | --- |
| Goals | ok | |
| Non-goals | ok | |
| Key decisions | weak | "append to the table" names no rejected option |
| NFRs | ok | |
| Data | missing | the design moves data but has no Data section |

Ready for research: no (1 missing, 1 weak)
```

You add the missing section and run it again. This takes a minute and saves the next
stage from guessing.

## Step 3: Have it challenged

You type:

```
/rb-research docs/architecture/001-daily-orders-load.md
```

The researcher agent reads the design and the repository, looks things up, and writes
[docs/research/001-assessment.md](daily-orders-load/docs/research/001-assessment.md).
The design's status becomes `challenged`.

In the example the assessment found the real problem: the first draft **appended**
each file to the table, and the scheduler retries failed jobs, so any retry would
duplicate a whole day. It is recommendation R1 there, with the facts it rests on. The
researcher did not rewrite the design; it listed the options and their costs.

## Gate 1: You approve the design

You read the assessment, change the design (append became merge, a staging table was
added), and then edit the front matter yourself:

```yaml
status: approved
```

No agent can do this. If one tries, the hook stops it:

```
Blocked: 'docs/architecture/001-daily-orders-load.md' would have status: approved
after this change. Approval is a human gate...
```

The approved design is
[docs/architecture/001-daily-orders-load.md](daily-orders-load/docs/architecture/001-daily-orders-load.md).

## Step 4: Turn it into a plan

You type:

```
/rb-draft-plan docs/architecture/001-daily-orders-load.md
```

The planner agent writes
[docs/plans/001-daily-orders-load.md](daily-orders-load/docs/plans/001-daily-orders-load.md)
as `status: draft`, plus one short decision record per key decision, such as
[docs/adr/0001-merge-on-order-line.md](daily-orders-load/docs/adr/0001-merge-on-order-line.md).

The plan splits the work into two milestones, each with acceptance criteria you could
check yourself ("loading the same file a second time leaves the row count unchanged"),
and it states what must not be touched.

If you had run this before approving the design, it would have refused:

```
Gate: docs/architecture/001-daily-orders-load.md has status challenged.
A human must set status: approved first.
```

## Gate 2: You approve the plan

You read the plan. This is the cheapest moment to change direction: nothing has been
built. When you are satisfied, you set `status: approved` in the plan yourself.

## Step 5: Build one milestone

You type:

```
/rb-implement docs/plans/001-daily-orders-load.md M1
```

The implementer agent builds milestone M1 only, runs `scripts/verify.sh`, and appends
an entry to [docs/plans/001-log.md](daily-orders-load/docs/plans/001-log.md) saying
what changed and what the checks reported.

Until gate 2, the same request is stopped the moment the agent tries to write code:

```
Blocked: plan 'docs/plans/001-daily-orders-load.md' has status 'draft', not approved.
A human approves the plan before any source change.
```

## Step 6: Review it independently

You type:

```
/rb-review-diff
```

The reviewer agent is given the plan and the diff, and nothing about what the
implementer thought it was doing. It writes
[docs/reviews/001-review.md](daily-orders-load/docs/reviews/001-review.md).

In the example it found a blocker: the merge matched on the order number alone, but
the file has one row **per order line**, so an order with three lines kept only one.
The implementer's own tests passed, because the sample data had one line per order.
This is the kind of error a second, uninformed reader catches and the author does not.

You send the fix back through `/rb-implement`, and the log records it.

## Step 7: When the plan cannot be followed

On milestone M2 the plan said to reuse an existing alert helper. The implementer found
the helper could not do the job, and that fixing it meant changing a file the plan
said must not change. It did not pick a way forward. It wrote a `DEVIATION` entry in
the log with the two options and stopped.

You wrote the decision into the log, ran `/rb-implement` again, and M2 finished. See
the `M2` entries in [the log](daily-orders-load/docs/plans/001-log.md).

## Step 8: Keep what was learned

The reviewer also wrote a proposal to
[docs/knowledge/inbox/](daily-orders-load/docs/knowledge/inbox/2026-02-03-confirm-file-grain.md):
"confirm the grain of a file before choosing a merge key". Agents can only write to
`inbox/`. You decide: delete it, or move it to `lessons/` and add a line to
`INDEX.md`. On the next piece of work the researcher and planner read that index first.

You can also record a lesson yourself at any time:

```
/rb-lesson merges need a test row that would collapse under a too-narrow key
```

## Step 9: Verify

`scripts/verify.sh` runs your lint, type check and tests, a secret scan, and a check
that every pipeline document has a valid status. CI runs the same script. No model is
involved in this step.

## What you did, and what the agents did

| You | The agents |
| --- | --- |
| Wrote the design | Checked it was complete |
| Read the assessment and revised the design | Found the duplicate-rows risk |
| Approved the design | |
| Read and approved the plan | Broke the work into milestones with checkable criteria |
| Decided the deviation | Built each milestone and ran the checks |
| Decided what to do about the findings | Found the wrong merge key |
| Decided whether to keep the lesson | Proposed the lesson |

Your time went on four decisions. The typing, the lookups, the checking and the
second opinion were done for you.

## When not to use it

A typo, a one-line fix or a quick experiment does not need a design document. The
pipeline costs several times the tokens of a single session, because four agents each
read the context afresh. Use it for work where building the wrong thing, or building
the right thing carelessly, would cost you more than that.

For a small change in a project that has the gate switched on, write a short plan and
approve it, or make the change by hand.
