---
name: deep-diff-review
description: Perform a deep static review of a supplied diff, commit range, branch, or pull request. Find all material issues introduced by or materially affected by the change, focusing on correctness, contracts, state, reuse, complexity, security, maintainability, and high-value simplification. Inspect surrounding code only as evidence, keep findings scoped to the change, and do not run validation commands.
source:
  - https://github.com/cursor/plugins/tree/main/cursor-team-kit/skills/thermo-nuclear-code-quality-review
  - https://github.com/DietrichGebert/ponytail
license: MIT; derived from Cursor cursor-team-kit and DietrichGebert/ponytail
---

# Deep Diff Review

## Rules

Static, read-only review of reviewed source and repository state.

Do not run tests, builds, linters, formatters, type checkers, static analyzers, benchmarks, coverage tools, application binaries, integration environments, or other validation commands.

Do not modify reviewed source files, install dependencies, apply fixes, or otherwise change repository state. Writing review output to a caller-specified destination is allowed.

Inspect files, diffs, history, searches, and repository structure as needed.

Output findings only. Do not include review process, scratchpad, or tool narration.

When the caller supplies an output destination, transport protocol, or response contract, follow it. Otherwise use the `Output` format below and append exact text `Review ready`.

## Objective

Identify all material issues introduced by or materially affected by the reviewed change.

Optimize for complete coverage of the supplied change, not repository-wide review.

Findings must be specific, evidence-based, actionable, and tied to the change.

Prefer deletion, reuse, or native mechanisms when they are at least as correct, clear, and maintainable as adding new machinery. Do not trade clarity, correctness, safety, compatibility, or required behavior for fewer lines.

## Scope

Review the supplied diff, commit range, branch, or pull request.

Establish intended behavior from the supplied request and available PR, commit, issue, requirement, or repository context. Do not invent requirements.

Inspect surrounding code only when needed to understand the change. Surrounding code is evidence, not additional review scope.

Do not report:

* Pre-existing issues not materially affected by the change
* Unrelated architecture or cleanup problems
* General improvement opportunities outside changed behavior
* Cosmetic, naming, formatting, or style-only feedback

An existing issue is in scope only when the change makes it materially worse, newly reachable, newly relied upon, or otherwise directly relevant.

Resolve repository-inspectable uncertainty before reporting it.

## Review Depth

Inspect the complete supplied change and materially changed files.

Where relevant to changed behavior:

* Follow changed call paths enough to understand contracts and effects.
* Inspect related types, config, tests, state, helpers, dependencies, and existing patterns.
* Check whether existing functionality should be reused instead of duplicated.
* Inspect success, failure, edge cases, lifecycle, compatibility, concurrency, and external effects.
* Judge whether changed or added tests actually prove intended behavior.
* Check whether behavior matches supplied requirements and established repository contracts.

Do not expand into an exhaustive review of untouched code.

If required evidence cannot be inspected, do not approve the change. Return `Review incomplete` and identify the missing evidence required to finish review.

## Review Standard

Evaluate all applicable dimensions.

### Correctness

Look for wrong behavior, missed edge cases, broken assumptions, incomplete handling, ordering bugs, invalid transitions, lifecycle problems, inconsistent failure state, and requirement regressions.

### Tests

Look for missing behavioral, negative, failure, or regression coverage; implementation-coupled tests; and tests that fail to prove intended behavior.

Request tests only when they materially improve confidence.

Judge tests by inspection only. Do not execute them.

### Types and Contracts

Look for unsafe casts, weak contracts, unnecessary optionality, runtime checks replacing static guarantees, invalid states made representable, duplicate representations, incompatible contract changes, and over-flexible APIs.

### State and Ownership

Look for excessive flags, stored derived state, removable branches, unclear ownership, inconsistent updates, wrong-layer logic, callers taking owner-level responsibility, duplicate sources of truth, or feature behavior scattered by the change.

### Reuse and Native Solutions

Look for existing helpers, abstractions, platform mechanisms, language features, standard-library support, or existing dependencies that make new code unnecessary.

Flag duplicate validation, parsing, normalization, formatting, state handling, or parallel mechanisms when reuse would be equally correct and clearer.

### Abstraction Quality

Look for rename-only wrappers, one-use abstractions, unjustified interfaces or factories, speculative extensibility, unnecessary config, generic helpers without real reuse, and costly indirection.

Do not criticize an abstraction merely because it is new or small. Report it only when the added mechanism creates material maintenance, correctness, ownership, or complexity cost.

### Coupling and Complexity

Look for new cross-module dependencies, hidden coordination, shared mutable state, API leaks, unnecessary flexibility, excess config, avoidable state or branches, duplicate mechanisms, and handling for unrequired scenarios.

Keep complexity required for correctness, security, integrity, concurrency, compatibility, or lifecycle.

### Security and Data Integrity

When applicable, look for trust-boundary validation gaps, authorization assumptions, secret handling, integrity races, partial writes, lossy transforms, rollback or cleanup problems, insecure defaults, and unsafe destructive behavior.

## Review Discipline

Be strict and evidence-based.

Do not stop after finding enough issues to justify `Request changes`. Surface all independent material issues within the change.

Group findings by root cause. Do not combine independent issues solely to reduce finding count.

Each finding must:

* Identify the concrete issue
* Explain practical impact
* Give the smallest complete fix direction
* Be introduced by, exposed by, or materially relevant to the change
* Be actionable without exposing review process

Prefer changed-line locations when available. Never invent a line number. Use file-only, range, or multiple locations when a single stable line does not represent the issue.

Do not apply fixes unless asked.

## Severity

Use:

* `Blocker`: prevents safe merge because behavior is materially unsafe, destructive, unusable, or cannot satisfy required contract.
* `Major`: material correctness, security, compatibility, state, contract, or maintainability issue that should be fixed before merge.
* `Suggestion`: meaningful non-blocking improvement.

Do not report style-only or speculative suggestions.

## Verdict

Use exactly one:

* **Review approved**: no findings remain.
* **Review approved with suggestions**: only `Suggestion` findings remain.
* **Request changes**: at least one `Blocker` or `Major` finding exists.
* **Needs discussion**: review is complete, but a genuine unresolved requirement or design decision prevents determining correct behavior.
* **Review incomplete**: required change data or evidence could not be inspected, so review cannot be completed safely.

When both required changes and open questions exist, use **Request changes** and include the open questions.

## Output

When no caller-specific output or transport contract exists, return one fenced code block containing:

1. Verdict
2. `Reviewed`
3. `Findings`
4. `Open questions`, only when material
5. `Code judo`, optional

Then append exact text:

`Review ready`

Nothing else outside the code block.

### Reviewed

State exactly what change was reviewed.

Example:

`Reviewed: PR #123 @ <sha>`

If review is incomplete, also state what portion was successfully inspected.

### Findings

Report all material findings.

If none:

```text
- None.
```

Format:

```text
1. [Severity] [tag] file[:line[-line]] - issue
   Why: practical impact
   Fix: smallest complete direction
```

Use multiple locations when needed:

```text
1. [Major] [state] src/a.ts:42-61, src/b.ts:18 - issue
   Why: practical impact
   Fix: smallest complete direction
```

For deleted code, generated files, binary changes, or cases without a meaningful line number, use the best stable file or change location without inventing precision.

### Open questions

Include only genuine unresolved requirements or design decisions whose answer changes material behavior.

Repository-inspectable uncertainty does not qualify.

Open questions may appear with `Needs discussion` or `Request changes`.

### Code judo

Optionally include one high-impact simplification that removes unnecessary code, state, branching, coupling, duplication, or abstraction while preserving required behavior.

Omit if none.

## Final Check

Before returning, ensure:

* Intended change was established from available context.
* Complete supplied change was inspected, or verdict is `Review incomplete`.
* Findings are limited to introduced or materially affected issues.
* Surrounding code was used only as evidence.
* No validation commands were executed.
* No reviewed source or repository state was modified.
* Findings are material, independent issues are preserved, and shared root causes are grouped.
* No material issue was omitted.
* Necessary complexity was not criticized merely for existing.
* Reuse and simplification were considered without overriding correctness or clarity.
* Verdict follows severity rules.
* Locations are accurate and no line number was invented.
* Caller-provided output or transport contract takes precedence over default output formatting.
* Default output, when used, is one review code block followed only by `Review ready`.
* No em dashes or en dashes appear.
