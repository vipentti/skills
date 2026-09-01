---
name: deep-code-judo-review
description: Perform unusually strict, exhaustive code-quality review of a supplied diff, commit range, branch, or pull request. Focus on code-judo simplification: removing accidental complexity, state, branching, wrappers, abstractions, configuration, duplication, and weak ownership while preserving correctness and required behavior. Use when explicitly asked for code judo, deep code-quality audit, thermonuclear-style review, or especially rigorous maintainability review.
source:
- https://github.com/cursor/plugins/tree/main/cursor-team-kit/skills/thermo-nuclear-code-quality-review
- https://github.com/DietrichGebert/ponytail
license: MIT; derived from Cursor cursor-team-kit and DietrichGebert/ponytail
---

# Deep Code Judo Review

## Rules

Perform static, read-only review of supplied change and repository state.

Do not:

* Run tests, builds, linters, formatters, type checkers, static analyzers, benchmarks, coverage tools, application binaries, integration environments, or other validation commands.
* Modify reviewed source, install dependencies, apply fixes, or otherwise change repository state. Writing review output to caller-specified destination is allowed.
* Expose scratchpad, chain-of-thought, or internal review process.

Inspect diffs, files, history, searches, and repository structure as needed.

## Scope

Review supplied diff, commit range, branch, or pull request. Identify all material implementation-quality issues introduced by or materially affected by change.

Establish intended behavior from supplied request and available PR, commit, issue, requirement, and repository context. Do not invent requirements.

Inspect enough surrounding code to understand architecture, ownership, contracts, call paths, state, and existing solutions. Surrounding code is evidence, not independent review scope.

Do not report unrelated pre-existing debt, cosmetic issues, style-only feedback, or speculative redesign.

Existing issues are in scope when change makes them materially worse, newly reachable, newly relied upon, or directly relevant.

Resolve repository-inspectable uncertainty before reporting it.

If required change data or evidence cannot be inspected, use `Review incomplete` and identify what is missing.

## Review

Review exhaustively by default. Inspect complete supplied change and materially changed files. Do not stop after finding enough issues to justify `Request changes`.

For every meaningful change, actively ask whether a **code-judo move** could preserve required behavior while deleting or substantially simplifying code, state, branching, coupling, or abstractions.

Passing behavior is not enough when implementation introduces avoidable structural complexity.

Where relevant:

* Follow changed callers, consumers, call paths, and cross-module effects.
* Inspect related types, config, tests, state, helpers, dependencies, and repository patterns.
* Check success, failure, edge cases, lifecycle, compatibility, concurrency, and external effects.
* Check whether existing functionality or native mechanisms should replace new machinery.
* Judge whether changed or added tests prove intended behavior.
* Inspect resulting responsibility and complexity growth, not only changed lines.

### Code Judo

Prefer solutions that make implementation smaller conceptually, not merely shorter.

Prefer fixes in this order:

1. Delete unnecessary code or mechanisms
2. Reuse canonical existing code
3. Use language or standard library
4. Use platform or framework
5. Use existing dependencies
6. Simplify model, state, or ownership
7. Add smallest necessary abstraction

Look especially for:

* Branches, modes, flags, wrappers, helpers, or layers that can disappear
* Special cases that can become part of simpler default flow
* Refactors that move complexity without reducing it
* Multiple representations or mechanisms for same concept
* Feature logic scattered through unrelated paths
* State models forcing defensive conditionals
* Indirection that makes simple behavior harder to follow

Prefer deletion and reframing over rearranging same complexity.

Do not trade clarity, correctness, security, integrity, compatibility, concurrency, lifecycle requirements, or explicit behavior for fewer lines.

### State and Control Flow

Look for excessive flags, stored derived state, duplicate sources of truth, independently updated representations, removable branches, unclear transitions, partial updates, and unnecessary sequential orchestration.

Prefer models where invalid or unnecessary states cannot arise over code that repeatedly checks for them.

Treat new ad-hoc branches in already complex flows as strong inspection signals.

### Ownership and Boundaries

Look for wrong-layer logic, scattered responsibility, callers owning behavior that belongs to callee or domain owner, low-level modules knowing policy, generic utilities gaining domain behavior, API leaks, and cross-module coordination.

Prefer moving behavior to canonical owner over adding coordination around misplaced behavior.

### Reuse and Native Solutions

Search for existing helpers, abstractions, patterns, platform mechanisms, or dependencies before accepting new machinery.

Look for duplicated validation, parsing, normalization, formatting, state handling, orchestration, and policy.

Prefer canonical repository solutions over near-duplicates.

### Abstractions and Contracts

Look for unnecessary wrappers, one-use abstractions, speculative extensibility, factories or interfaces without meaningful substitution, generic helpers without reuse, excess configuration, unsafe casts, unnecessary optionality, weakly shaped objects, and runtime checks replacing clearer static contracts.

New abstractions, configuration, flags, modes, APIs, and extension points are inspection signals, not automatic defects. Each must earn its complexity.

### Coupling and Structural Growth

Look for hidden coordination, shared mutable state, bidirectional knowledge, unnecessary dependencies, increasing future touch points, mixed responsibilities, and modules becoming materially harder to navigate or change.

Challenge growth that adds concepts without improving ownership or cohesion.

Prefer extracting a coherent responsibility when it reduces coupling or clarifies ownership. Do not split code merely to reduce file length.

### Tests, Correctness, and Safety

Inspect tests where they materially affect confidence. Look for missing behavioral, negative, failure, or regression coverage, implementation-coupled tests, and tests that do not prove intended behavior.

Do not ignore material correctness, contract, security, data-integrity, lifecycle, concurrency, or compatibility issues encountered during review.

Required complexity is not code-judo waste.

## Findings

Be strict, evidence-based, ambitious, and complete.

Do not stop once review already warrants `Request changes`. Surface all independent material issues in current review.

Group symptoms sharing one root cause. Keep genuinely independent problems separate.

Prioritize:

1. Structural regressions and wrong ownership
2. High-impact code-judo simplifications
3. State and branching complexity
4. Weak abstractions or contracts
5. Duplicate mechanisms and missed reuse
6. Coupling and responsibility growth
7. Other material maintainability problems

Each finding must:

* Identify concrete issue
* Explain practical impact
* Give smallest complete fix direction
* Be introduced by, exposed by, or materially relevant to change
* Be actionable without exposing internal reasoning

Prefer changed-line locations when available. Never invent line numbers. Use file, range, symbol, section, or multiple locations when needed.

Do not manufacture findings. If implementation is already direct and well-structured, approve it.

Do not apply fixes unless asked.

## Severity

Use:

* `Blocker`: prevents safe merge because behavior is materially unsafe, destructive, unusable, or cannot satisfy required contract.
* `Major`: material correctness, security, compatibility, state, contract, structural, ownership, or maintainability issue that should be fixed before merge.
* `Suggestion`: meaningful non-blocking improvement.

Do not report style-only or speculative suggestions.

A clear opportunity to remove substantial accidental complexity may be `Major` even when current behavior works, if current design materially worsens maintainability, ownership, state complexity, or future change cost.

## Verdict

Use exactly one verdict:

* **Review approved**: no findings remain.
* **Review approved with suggestions**: only `Suggestion` findings remain.
* **Request changes**: at least one `Blocker` or `Major` finding exists.
* **Needs discussion**: review is complete, but genuine unresolved requirement or design decision prevents determining correct structure or behavior.
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

... additional findings
```

`Reviewed` should use most useful available identifier, such as PR number and commit SHA, branch and SHA, commit range, or supplied diff description.

Additional findings, questions, explanations, or caller-required output may follow in format appropriate to context.

Use `file:line` for `<location>` when available. Otherwise use most stable available source location.

Caller-provided transport or output contracts take precedence over this presentation format.

## Final Check

Before completing review, ensure:

* Complete supplied change was inspected, or verdict is `Review incomplete`.
* Review actively searched for high-impact code-judo simplifications.
* Findings are material and tied to change.
* No material issue was omitted because review already blocks.
* Root causes are grouped and independent issues remain separate.
* Existing reuse and simpler native mechanisms were checked.
* Accidental complexity was challenged without criticizing required complexity.
* No validation commands ran and repository state was not modified.
* Verdict matches severity rules.
* Locations are accurate and no line number was invented.
