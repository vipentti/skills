---
name: planlet-plan-review
description: Read-only convergence review for Planlets after initial review or revision. Checks plan.md and tasks.md for material contradictions, stale decisions, missing task coverage, invalid ordering, unresolved implementation decisions, and revision regressions. Do not use for exhaustive design discovery, architecture critique, optimization, or broad edge-case hunting.
license: MIT
---

# Planlet Plan Review

## Rules

Read-only review. Do not edit files, change task state, complete the planlet, modify repository state, or implement changes.

Review internally. Do not expose reasoning, scratchpad, process notes, or tool use.

This is a **convergence review**, not a deep discovery review. The goal is to determine whether the current plan is coherent and ready to implement, not whether it could be improved further.

## Objective

Primary test:

> Can a competent implementation agent follow this plan as written without encountering a material contradiction, missing required work, invalid instruction, or unresolved design decision?

Report only issues likely to cause incorrect implementation, blocked implementation, invalid verification, or material rework.

Do not reopen settled design decisions merely because another approach is possible.

## Inputs

Review the in-scope `plan.md` and `tasks.md` as one implementation handoff.

Inspect repository code, tests, config, or documentation only when needed to verify a material claim or resolve an apparent contradiction. Do not perform broad repository exploration looking for additional concerns.

Treat:

- `plan.md` as the authority for outcome, scope, design decisions, invariants, acceptance, and verification.
- `tasks.md` as the ordered execution breakdown implementing that plan.

## Review Checks

### 1. Internal consistency

Check that the plan agrees with itself.

Report:

- contradictory requirements or design decisions
- stale sections left behind after revisions
- scope or exclusion conflicts
- acceptance criteria inconsistent with the stated behavior
- verification that proves different behavior than the plan requires
- terminology or ownership differences that materially change meaning

Do not report harmless wording differences.

### 2. Plan-task consistency

Ensure `tasks.md` faithfully implements `plan.md`.

Report when:

- a required plan outcome has no task ownership
- a task contradicts the plan
- a task introduces materially out-of-scope behavior
- prerequisite work occurs after its consumer
- a task depends on excluded or nonexistent work
- completion conditions conflict with plan acceptance criteria

Do not require every plan detail to be repeated in tasks.

### 3. Implementability

Check for unresolved choices that would force the implementer to invent material behavior.

Report only when reasonable implementations could differ materially in behavior, ownership, state, compatibility, failure semantics, or externally visible results.

Do not demand explicit detail when repository conventions or the plan already settle the choice.

### 4. Repository alignment

Verify repository facts only where they matter to execution.

Report material mismatches such as:

- referenced files, APIs, commands, or configuration that do not exist and are not introduced by the plan
- assumptions contradicted by the relevant existing implementation
- incorrect ownership or integration points
- verification instructions that cannot work in the repository as described

Do not use this check to conduct a new architecture review or search for better implementation approaches.

### 5. Revision regressions

When the plan has been revised, check that changes did not leave related sections or tasks inconsistent.

Pay particular attention to:

- renamed concepts
- changed ownership
- changed scope
- changed ordering
- removed behavior
- modified acceptance criteria
- modified verification

Report the resulting inconsistency, not the history of how it arose.

## Convergence Discipline

Do **not** report:

- alternative designs that are merely preferable
- additional edge cases not required by the stated behavior
- optional hardening or polish
- speculative future requirements
- opportunities for refactoring
- additional abstractions
- broader architecture improvements
- stronger verification when existing verification is sufficient
- additional documentation that implementation does not require
- minor conciseness, style, naming, or wording improvements
- concerns already resolved by the plan or repository
- issues whose fix would not materially affect implementation correctness

Do not expand the review because few or no findings remain.

A clean review is a valid and desirable result.

## Findings

Use only:

- **BLOCKER**: the plan is contradictory, undefined, impossible, or unsafe enough that implementation cannot reliably proceed.
- **IMPORTANT**: likely to cause incorrect or incomplete implementation, invalid verification, or material rework.

Before reporting an IMPORTANT finding, ask:

> Would a competent implementation agent plausibly implement the wrong thing, become blocked, or require substantial rework because of this?

If not, omit it.

Group findings by root cause. State the issue, practical impact, and smallest complete fix.

Do not report suggestions or optional improvements.

## Verdict

- **READY**: no BLOCKER or IMPORTANT findings remain.
- **NEEDS REVISION**: at least one BLOCKER or IMPORTANT finding remains.

`READY` means the plan is sufficiently coherent for implementation. It does not mean no imaginable improvement exists.

## Output

Use:

```text
Verdict: READY | NEEDS REVISION
Reviewed: <plan-identifier> @ <commit-sha>
Requested revisions

1. [SEVERITY] <location> - issue
   Why: practical impact
   Fix: smallest complete correction
```

Use the most useful available planlet identifier and `unknown` when the commit SHA is unavailable.

Prefer `file:line` for locations when available; otherwise use the relevant heading or task identifier.

If no findings:

```text
Verdict: READY
Reviewed: <plan-identifier> @ <commit-sha>
Requested revisions

- None.
```

## Final Check

Before returning `NEEDS REVISION`, confirm every finding:

1. identifies a concrete defect in the current plan,
2. could materially affect implementation or verification,
3. is not merely an opportunity to improve the design,
4. is not already settled by repository reality, and
5. can be fixed without expanding the intended scope.

If no finding passes all five conditions, return `READY`.
