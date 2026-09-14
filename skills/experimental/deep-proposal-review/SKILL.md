---
name: deep-proposal-review
description: Deep read-only review of software and architecture proposals before acceptance. Checks problem and value, repository alignment, scope, behavior, architecture, ownership, contracts, compatibility, risks, acceptance evidence, unresolved decisions, and ordered value-delivering vertical slices. Use for proposals, RFCs, and design documents, not implementation plans or code review.
license: MIT
---

# Deep Proposal Review

## Rules

Read-only. Do not edit files, implement, alter proposal status, or change repository state. Inspect repository and authoritative external contracts only to judge the proposal. Do not expose reasoning, scratchpad, process notes, or tool use.

## Objective

Primary test:

> Can this proposal be accepted as direction without implementation later reopening material decisions about outcome, scope, behavior, ownership, architecture, compatibility, failure semantics, or delivery order?

Underspecified: two reasonable interpretations yield materially different scope, behavior, ownership, compatibility, security, migration, operational semantics, or delivery shape. Over-specified: incidental implementation detail unnecessary for acceptance, unsupported by evidence, or better decided during planning and implementation. No proposal is `READY` without an ordered vertical slicing strategy.

## Inputs

Inspect as applicable: proposal, repository, related or competing proposals, authoritative external contracts, and commit SHA. Resolve repository-inspectable uncertainty; do not restate repository-settled facts. Flag unverified claims and assumptions presented as facts when direction depends on them. Open questions only if they cannot change acceptance; resolve or bound those affecting feasibility, scope, architecture, compatibility, security, migration, or required slices. Group findings by root cause; one finding covers all affected sections and consequences.

## Review Checks

Review all applicable checks even after `NEEDS REVISION` is clear.

### 1. Problem and value

Confirm concrete problem or opportunity, affected user or system behavior, and intended outcome. Work must solve that problem, not merely add desired machinery. Challenge existing repository behavior, a smaller change, or narrower scope. Enough motivation to judge tradeoffs; no generic rationale.

### 2. Scope and behavior

Goals and non-goals form a coherent boundary. Check consequential behavior: externally visible behavior, state transitions and persistence, errors and failure handling, defaults and precedence, lifecycle and cleanup, destructive operations, compatibility and migration, side effects and trust boundaries. Flag hidden prerequisites, unrelated work, speculative future scope, or exclusions that contradict the design. No task-level implementation detail.

### 3. Architecture and ownership

Fit repository architecture; reuse existing seams. Check source of truth; state, policy, and configuration ownership; dependency direction; request or data flow; extension boundaries; interaction with existing abstractions. Flag duplicate authorities, parallel infrastructure, wrong-layer policy, unnecessary state, temporary architecture presented as final, or abstractions justified only by hypothetical future needs. Module or type shapes stay flexible unless they change accepted architecture or contract.

### 4. Repository and contract alignment

Referenced modules, APIs, configuration, commands, storage, workflows, tests, and architectural assumptions match repository reality or are explicitly introduced. Verify consequential external API, protocol, dependency, or service claims against authoritative contracts when practical. Distinguish stable contracts from compatibility assumptions or undocumented behavior. Isolate unstable dependencies so likely change does not contaminate generic architecture. No design whose feasibility depends on an unverified external assumption without a concrete validation path.

### 5. Compatibility, safety, and operations

Review: backwards compatibility, persisted data and migrations, concurrent actors, security and secret handling, permissions and trust boundaries, retries and idempotency, resource or cost behavior, rollout and rollback, observability and diagnosis, partial failure and recovery. Detail only where it could change acceptance or architecture. Destructive or externally persisted state needs preservation expectations and failure semantics clear enough to judge safety.

### 6. Decisions and tradeoffs

Material design choices need enough reasoning to show why chosen direction fits constraints. Require alternatives only when another plausible approach materially changes complexity, ownership, compatibility, risk, or scope; no exhaustive alternatives. Flag unsupported major decisions, unresolved alternatives that would produce different architectures, premature commitment where a cheaper reversible choice exists, and generalized infrastructure without demonstrated need. Incidental details stay open.

### 7. Acceptance and proof

Intended success must be observable. Ask:

> What evidence would show this proposal delivered intended value and preserved required behavior?

Acceptance covers important outcomes and architectural invariants, not an implementation task list. Verification targets the correct boundary; configuration existence is not proof of runtime behavior. When mocks cannot prove external compatibility, require a live, integration, migration, interoperability, or operational check.

### 8. Vertical slicing

Suggest implementation order as vertical slices. Each slice: independently observable user, operator, integrator, or developer value, or retire a concrete acceptance-critical risk; coherent working repository state; integrate through relevant layers, not isolated horizontal components; enough acceptance evidence; only its prerequisites; clean path into later slices. Prefer earliest slice proving core value on smallest end-to-end path.

Avoid this horizontal sequence when no usable behavior exists until the final step:

```text
1. add storage
2. add service layer
3. add CLI
4. add tests
```

Infrastructure-only or validation-first slice is acceptable to retire a risk blocking safe value delivery; keep it minimal and name that uncertainty. Later slices must not secretly be required for earlier claimed value. Optional work stays optional; do not bury core correctness, migration, safety, or compatibility in a final hardening slice. Atomic work may be one slice when further splitting would create fake or non-working increments. Never manufacture slices solely to satisfy format.

## Findings

Use only:

* **BLOCKER**: cannot safely accept because direction is contradictory, materially undefined, infeasible, unsafe, or based on an unresolved decision that can change architecture or scope.
* **IMPORTANT**: acceptance would likely cause wrong implementation direction, substantial rework, hidden scope, invalid assumptions, poor delivery sequencing, material over-engineering, or another proposal review round.

Missing vertical slicing prevents `READY`. Do not report style, polish, naming, speculative future-proofing, planning-level detail, or alternate designs just because possible. Each finding: issue, practical impact, and smallest complete proposal change needed.

## Verdict

* **READY**: no BLOCKER or IMPORTANT findings remain. Proposal can be accepted as direction and has a credible ordered vertical delivery strategy.
* **NEEDS REVISION**: at least one BLOCKER or IMPORTANT finding exists.

## Output

```text
Verdict: READY | NEEDS REVISION
Reviewed: <proposal-identifier> @ <commit-sha>
Requested revisions

1. [SEVERITY] <location> - issue
   Why: practical impact
   Fix: smallest complete correction
```

Identifier: most useful available, else `unknown`. Location: `file:line` or stable heading. If no findings, use `- None.` under Requested revisions.
