# Contributing knowledge

This folder holds what the project has learned, so the next piece of work starts from
it. It stays in this repository and is never copied to another project.

## Folders

| Folder | Holds | Who writes |
| --- | --- | --- |
| `inbox/` | Proposals awaiting review | agents, or a person via `/rb-lesson` |
| `lessons/` | Things that went wrong and the rule that follows | a person |
| `patterns/` | Approaches that worked and when to use them | a person |
| `references/` | Stable facts about systems this project depends on | a person |
| `INDEX.md` | One line per accepted entry | a person |

Agents can write to `inbox/` only; a hook blocks them everywhere else in this folder.

## Entry format

```markdown
---
status: accepted            # proposed | accepted | retired
date: 2026-01-31
kind: lesson                # lesson | pattern | reference
evidence: docs/reviews/003-review.md#finding-2
review-by: 2026-07-31
tags: [retries, jobs]
---

# One-line statement of the lesson

## What happened
## Lesson
## Applies when
```

`evidence` must point at a review, plan, log entry or commit in this repository.
An entry with no evidence is an opinion and does not belong here.

## Approving a proposal

1. Read the proposal in `inbox/` and follow its evidence link.
2. If it would not change what someone does next time, delete it.
3. Otherwise move it to `lessons/`, `patterns/` or `references/`, set
   `status: accepted`, and add its line to `INDEX.md`.

## Keeping it fresh

- Every entry has a `review-by` date, six months out by default. `scripts/verify.sh`
  lists entries past that date.
- At review, either extend the date or set `status: retired` and remove the index line.
  Retired entries stay in the folder as history; agents ignore them.
- Prefer few, sharp entries. If the index outgrows one screen, retire or merge.

## Sharing beyond this project

Nothing leaves automatically. A lesson that proves general is rewritten from scratch,
with no project, employer or system detail, and committed to the shared configuration
by hand.
