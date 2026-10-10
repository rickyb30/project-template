---
status: accepted
date: 2026-02-02
source: docs/architecture/001-daily-orders-load.md
---

# 0001: Merge the daily file into the target on order and line number

> Example file. Written by the planner agent from the approved design.

## Context

The loader must be safe to re-run for the same day, and the scheduler retries failed
jobs automatically. The export has one row per order line.

## Decision

The loader merges each day's file into `analytics.order_lines`, matching on order
identifier and line number.

## Alternatives considered

- Plain append: rejected because a re-run or retry duplicates the day.
- Delete the day then insert: rejected because a failure between the steps loses the day.

## Consequences

Re-runs are safe. The merge key must match the true grain of the file; if the export
ever changes grain, this decision must be revisited.
