---
title: Daily orders load
status: approved
architecture: docs/architecture/001-daily-orders-load.md
date: 2026-02-02
---

# Plan: Daily orders load

> Example file. Written by the planner agent as `status: draft`; a person changed it
> to `approved` after reading it.

## Requirements map

| Requirement (from the architecture) | Component | Files |
| --- | --- | --- |
| G1: orders queryable each morning | loader, target table | src/load_orders.sql, migrations/0007_order_lines.sql |
| G2: re-runs never duplicate | loader (merge) | src/load_orders.sql, tests/test_load_orders.py |
| G3: available by 06:00 | schedule | jobs/daily_orders.yml |

## Dependencies

None.

## Migrations and interfaces

- New table `staging.orders_raw` (all columns text, truncated each run).
- New table `analytics.order_lines`, unique on `(order_id, line_no)`.

## Must not change

- `src/load_customers.sql` and its tables.
- The scheduler's shared configuration.

## Rollout and rollback

Development first, then production, both run by a person. Rollback: drop the two new
tables and remove the job; nothing else depends on them yet.

## Milestones

### M1: A day's file can be loaded, and loaded again, without duplicates
- Scope: migration for both tables; loader that copies to staging and merges.
- Files: migrations/0007_order_lines.sql, src/load_orders.sql, tests/test_load_orders.py
- Acceptance criteria:
  - [ ] AC1.1: loading the sample file produces one target row per line in the file
  - [ ] AC1.2: loading the same file a second time leaves the row count unchanged
  - [ ] AC1.3: a file with a missing required column fails and leaves the target untouched
- Checks: `scripts/verify.sh`

### M2: The load runs daily and someone is told when it fails
- Scope: job definition at 03:00 with a failure alert, reusing the existing alert helper.
- Files: jobs/daily_orders.yml
- Acceptance criteria:
  - [ ] AC2.1: the job definition validates
  - [ ] AC2.2: a missing file fails the job and raises an alert
- Checks: `scripts/verify.sh`

## Unresolved questions

None.
