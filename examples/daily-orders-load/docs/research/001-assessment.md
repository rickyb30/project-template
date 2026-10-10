---
architecture: docs/architecture/001-daily-orders-load.md
date: 2026-02-01
---

# Assessment: Daily orders load

> Example file. Written by the researcher agent against the first draft of the design.

## Summary

The design is small and mostly sound. Its main risk is that it appends each file to
the target table, so any re-run duplicates a day, which contradicts goal G2. It also
does not say what one row of the file represents.

## Verified facts

| # | Fact | Source | Checked |
| --- | --- | --- | --- |
| F1 | The scheduler retries a failed job up to three times by default | https://docs.example.com/scheduler/retries | 2026-02-01 |
| F2 | The repository already has a staging-then-merge pattern for another feed | src/load_customers.sql:8 | 2026-02-01 |
| F3 | The sample export has several rows per order, one per line item | samples/orders-sample.csv:2 | 2026-02-01 |

## Alternatives matrix

| Decision | Option | Build cost | Run cost | Operational burden | Main risk |
| --- | --- | --- | --- | --- | --- |
| Write mode | Proposed: append | low | low | none | re-runs and retries duplicate rows (F1) |
| Write mode | Merge on a key | low | low | none | wrong key silently collapses rows (F3) |
| Write mode | Delete the day, then insert | low | low | none | a failure between the two steps loses the day |

## Security gaps

The file contains customer email. The design does not say whether development may
receive real files.

## Failure modes

- File missing at 03:00: not addressed. The job should fail loudly, not load nothing.
- File arrives twice or the job retries (F1): duplicates under the proposed append.
- Malformed file: would be partly applied, because there is no staging step.

## Unnecessary complexity

None found.

## Recommendations

| # | Severity | Recommendation | Based on |
| --- | --- | --- | --- |
| R1 | high | Replace append with a merge, and state the key | F1, F3 |
| R2 | medium | Add a staging table so a bad file is never half-applied | F2, failure modes |
| R3 | medium | Say whether customer email may reach development | security gaps |
| R4 | low | Fail the job when the file is missing | failure modes |

## Open questions

- What is the grain of the file: one row per order, or per order line? F3 suggests per
  line, but one sample is not proof.
- unverified: whether the export is ever regenerated for a past date.
