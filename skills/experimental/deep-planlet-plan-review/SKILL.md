---
name: deep-planlet-plan-review
description: Deep read-only review of plans before development. Checks whether a fresh agent can implement the plan correctly without material guessing, validates repository alignment, scope, behavior, ownership, acceptance, verification, task coverage, external contracts, and unnecessary complexity.
license: MIT
---

# Deep Planlet Plan Review

## Rules

Read-only review. Do not run commands, edit files, change task state, complete the planlet, modify repository state, or implement changes. Planlet structure is already validated; inspect code only to judge the plan.

Review internally. Do not expose reasoning, scratchpad, process notes, or tool use.

## Objective

Find material planning defects before implementation. Treat this as the last serious plan review.

Primary test:

> Can a fresh implementation agent complete the work correctly from the repository and planlet without making a material design decision or guessing intended behavior?

A plan is underspecified when two reasonable implementations can satisfy it while producing materially different behavior, ownership, failure semantics, compatibility, state, or verification. Simulate at least two such implementations; when they diverge materially, report the missing decision unless repository reality settles it.

Review all applicable dimensions even after `NEEDS REVISION` is clear. Never demand detail already settled by repository reality or authoritative contracts; treat restated detail as possible accidental complexity instead.

## Inputs and Discipline

Inspect as available: in-scope `plan.md` and `tasks.md`, repository instructions and planning guidance, relevant architecture, code, APIs, tests, config, workflows, authoritative dependency, service, or protocol contracts, and the commit SHA.

Treat the in-scope `plan.md` and `tasks.md` supplied or referenced for this review as one implementation handoff:

* `plan.md` owns outcome, scope, exclusions, design decisions, invariants, acceptance, verification, and risks.
* `tasks.md` owns ordered, independently meaningful outcomes. Tasks may repeat small constraints for clarity, but must not become a second detailed specification.

Group findings by root cause: one finding per issue, covering every affected section or task and every contradiction exposed by the smallest complete fix. Normally report 8 or fewer grouped findings, but never omit a material issue to meet the limit.

## Review Checks

### 1. Repository alignment

Verify referenced files, APIs, commands, tests, workflows, config, architecture, ownership, rules, and external contracts exist or are introduced and match repository reality.

Resolve repository-inspectable uncertainty during review. Report only drift affecting implementation, scope, ordering, or verification.

### 2. Scope, behavior, and ownership

Ensure one coherent outcome with clear boundaries. Flag missing prerequisites, unrelated work, future-phase leakage, exclusion conflicts, speculative functionality, or unnecessary scope.

Check consequential behavior: errors, state transitions, precedence, lifecycle, cleanup, persistence, compatibility, defaults, side effects, and trust boundaries.

Ensure responsibilities live in correct layer and reuse existing seams. Flag duplicate authorities, wrong-layer policy, unnecessary coupling or state, temporary architecture, speculative abstractions, and premature future-proofing.

Flag only unresolved decisions that materially affect implementation, not edge cases already settled by repository behavior. Split only genuinely independent outcomes whose combination increases implementation or review risk.

### 3. Acceptance and proof

Acceptance criteria must be observable, objective, complete for key behavior, scope-consistent, and able to reject materially wrong implementations. Ask:

> Could a plausible incorrect implementation satisfy every acceptance criterion?
>
> For each material claim: what observation distinguishes correct behavior from a plausible incorrect implementation?

Verification must observe the invariant at the correct boundary, fail when behavior is wrong, cover material failure paths, handle skips or unavailable dependencies, match platform and CI reality, and avoid brittle or redundant proof. Do not confuse configuration with runtime behavior. Prefer the cheapest sufficient proof at the owning boundary.

### 4. Plan-task coverage

Ensure every required outcome has task ownership, every task contributes, prerequisites precede consumers, and no task depends on excluded work.

Flag catch-all tasks, unrelated bundles, vague completion conditions, unsafe ordering, or detailed duplication of `plan.md`. Compress before splitting; split only when each resulting task is a meaningful delivered outcome.

### 5. External state and contracts

For external or destructive state, require clarity on target, preconditions, ordering, preservation of unrelated state, mutation semantics, repeat behavior, and post-change verification.

For pinned CLIs, SDKs, protocols, services, or dependencies, verify the plan matches that version's contract, including consequential flags, defaults, environment semantics, and provider or network assumptions. Preserve needed contract facts, not copied documentation.

### 6. Conciseness

Both files must be concise and implementation-focused. Flag verbosity, repetition, excessive rationale, or any section or task that can be substantially shortened without losing information needed for correctness, constraints, validation, acceptance, or consequential decisions.

## Plan Judo

Prefer, in order:

1. Remove out-of-scope or speculative work.
2. Reuse existing repository behavior or architecture.
3. State invariants instead of incidental steps.
4. Remove duplicated requirements.
5. Use existing platform or dependency mechanisms.
6. Simplify ownership, state, or verification.
7. Split genuinely independent outcomes.
8. Add only the smallest necessary abstraction.

Keep complexity required by correctness or explicit requirements.

## Findings Standard

Use only:

* **BLOCKER**: implementation cannot reliably proceed, or the plan permits materially unsafe, destructive, contradictory, or undefined behavior.
* **IMPORTANT**: likely to cause incorrect or incomplete implementation, invalid verification, avoidable rework, material over-engineering, or another review round.

Do not report suggestions, style preferences, optional polish, speculative future-proofing, unrelated cleanup, or redesign just because another design is possible.

Each finding must state the issue, practical impact, and smallest complete fix.

## Verdict

* **READY**: no BLOCKER or IMPORTANT findings remain, meaning implementation can begin without material guessing.
* **NEEDS REVISION**: at least one BLOCKER or IMPORTANT finding exists.

## Output

Prefer this standard summary block when presenting the review:

```text
Verdict: READY | NEEDS REVISION
Reviewed: <plan-identifier> @ <commit-sha>
Requested revisions

1. [SEVERITY] <location> - issue
   Why: practical impact
   Fix: smallest complete correction
```

Use most useful available planlet slug and `unknown` when slug or commit SHA is unavailable.

`<location>` should be `file:line` when available. Otherwise use most stable available source location, such as file section, task identifier, heading, or supplied-plan reference.

If no findings, use:

```text
Verdict: READY
Reviewed: <plan-identifier> @ <commit-sha>
Requested revisions

- None.
```

## Final Check

Confirm all applicable checks completed, review continued past first finding, fresh-agent simulation and proof challenge were performed, findings are grouped by root cause, no finding asks for repository-obvious detail or unnecessary scope, and output follows exact `Output` contract. No commands executed.
