---
title: Daily orders load
status: approved
date: 2026-02-02
---

# Daily orders load

> Example file. This is the design after the author revised it in response to the
> assessment, which is why it says "merge" where the first draft said "append".

## Goals

- G1 (R1): yesterday's orders are queryable in the warehouse every morning.
- G2 (R2): running the load twice for the same day never duplicates rows.
- G3 (N1): data is available by 06:00 local time.

## Non-goals

- Real-time or intraday loading.
- Loading order history from before the first export file.

## Constraints

- The shop system can only produce one CSV export per day, written to object storage
  at about 02:00.
- No new paid services. Use the existing warehouse and the existing scheduler.

## Components

| Component | Responsibility | Interface |
| --- | --- | --- |
| Export file | One CSV per day, one row per order line | `exports/orders/YYYY-MM-DD.csv` |
| Staging table | Holds one day's file exactly as received | `staging.orders_raw` |
| Loader | Copies the file to staging, then merges into the target | `src/load_orders.sql` |
| Target table | One row per order line, current state | `analytics.order_lines` |
| Schedule | Runs the loader daily at 03:00, alerts on failure | `jobs/daily_orders.yml` |

## Key decisions

1. **Merge into the target, keyed on order and line number.** Rejected: plain append,
   because a re-run would duplicate the day (see assessment R1).
2. **Keep a staging table.** Rejected: loading straight into the target, because a
   malformed file would then be half-applied.

## NFRs

- Availability: loaded by 06:00 on 99% of days.
- Volume: up to 200,000 lines per file.
- Recovery: any day can be re-run by hand from its file.

## Data

Source: the shop system's nightly export. Freshness: one day. Retention: target kept
indefinitely, staging truncated on each run. Classification: contains customer email,
which is restricted and must not be copied to lower environments.

## Environments and rollout

Development and production warehouses. The table and job are created in development
first. A person runs the production deploy; agents do not.

## Cost

One small scheduled query per day on existing compute. No new services.

## Access

The loader runs as the existing scheduler role, which gets read on the export path and
write on the two tables. No new identities.

## Open questions

None.
