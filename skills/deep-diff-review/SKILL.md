---
name: deep-diff-review
description: Perform deep static review of supplied diff, commit range, branch, or pull request. Find all material issues introduced by or materially affected by change, focusing on correctness, contracts, state, reuse, complexity, security, maintainability, and high-value simplification. Inspect surrounding code only as evidence, keep findings scoped to change, and do not run validation commands.
source:
  - https://github.com/cursor/plugins/tree/main/cursor-team-kit/skills/thermo-nuclear-code-quality-review
  - https://github.com/DietrichGebert/ponytail
license: MIT; derived from Cursor cursor-team-kit and DietrichGebert/ponytail
---

# Deep Diff Review

## Rules

Perform static, read-only review of supplied change and repository state.

Do not:

* Run tests, builds, linters, formatters, type checkers, static analyzers, benchmarks, coverage tools, application binaries, integration environments, or other validation commands.
* Modify reviewed source, install dependencies, apply fixes, or otherwise change repository state. Writing review output to caller-specified destination is allowed.
* Expose scratchpad, chain-of-thought, or internal review process.

Inspect diffs, files, history, searches, and repository structure as needed.

## Scope

Review supplied diff, commit range, branch, or pull request. Identify all material issues introduced by or materially affected by change.

Establish intended behavior from supplied request and available PR, commit, issue, requirement, and repository context. Do not invent requirements.

Inspect surrounding code only as needed to understand contracts and effects. Surrounding code is evidence, not additional review scope.

Do not report:

* Pre-existing issues not materially affected by change
* Unrelated architecture or cleanup problems
* General improvements outside changed behavior
* Cosmetic, naming, formatting, or style-only feedback

Existing issues are in scope only when change makes them materially worse, newly reachable, newly relied upon, or otherwise directly relevant.

Resolve repository-inspectable uncertainty before reporting it.

If required change data or evidence cannot be inspected, use `Review incomplete` and identify what is missing.

## Review

Inspect complete supplied change and materially changed files.

Where relevant:

* Follow changed call paths enough to understand contracts and effects.
* Inspect related types, config, tests, state, helpers, dependencies, and repository patterns.
* Check success, failure, edge cases, lifecycle, compatibility, concurrency, and external effects.
* Check whether behavior matches supplied requirements and established contracts.
* Judge whether changed or added tests prove intended behavior.
* Look for existing functionality or native mechanisms that should be reused instead of duplicated.

Evaluate applicable dimensions:

### Correctness

Wrong behavior, missed edge cases, broken assumptions, ordering bugs, invalid transitions, lifecycle failures, inconsistent failure state, and requirement regressions.

### Tests

Missing behavioral, negative, failure, or regression coverage; implementation-coupled tests; tests that do not prove intended behavior.

Request tests only when they materially improve confidence. Judge tests by inspection only.

### Types and Contracts

Unsafe casts, weak contracts, unnecessary optionality, runtime checks replacing static guarantees, invalid states made representable, duplicate representations, incompatible changes, and over-flexible APIs.

### State and Ownership

Excess flags, stored derived state, unclear ownership, inconsistent updates, duplicate sources of truth, wrong-layer logic, and scattered feature behavior.

### Reuse and Abstraction

Duplicate validation, parsing, normalization, formatting, state handling, or parallel mechanisms when existing helpers, platform mechanisms, language features, standard-library support, or dependencies provide an equally correct and clearer solution.

Look for unnecessary wrappers, one-use abstractions, speculative extensibility, unnecessary config, generic helpers without real reuse, and costly indirection.

Report abstraction concerns only when they create material maintenance, correctness, ownership, or complexity cost.

### Complexity and Coupling

New cross-module dependencies, hidden coordination, shared mutable state, API leaks, unnecessary flexibility, excess configuration, avoidable state or branches, and handling for unrequired scenarios.

Keep complexity required for correctness, security, integrity, concurrency, compatibility, or lifecycle.

### Security and Data Integrity

When applicable, inspect trust-boundary validation, authorization assumptions, secret handling, integrity races, partial writes, lossy transforms, rollback or cleanup, insecure defaults, and destructive behavior.

## Findings

Be strict, evidence-based, and complete. Do not stop after finding enough issues to justify `Request changes`.

Group findings by root cause. Keep independent issues separate.

Each finding must:

* Identify concrete issue
* Explain practical impact
* Give smallest complete fix direction
* Be introduced by, exposed by, or materially relevant to change
* Be actionable without exposing internal reasoning

Prefer changed-line locations when available. Never invent line numbers. Use file, range, section, or multiple locations when needed.

Prefer deletion, reuse, or native mechanisms when at least as correct, clear, and maintainable as new machinery. Never trade correctness, safety, compatibility, required behavior, or clarity for fewer lines.

Do not apply fixes unless asked.

## Severity

Use:

* `Blocker`: prevents safe merge because behavior is materially unsafe, destructive, unusable, or cannot satisfy required contract.
* `Major`: material correctness, security, compatibility, state, contract, or maintainability issue that should be fixed before merge.
* `Suggestion`: meaningful non-blocking improvement.

Do not report style-only or speculative suggestions.

## Verdict

Use exactly one verdict:

* **Review approved**: no findings remain.
* **Review approved with suggestions**: only `Suggestion` findings remain.
* **Request changes**: at least one `Blocker` or `Major` finding exists.
* **Needs discussion**: review is complete, but genuine unresolved requirement or design decision prevents determining correct behavior.
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

* Intended change was established from available context.
* Complete supplied change was inspected, or verdict is `Review incomplete`.
* Findings are material and limited to introduced or materially affected issues.
* Independent issues remain separate and shared root causes are grouped.
* No material issue was omitted.
* No validation commands ran and repository state was not modified.
* Reuse and simplification were considered without sacrificing required complexity.
* Verdict matches severity rules.
* Locations are accurate and no line number was invented.
