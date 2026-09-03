---
name: planlet-plan-review
description: Read-only convergence review for Planlets after a substantive review has already been completed, normally after revisions. Re-checks plan.md and tasks.md for material contradictions, stale decisions, missing task coverage, invalid ordering, unresolved implementation decisions, repository mismatches, and revision regressions. Do not use for initial or exhaustive design review, architecture critique, optimization, or broad edge-case discovery.
license: MIT
---

# Planlet Plan Review

## Rules

Read-only review. Do not edit files, change task state, complete the planlet, modify repository state, or implement changes.

This is a convergence review, not a discovery review. Determine whether the current plan is coherent and ready to implement. Do not reopen settled design decisions or search for further improvements merely because alternatives exist.

Complete all applicable checks before the verdict. Do not stop after the first finding.

## Objective

Primary test:

> Can a competent implementation agent follow this plan as written without encountering a material contradiction, missing required work, invalid instruction, or unresolved design decision?

Report only defects likely to cause incorrect or blocked implementation, invalid verification, or material rework.

## Inputs

Review the in-scope `plan.md` and `tasks.md` as one implementation handoff.

Treat:

* `plan.md` as owning outcome, scope, design decisions, invariants, acceptance, and verification.
* `tasks.md` as the ordered execution breakdown implementing that plan.

Inspect repository code, tests, config, or documentation only when needed to verify a material claim or resolve an apparent contradiction. Do not broadly explore the repository for additional concerns.

## Review Checks

### 1. Internal consistency

Check that the plan agrees with itself.

Report material:

* contradictory requirements or design decisions
* stale sections left after revisions
* scope or exclusion conflicts
* acceptance criteria inconsistent with required behavior
* verification proving different behavior than the plan requires
* terminology or ownership differences that change meaning

Ignore harmless wording differences.

### 2. Plan-task consistency

Ensure `tasks.md` faithfully implements `plan.md`.

Report when:

* required plan outcomes lack task ownership
* tasks contradict the plan
* tasks introduce materially out-of-scope behavior
* prerequisites occur after their consumers
* tasks depend on excluded or nonexistent work
* completion conditions conflict with plan acceptance criteria

Do not require every plan detail to be repeated in tasks.

### 3. Implementability

Check for unresolved choices that force the implementer to invent material behavior.

Report when reasonable implementations could differ materially in behavior, ownership, state, compatibility, failure semantics, or externally visible results.

Do not demand detail already settled by repository conventions or the plan.

### 4. Repository alignment

Verify repository facts only where they matter to execution.

Report material mismatches such as:

* referenced files, APIs, commands, or configuration that do not exist and are not introduced by the plan
* assumptions contradicted by relevant existing implementation
* incorrect ownership or integration points
* verification instructions that cannot work as described

Do not turn this check into architecture review or implementation optimization.

### 5. Revision regressions

When the plan has been revised, check affected sections and tasks for inconsistencies involving:

* renamed concepts
* changed ownership
* changed scope
* changed ordering
* removed behavior
* modified acceptance criteria
* modified verification

Report current inconsistency, not revision history.

## Findings Standard

Use only:

* **BLOCKER**: implementation cannot reliably proceed because the plan is materially contradictory, undefined, impossible, or unsafe.
* **IMPORTANT**: likely to cause incorrect or incomplete implementation, invalid verification, or material rework.

Before reporting an IMPORTANT finding, ask:

> Would a competent implementation agent plausibly implement the wrong thing, become blocked, or require substantial rework because of this?

If not, omit it.

Do not report alternative designs, additional edge cases, optional hardening or polish, speculative future requirements, refactoring opportunities, additional abstractions, broader architecture improvements, unnecessary stronger verification or documentation, style or naming improvements, resolved concerns, or issues without material implementation impact.

Group findings by root cause. State the issue, practical impact, and smallest complete fix.

Prefer corrections that preserve intended scope, but do not suppress a material defect when correcting it requires changing scope.

Do not expand the review because few or no findings remain. A clean review is a valid result.

## Verdict

* **READY**: no BLOCKER or IMPORTANT findings remain.
* **NEEDS REVISION**: at least one BLOCKER or IMPORTANT finding remains.

`READY` means the plan is sufficiently coherent for implementation, not that no further improvement is possible.

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

Use the most useful available planlet identifier. Use `unknown` when the planlet identifier or commit SHA is unavailable.

Prefer `file:line` for locations when available. Otherwise use the relevant heading or task identifier.

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
3. is not merely an opportunity to improve the design, and
4. is not already settled by repository reality.

If no finding passes all four conditions, return `READY`.
