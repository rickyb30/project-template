---
plan: docs/plans/001-daily-orders-load.md
diff: main...HEAD
date: 2026-02-03
verdict: changes required
---

# Review: Daily orders load, M1

> Example file. Written by the reviewer agent, which saw only the plan and the diff.

## Findings

| # | Severity | Location | Finding | Suggested direction |
| --- | --- | --- | --- | --- |
| 1 | blocker | src/load_orders.sql:14 | The merge matches on `order_id` alone. An order with three lines keeps only the last one, so AC1.1 fails for any multi-line order. The test passes because its sample has one line per order. | Match on `(order_id, line_no)` as the plan's interface section states |
| 2 | major | tests/test_load_orders.py:22 | No test loads an order with more than one line, so finding 1 is not caught | Add a multi-line order to the sample and assert the line count |
| 3 | minor | src/load_orders.sql:31 | No row-count comparison between staging and target after the merge | Compare counts and fail on a mismatch |

## Acceptance criteria

| Criterion | Met | Evidence |
| --- | --- | --- |
| AC1.1 | no | finding 1 |
| AC1.2 | yes | tests/test_load_orders.py:35 |
| AC1.3 | yes | tests/test_load_orders.py:48 |

## Checklist

- Authentication, authorisation: not applicable: no entry points added.
- Secrets: checked, no finding.
- Input validation: checked, no finding (required columns are validated in staging).
- Data exposure: checked, no finding. Customer email is loaded only into the target.
- Idempotency: finding 1.
- Schema changes: checked, no finding. Both tables are new.
- Data quality: findings 1, 2, 3.
- Query cost: checked, no finding.
- Missing tests: finding 2.
- Plan conformance: finding 1.

## Outside the plan

None.
