---
title: Weekly expensive-query report
status: approved
date: 2026-03-02
---

# Weekly expensive-query report

> Example file, written by `/rb-design` from a conversation and then approved by hand.
> The scenario is fictional.

## Purpose

Queries against the shared log store are billed by the amount of data they scan, and a
few heavy queries make up most of the bill. Once a week the team wants a list of the
ten most expensive queries from the last seven days, with who ran them, so the owners
can tune them.

## High-level architecture

- A scheduled workflow in the observability platform runs every Monday at 08:00.
- It runs one query over the platform's own query-usage records for the last 7 days,
  ranked by data scanned.
- It formats the top ten as a table and posts it to the team's chat channel through the
  platform's built-in chat integration.

```
schedule (Mon 08:00) -> usage query -> format top 10 -> chat channel
```

## Tech stack

- The platform's workflow engine and query language.
- The workflow is kept as code in `workflows/expensive-queries.yaml` and deployed with
  the platform's CLI.
- The built-in chat integration, already configured for the team
  ([integration docs](https://docs.example.com/integrations/chat)).

## Identity

Not applicable: the workflow runs as the platform's built-in workflow actor with its
existing permissions, and the chat integration already exists. No new identities.

## Security and governance

Not applicable: the report contains query text and user names, which every member of
the channel can already see in the platform. No secrets, no new network paths.

## Open questions

1. Should queries run by scheduled jobs be listed separately from people's ad-hoc
   queries?
