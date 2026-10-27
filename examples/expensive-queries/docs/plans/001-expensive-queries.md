---
design: docs/architecture/001-expensive-queries.md
date: 2026-03-02
---

# Phases: Weekly expensive-query report

> Example file, written by `/rb-intake`. `/rb-implement` ticks each phase when its
> checks pass.

## Phase 1: the usage query returns the top ten for the last 7 days
- Build: the query, saved in the repository so it can be reviewed and tested.
- Files: `queries/expensive-queries.dql`, `tests/test_query_shape.py`
- Done when: a manual run in the platform returns ten rows with query, user and data
  scanned; the shape test passes.
- [x] done

## Phase 2: the workflow runs on schedule and posts to the channel
- Build: the workflow definition with the Monday 08:00 schedule, the query from phase 1,
  and the chat step.
- Files: `workflows/expensive-queries.yaml`
- Done when: the definition validates with the platform CLI; a manual trigger posts the
  table to a test channel.
- Deploy the workflow with the platform CLI (you run this).
- [ ] done

## Questions

1. Open question 1 from the design (scheduled jobs listed separately) is still open;
   phase 1 lists everything together until it is decided.
