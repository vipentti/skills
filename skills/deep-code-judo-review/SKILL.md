---
name: deep-code-judo-review
description: Perform unusually strict, exhaustive code-quality review of a diff, commit range, branch, or pull request. Focus on code-judo simplification, removing accidental complexity, state, branching, abstractions, duplication, and weak ownership while preserving required behavior. Use for code judo, deep code-quality audit, thermonuclear-style review, or especially rigorous maintainability review.
source:
  - https://github.com/cursor/plugins/tree/main/cursor-team-kit/skills/thermo-nuclear-code-quality-review
  - https://github.com/DietrichGebert/ponytail
license: MIT; derived from Cursor cursor-team-kit and DietrichGebert/ponytail
---

# Deep Code Judo Review

## Rules

Perform static, read-only review.

Do not:

* Run tests, builds, linters, formatters, type checkers, static analyzers, benchmarks, coverage tools, binaries, or integration environments.
* Modify source, install dependencies, apply fixes, or otherwise change repository state. Writing review output to caller-specified destination is allowed.
* Expose scratchpad, chain-of-thought, or internal review process.

Read-only diff, file, history, search, and repository inspection is allowed.

## Scope

Review supplied diff, commit range, branch, or pull request. Find all material implementation-quality issues introduced by or materially affected by change.

Establish intended behavior from supplied request and available PR, commit, issue, requirement, and repository context. Do not invent requirements.

Inspect surrounding code only as evidence needed to understand contracts, ownership, call paths, state, and existing solutions.

Do not report unrelated pre-existing debt, cosmetic or style-only feedback, or speculative redesign. Existing issues are in scope only when materially worsened, newly reachable, newly relied upon, or directly relevant.

Resolve repository-inspectable uncertainty before reporting it. If required evidence cannot be inspected, use `Review incomplete` and identify what is missing.

## Review

Review exhaustively by default. Inspect complete supplied change and materially changed files. Do not stop after enough findings exist for `Request changes`.

For every meaningful change, actively ask whether a **code-judo move** can preserve required behavior while deleting or substantially simplifying code, state, branching, coupling, ownership, or abstractions. Passing behavior alone is insufficient when implementation adds avoidable structural complexity.

Where relevant:

* Follow changed call paths and cross-module effects.
* Inspect related types, config, tests, state, helpers, dependencies, and patterns.
* Check failure paths, edge cases, lifecycle, compatibility, concurrency, security, integrity, and external effects.
* Check whether existing repository or native mechanisms should replace new machinery.
* Judge whether changed or added tests prove intended behavior.
* Inspect resulting responsibility and complexity growth.

Request additional tests only when they materially improve confidence.

## Code Judo Standard

Prefer fixes in this order:

1. Delete unnecessary code or mechanisms
2. Reuse canonical existing code
3. Use language, standard library, platform, or framework
4. Use existing dependencies
5. Simplify model, state, or ownership
6. Add smallest necessary abstraction

Prefer conceptual simplification, not fewer lines.

Look especially for:

* Branches, modes, flags, wrappers, helpers, config, or layers that can disappear
* Special cases that can become part of simpler default flow
* Duplicate state, sources of truth, or mechanisms
* Refactors that move complexity without reducing it
* Feature logic scattered through unrelated paths or wrong layers
* State models that require defensive conditionals
* Thin, one-use, speculative, generic, or pass-through abstractions
* Weak contracts, unnecessary optionality, unsafe casts, or runtime checks replacing static guarantees
* Hidden coordination, shared mutable state, unnecessary dependencies, or growing future touch points
* Bespoke logic duplicating canonical repository functionality

New abstractions, config, flags, APIs, helpers, dependencies, and extension points are inspection signals, not automatic defects. Each must earn its complexity.

Prefer canonical ownership over coordination around misplaced behavior. Prefer models that make invalid or unnecessary states impossible over repeated checks.

Challenge structural growth that adds concepts without improving cohesion or ownership. Extract coherent responsibilities when that reduces coupling or complexity, not merely file length.

Do not trade correctness, security, integrity, compatibility, concurrency, lifecycle requirements, explicit behavior, or clarity for simplification. Required complexity is not code-judo waste.

## Findings

Be strict, evidence-based, ambitious, and complete. Group symptoms sharing one root cause and keep independent issues separate.

Prioritize:

1. Structural regressions and wrong ownership
2. High-impact code-judo simplifications
3. State and branching complexity
4. Weak abstractions, contracts, reuse, or coupling
5. Other material maintainability issues

Each finding must identify concrete issue, practical impact, smallest complete fix direction, and relation to change.

Prefer changed-line locations. Never invent line numbers. Use stable file, range, symbol, or section when needed.

Do not manufacture findings. Approve direct, well-structured implementations. Do not apply fixes unless asked.

## Severity

Use:

* `Blocker`: prevents safe merge because behavior is materially unsafe, destructive, unusable, or cannot satisfy required contract.
* `Major`: material correctness, security, compatibility, state, contract, structural, ownership, or maintainability issue that should be fixed before merge.
* `Suggestion`: meaningful non-blocking improvement.

Substantial accidental complexity may be `Major` even when behavior works if it materially worsens maintainability, ownership, state complexity, or future change cost.

Do not report style-only or speculative suggestions.

## Verdict

Use exactly one verdict:

* **Review approved**: no findings remain.
* **Review approved with suggestions**: only `Suggestion` findings remain.
* **Request changes**: at least one `Blocker` or `Major` finding exists.
* **Needs discussion**: unresolved requirement or design decision prevents determining correct structure or behavior.
* **Review incomplete**: required change data or evidence could not be inspected safely.

When both required changes and open questions exist, use **Request changes**.

Prefer this standard output format:

```text
Verdict: <Review approved | Review approved with suggestions | Request changes | Needs discussion | Review incomplete>
Reviewed: <change identifier>
Findings

1. [SEVERITY] <location> - issue
   Why: practical impact
   Fix: smallest complete correction
```

Additional findings, questions, or caller-required output may follow.

Use most useful identifier for `Reviewed`. Use `file:line` when available, otherwise most stable location.

Caller-provided transport or output contracts take precedence over this presentation format.

## Final Check

Before completing review, ensure:

* Complete supplied change was inspected, or verdict is `Review incomplete`.
* Review actively searched for high-impact code-judo simplifications.
* Findings are material, complete, tied to change, and grouped correctly.
* Reuse and simpler native mechanisms were considered without sacrificing required complexity.
* No validation commands ran and repository state was not modified.
* Verdict and locations are accurate.
