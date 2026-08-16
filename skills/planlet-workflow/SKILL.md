---
name: planlet-workflow
description: >
  Use only when explicitly requested or when repository instructions opt into
  this workflow. Apply an opinionated Planlet development workflow: work through
  one task at a time in plan order, verify before checking it off, create one
  commit per completed task, and complete the Planlet in a separate final
  commit. Layers on top of Planlet's normal planning, implementation, and
  completion skills.
license: MIT
---

# Planlet Workflow

Use this skill as an opinionated workflow layer on top of Planlet.

Do not activate it merely because Planlet is installed. Use it when the user or
repository instructions explicitly opt into `planlet-workflow`.

Planlet's own skills and CLI remain authoritative for Planlet lifecycle
operations, file formats, validation, task state, and completion behavior. This
skill adds stricter execution and Git workflow rules.

## Core Workflow

When implementing a Planlet, follow this loop in order:

1. Select and validate exactly one active Planlet.
2. Read its complete `plan.md` and `tasks.md` before implementation begins.
3. Take the first unchecked task, in listed order.
4. Implement only that task.
5. Run its required verification.
6. Check the task off using the Planlet CLI.
7. Commit that task's implementation and corresponding Planlet state together.
8. Report the task outcome.
9. Repeat from step 3 until no unchecked tasks remain.
10. Run the separate Planlet completion workflow.
11. Commit the completed or archived Planlet state separately.

One task per iteration. One implementation commit per task. Do not batch tasks,
implement ahead, or defer task verification until the end.

## Selecting the Planlet

Use Planlet's normal implementation workflow to resolve and validate the
Planlet.

If the user supplies a slug, use that slug if it is a valid active Planlet.

If no slug is supplied:

- use the sole active Planlet when there is exactly one;
- if several are active and the requested work clearly identifies one, use it;
- otherwise ask the user to choose rather than guessing.

Announce the selected slug before changing implementation files.

## Read Before Implementing

Before starting the first task:

- read `plan.md` completely;
- read `tasks.md` completely;
- inspect relevant repository instructions and existing working-tree changes;
- preserve unrelated user work.

Treat `plan.md` as the implementation and acceptance contract and `tasks.md` as
the ordered execution list.

Tasks inherit applicable requirements from the plan even when those
requirements are not repeated in the task text.

## One Task at a Time

Always take the first unchecked task in `tasks.md`.

Do not:

- reorder tasks for convenience;
- start later tasks while the current task is unfinished;
- combine several tasks into one implementation pass;
- implement anticipated work from later tasks;
- silently broaden the current task.

A task may naturally touch several files. "One task at a time" constrains scope,
not file count.

If the current task cannot be completed without work materially outside the
persisted plan, stop rather than silently expanding scope. Revise the plan and
tasks only when the user has authorized that change or the surrounding Planlet
workflow grants that authority.

## Verify Before Checking

A task is complete only after its complete outcome has been implemented and its
relevant verification has succeeded.

Run:

1. the task-specific `Verify:` requirement, when present; and
2. applicable repository checks required by the plan's verification contract.

Fix an in-scope verification failure before continuing.

If required verification cannot be performed or remains failing, leave the task
unchecked and report the blocker. Never mark a task complete based only on the
implementation appearing correct.

Use the Planlet CLI to change checkbox state. Never edit task checkboxes by
hand.

After checking a task, confirm Planlet's reported task and lifecycle state
before continuing.

## One Commit Per Task

After a task has been implemented, verified, and checked off, create exactly one
commit for that task.

The commit must contain:

- the implementation for that task; and
- the Planlet task-state change describing that implementation.

Do not:

- put multiple Planlet tasks into the same implementation commit;
- commit implementation before its corresponding task has been checked;
- leave Planlet state trailing the repository state it describes;
- include unrelated working-tree changes;
- amend an earlier task commit with later-task work.

If unrelated user changes are present, preserve them and commit only the files
or hunks belonging to the current task.

Unless repository instructions say otherwise, use the repository's established
commit-message convention.

## Report After Every Task

After each task commit, briefly report:

- the completed task ID and outcome;
- verification performed and whether it passed;
- the commit created;
- what task comes next, if any.

Do not wait until the entire Planlet is finished before reporting progress.

## Complete Separately

After the final task has been:

1. implemented;
2. verified;
3. checked off; and
4. committed;

run Planlet's separate completion workflow.

Use the normal `planlet-complete` skill or equivalent Planlet CLI lifecycle
operation. Do not manually move the Planlet or write completion metadata.

After successful completion, create a separate commit containing the
completion/archive state.

The completion commit must not contain implementation work from the final task
or any other task.

The intended history is therefore:

```text
task 1 implementation + task 1 Planlet state
task 2 implementation + task 2 Planlet state
task 3 implementation + task 3 Planlet state
...
Planlet completion/archive
```

## Scope Changes and Drift

Pause rather than guess when:

- the persisted plan is materially stale;
- a task has multiple consequential interpretations;
- required work materially exceeds the task or plan;
- verification fails without a clear in-scope remedy;
- proceeding would overwrite or mix unrelated user work;
- required authority is missing.

Do not use a later task as justification for silently widening the current one.

Small implementation discoveries that remain clearly within the current task's
documented outcome do not require plan revision.

## Relationship to Planlet Skills

This skill does not replace:

- `planlet-plan`;
- `planlet-implement`;
- `planlet-complete`;
- the `planlet` CLI.

Use those for Planlet-specific mechanics and lifecycle safety.

Where this skill is stricter about workflow granularity, its stricter rule
applies when the skill has been explicitly activated. In particular:

- tasks are executed in listed order rather than opportunistically reordered;
- only one task is implemented at a time;
- every completed task gets its own commit;
- Planlet completion gets its own separate commit.

Do not weaken Planlet's validation, safety, verification, or state-management
rules in order to satisfy this workflow.

## Final State

A successfully finished Planlet using this workflow should have:

1. every planned task implemented and verified;
2. every task checked through the Planlet CLI;
3. one implementation commit per task;
4. Planlet state committed alongside the task it describes;
5. the Planlet completed through its normal completion workflow;
6. completion/archive state in its own final commit; and
7. no unrelated work mixed into those commits.
