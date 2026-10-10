---
status: proposed
date: 2026-02-03
kind: lesson
evidence: docs/reviews/001-review.md#finding-1
review-by: 2026-08-03
tags: [merge, grain, loading]
---

# Confirm the grain of a file before choosing a merge key

> Example file. Written by the reviewer agent. A person decides whether it is kept.

## What happened
The first loader merged on `order_id`, but the export has one row per order line, so
multi-line orders lost lines. The test sample had one line per order and passed.

## Lesson
When a loader merges, state the grain of the source in the design, and include a test
row that would collapse if the key were too narrow.

## Applies when
Any load that merges or deduplicates. Does not apply to append-only event feeds.

## Suggested index line
`lessons/confirm-file-grain.md` | Confirm the grain of a file before choosing a merge key | merge, grain, loading
