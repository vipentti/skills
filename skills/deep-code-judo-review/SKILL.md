---
name: deep-code-judo-review
description: Perform a deep, exhaustive code-quality review focused on finding all material issues before the next fix round. Inspect the full change and relevant surrounding code for correctness, maintainability, structural simplicity, missed reuse, weak contracts, unnecessary state, over-engineering, and high-value simplifications. Prefer complete material coverage with concise, actionable findings grouped by root cause.
source:
  - https://github.com/cursor/plugins/tree/main/cursor-team-kit/skills/thermo-nuclear-code-quality-review
  - https://github.com/DietrichGebert/ponytail
license: MIT; derived from Cursor cursor-team-kit and DietrichGebert/ponytail
---

# Deep Code Judo Review

* Never use em dashes or en dashes. Use commas, colons, semicolons, or hyphens (-).

## Final Response Contract

This section overrides all other instructions.

Perform review internally. Do not expose reasoning, scratchpad, process notes, chain-of-thought, or tool use.

Return exactly:

1. One fenced code block containing full review in format under `Output`.
2. Exact text `Review ready` immediately after.

Nothing else before or after. Express conclusions only through defined review sections.

## Objective

Identify all material issues before next fix round. Optimize for complete coverage, not short review. Do not stop after enough findings for `Request changes`; cover full relevant change surface.

Findings must be specific, evidence-based, and useful. Do not manufacture them.

Prefer simplest maintainable solution, not fewest lines. Apply **code judo**: remove unnecessary branches, state, wrappers, config, abstractions, duplication, and mechanisms. Prefer deletion over addition.

## Review Depth

Review complete change plus enough surrounding code to judge it correctly. Never judge diff in isolation.

Always inspect the full diff and materially changed files.

Where relevant:

* Follow callers, consumers, call paths, and cross-module interactions.
* Inspect related types, config, tests, state, helpers, and repository patterns.
* Check for existing equivalent functionality.
* Inspect failure paths, edge cases, lifecycle, compatibility, and external effects.
* Judge whether tests prove behavior, not only happy paths.

Focus on highest behavioral, state, ownership, contract, and complexity risk. Avoid unrelated areas unless material.

## Review Standard

Evaluate all applicable dimensions.

### Correctness

Look for wrong behavior, missed edge cases, broken assumptions, incomplete handling, ordering bugs, invalid transitions, partial updates, bad lifecycle, and inconsistent failure state.

### Tests

Look for missing behavioral, negative, failure, or regression coverage; implementation-coupled tests; tests that fail to prove intended behavior; duplicated setup.

Request tests only when they materially improve confidence.

### Types and Contracts

Look for unsafe casts, `any`, weak contracts, unnecessary optionality, runtime checks replacing static guarantees, invalid states representable by types, duplicate representations, and over-flexible APIs.

### State and Branching

Look for excessive flags, booleans encoding one state machine, stored derived state, removable branches, flexible condition chains, unclear ownership, and inconsistent updates.

### Ownership

Look for wrong-layer logic, scattered feature behavior, callers owning owner-level behavior, low-level modules knowing policy, utility modules gaining domain behavior, and unclear responsibility growth.

### Reuse

Look for existing helpers, abstractions, or patterns that should replace new code, plus duplicate validation, parsing, normalization, formatting, or state handling.

### Native Solutions

Prefer simpler sufficient native options:

1. Language or standard library
2. Platform
3. Framework
4. Existing dependencies

### Abstraction Quality

Look for rename-only wrappers, one-use abstractions, unjustified interfaces or factories, single-use generic helpers, speculative extensibility, unnecessary config, and costly indirection.

### Coupling

Look for new cross-module dependencies, hidden coordination, shared mutable state, bidirectional knowledge, API leaks, and changes increasing future touch points.

### Complexity

Look for over-engineering, unnecessary flexibility, excess config, avoidable state or branches, pointless indirection, duplicate mechanisms, and handling for unrequired scenarios.

### Security and Data Integrity

When applicable, look for bad trust-boundary validation, authorization assumptions, secret handling, integrity races, partial writes, lossy transforms, rollback/cleanup, and insecure defaults.

Do not remove complexity required for security, integrity, concurrency, compatibility, or correctness.

## Simplification Ladder

Prefer fixes in this order:

1. Delete unnecessary code
2. Reuse existing code
3. Use language or standard library
4. Use platform or framework
5. Use existing dependencies
6. Simplify model or state
7. Add smallest necessary abstraction

Do not trade clarity for fewer lines.

## Presumptive Problems

Treat as inspection signals, not automatic defects:

* New abstractions, wrappers, config, dependencies, flags, modes, state, APIs, helpers, or interfaces
* Duplicate logic or feature logic spread across layers
* Runtime type checks or unsafe casts
* Responsibility growth in complex modules
* Multiple independently updated representations of same state

Each addition must earn its complexity.

## Deep Review Discipline

Be strict and evidence-based. Passing behavior alone is insufficient.

Review dimensions independently. Existing findings do not define scope.

Do not stop once enough findings exist to justify `Request changes`.

Assume this is the last review before merge: surface independent material issues now rather than deferring them to later rounds.

Group by root cause. Exclude cosmetic, naming, formatting, style-only, and speculative redesign feedback. Prefer deletion, reuse, or state simplification over large redesign.

Each finding must:

* Identify concrete issue
* Explain practical impact
* Give simpler or safer direction
* Be actionable without exposing reasoning

Do not apply fixes unless asked. Do not describe process or mention tool use in output.

## Do Not Oversimplify

Keep complexity required for correctness, security, integrity, concurrency, error handling, lifecycle, compatibility, or explicit requirements.

Code judo removes accidental complexity only.

## Output

Inside code block, start with one verdict:

**Review approved**, **Review approved with suggestions**,
**Request changes**, or **Needs discussion**

Then, in order:

1. Reviewed
2. Requested changes
3. Approved items
4. Open questions, only for `Needs discussion`
5. Code judo, optional

No extra sections or commentary.

### Reviewed

State exactly what was reviewed.

Example: `Reviewed: PR #123 @ <sha>`

### Requested changes

Report all material findings. Normally use 8 or fewer by grouping root causes. Exceed 8 for additional independent material issues. Never omit one only to meet limit.

If there are no requested changes:

* None

Format:

```
1. [Severity] [tag] file:line - issue
   Why: impact
   Fix: direction
```

Example:

```
1. [Major] [yagni] src/store.ts:42 - Generic provider interface has one implementation.
   Why: It adds another contract and indirection without reducing complexity.
   Fix: Use the concrete store directly until a second implementation requires abstraction.
```

Severity:

* `Blocker`: prevents safe merge
* `Major`: material issue that should be fixed before merge
* `Suggestion`: meaningful improvement that need not block merge

### Approved items

Briefly list accepted decisions. If none are worth calling out:

* No specific approved items

Do not repeat requested changes.

### Open questions

Only genuine design decisions unresolved by implementation or requirements. Repository-inspectable uncertainty does not qualify.

### Code judo

Optionally include one high-impact root-cause simplification reducing code, state, branching, coupling, or abstraction. Omit if none.

## Final Check

Before returning, ensure:

* Relevant change surface fully considered
* Findings material, evidence-based, grouped by root cause
* No material issue omitted for finding limit
* Necessary complexity not criticized merely for existing
* Deletion, reuse, native solutions, and state/model simplification considered
* One code block, correct structure, no reasoning or process text
* No em dashes or en dashes
* Only `Review ready` appears outside code block
