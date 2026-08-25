---
name: deep-plan-review
description: Deep read-only review of implementation plans before development. Checks whether a fresh agent can implement the plan correctly without material guessing, validates repository alignment, scope, behavior, ownership, acceptance, verification, task coverage, external contracts, and unnecessary complexity.
license: MIT
---

# Deep Plan Review

## Rules

Read-only review. Do not implement, edit files, change repository state or plan status, perform cleanup, or run builds, tests, linting, formatting, migrations, deployments, or other validation commands. Inspect repository files as needed.

Perform review internally. Do not expose reasoning, scratchpad, process notes, or tool use. Return only one fenced code block in the `Output` format, followed by the exact text `Review ready`.

## Objective

Find material planning issues before implementation.

Primary test:

> Can a fresh competent agent implement intended work correctly using only repository and plan, without making a material design decision or guessing intended behavior?

Plan is underspecified when reasonable implementations can satisfy it while differing materially in consequential behavior, ownership, state, compatibility, security, external effects, or verification. Simulate at least two implementations an unfamiliar competent agent could produce; when they diverge materially, report the missing decision unless repository reality settles it.

Review all applicable dimensions. Do not stop after enough findings exist for `NEEDS REVISION`. Do not require detail already settled by repository conventions, code, architecture, or authoritative contracts; challenge such restatement as possible accidental complexity instead.

## Inputs and Discipline

Inspect as available: plan and tasks, repository instructions, relevant code and architecture, APIs, tests, config, schemas, workflows, external contracts, and current commit SHA.

Treat all plan documents as one implementation handoff, reviewed as implementation contract rather than prose. Require enough detail on outcome, scope, decisions, invariants, acceptance, verification, risks, and ordered outcomes without duplicating repository-obvious facts.

Group findings by root cause: one finding per flaw, covering every affected location, fixed by the smallest complete correction. Normally report 8 or fewer grouped findings, but never omit material issues to meet limit.

## Review Checks

### 1. Repository alignment and scope

Verify referenced repository elements exist and match plan, or are explicitly introduced.

Resolve repository-inspectable uncertainty. Report drift only when it materially affects implementation, behavior, scope, ordering, ownership, compatibility, or verification.

Check for missing prerequisites, unrelated or future work, contradictions, speculation, hidden dependencies, unnecessary compatibility work, or excessive scope. Prefer removal over added detail.

### 2. Behavior, state, and architecture

Ensure consequential behavior is determined clearly enough to implement: success and failure behavior; state, precedence, defaults; lifecycle, cleanup, persistence, retries; compatibility, side effects, concurrency, partial failure; trust, security, and destructive operations.

Flag only missing decisions that could materially change implementation. Prefer observable invariants over procedural instructions.

Check responsibilities live in correct layer and existing seams are reused. Look for duplicate truth, misplaced policy, unnecessary coupling or shared state, parallel mechanisms, unclear ownership, or speculative abstractions. Report architecture issues only when they create material correctness, maintenance, implementation, or review risk.

### 3. Acceptance and verification

Acceptance must be observable, objective, consistent with scope, and strong enough to reject materially incorrect implementations. Ask:

> Could a plausible incorrect implementation satisfy every acceptance criterion?
>
> For each material claim: what observation distinguishes correct behavior from a plausible incorrect implementation?

Verification should observe intended invariant at correct boundary, fail on material errors, cover important failure paths, distinguish configuration from runtime behavior, match supported platforms and CI, and avoid brittle or redundant checks.

Prefer cheapest sufficient proof. One strong observation may prove several requirements.

### 4. Tasks and ordering

Ensure required outcomes have ownership, tasks contribute to plan, prerequisites precede consumers, excluded work is not required, integration is explicit, completion conditions matter, and ordering avoids invalid temporary designs.

Tasks may repeat small constraints but must not become a competing specification. Compress unnecessary detail before splitting. Split only meaningful independent outcomes.

### 5. Compatibility and external contracts

When existing behavior, persisted state, external systems, public interfaces, or destructive operations are affected, ensure boundaries are explicit: state and config, public interfaces, schemas and protocols, callers, preservation of unrelated state, mutation ordering, idempotency, recovery, and post-change verification.

Do not invent compatibility requirements. If compatibility is intentionally broken, make boundary explicit enough to implement and verify safely.

For pinned dependencies or platform features, verify consequential assumptions against version in use, including APIs, flags, defaults, environment semantics, authentication, failures, platform limits, and compatibility. Keep only contract detail needed for deterministic implementation.

## Plan Judo

Prefer:

1. Remove out-of-scope or speculative work.
2. Reuse existing repository behavior or architecture.
3. State invariants instead of incidental steps.
4. Remove duplicated requirements.
5. Use existing platform or dependency mechanisms.
6. Simplify ownership, state, or verification.
7. Split genuinely independent outcomes.
8. Add smallest necessary abstraction.

Keep complexity required for correctness, safety, compatibility, or explicit requirements.

## Findings Standard

Use only:

* **BLOCKER**: implementation cannot reliably proceed, or plan permits materially unsafe, destructive, contradictory, or undefined behavior.
* **IMPORTANT**: likely to cause incorrect or incomplete implementation, invalid verification, avoidable rework, material over-engineering, or another substantive review round.

Do not report style, wording polish, optional improvements, speculative future-proofing, unrelated cleanup, minor edge cases, or alternate design alone.

Each finding must state problem, practical impact, and smallest complete fix.

## Verdict

* **READY**: no BLOCKER or IMPORTANT findings remain, meaning fresh agent can implement without material product, architecture, behavior, or verification decisions.
* **NEEDS REVISION**: at least one BLOCKER or IMPORTANT finding exists.

## Output

Inside one fenced code block:

1. Verdict: **READY** or **NEEDS REVISION**
2. `Reviewed: <plan-identifier> @ <commit-sha>`, using most useful available identifier and `unknown` when unavailable
3. `Requested revisions`

```text
1. [SEVERITY] file:line - issue
   Why: practical impact
   Fix: smallest complete correction
```

If no findings:

```text
- None.
```

## Final Check

Ensure all applicable checks were considered; review continued past first finding; repository-inspectable uncertainty was resolved; fresh-agent simulation was performed; acceptance and verification reject plausible incorrect implementations; root causes were grouped; output is exactly one review code block followed only by `Review ready`.
