---
name: deep-diff-review
description: Perform a deep static review of a supplied diff, commit range, branch, or pull request. Find all material issues introduced by or materially affected by the change, focusing on correctness, maintainability, structural simplicity, contracts, state, reuse, complexity, security, and high-value simplifications. Inspect surrounding code only as evidence, keep findings scoped to the change, and never run validation commands.
source:
  - https://github.com/cursor/plugins/tree/main/cursor-team-kit/skills/thermo-nuclear-code-quality-review
  - https://github.com/DietrichGebert/ponytail
license: MIT; derived from Cursor cursor-team-kit and DietrichGebert/ponytail
---

# Deep Diff Review

* Never use em dashes or en dashes. Use commas, colons, semicolons, or hyphens (-).

## Final Response Contract

This section overrides all other instructions.

Perform review internally. Do not expose reasoning, scratchpad, process notes, chain-of-thought, or tool use.

Return exactly:

1. One fenced code block containing the full review in the format under `Output`.
2. Exact text `Review ready` immediately after.

Nothing else before or after.

## Objective

Identify all material issues introduced by or materially affected by the reviewed change. Optimize for complete coverage of the change, not repository-wide review.

Findings must be specific, evidence-based, actionable, and tied to the change.

Prefer the simplest maintainable solution, not the fewest lines. Apply **code judo**: remove unnecessary branches, state, wrappers, config, abstractions, duplication, and mechanisms. Prefer deletion over addition.

## Scope

Review the supplied diff, commit range, branch, or pull request.

Inspect surrounding code only when needed to understand the change. **Surrounding code is evidence, not additional review scope.**

Do not report:

* Pre-existing issues not materially affected by the change
* Unrelated architecture or cleanup problems
* General improvement opportunities outside changed behavior
* Cosmetic, naming, formatting, or style-only feedback

An existing issue is in scope only when the change makes it materially worse, newly reachable, newly relied upon, or otherwise directly relevant.

## No Validation Commands

This is a static review only. Validation execution is the implementer's responsibility.

Do not run tests, builds, linters, formatters, type checkers, static analyzers, benchmarks, coverage tools, application binaries, integration environments, or other validation commands.

Do not modify files, apply fixes, install dependencies, or change repository state.

Read-only inspection is allowed, including diff/history inspection, file reads, searches, and repository navigation.

Judge tests and validation configuration by inspection only. You may report missing, weak, misleading, or insufficient validation, but do not execute it.

## Review Depth

Always inspect the complete supplied diff and materially changed files.

Where relevant to changed behavior:

* Follow changed call paths enough to understand contracts and effects.
* Inspect related types, config, tests, state, helpers, and existing patterns.
* Check whether existing functionality should have been reused.
* Inspect failure paths, edge cases, lifecycle, compatibility, and external effects.
* Judge whether changed or added tests actually prove intended behavior.

Do not expand into an exhaustive review of untouched code.

## Review Standard

Evaluate all applicable dimensions.

### Correctness

Look for wrong behavior, missed edge cases, broken assumptions, incomplete handling, ordering bugs, invalid transitions, lifecycle problems, and inconsistent failure state.

### Tests

Look for missing behavioral, negative, failure, or regression coverage; implementation-coupled tests; and tests that fail to prove intended behavior. Request tests only when they materially improve confidence.

### Types and Contracts

Look for unsafe casts, weak contracts, unnecessary optionality, runtime checks replacing static guarantees, invalid states made representable, duplicate representations, and over-flexible APIs.

### State and Ownership

Look for excessive flags, stored derived state, removable branches, unclear ownership, inconsistent updates, wrong-layer logic, callers taking owner-level responsibility, or feature behavior scattered by the change.

### Reuse and Native Solutions

Look for existing helpers, abstractions, or patterns that should replace new code, plus duplicate validation, parsing, normalization, formatting, or state handling.

Prefer sufficient solutions in this order:

1. Existing code
2. Language or standard library
3. Platform or framework
4. Existing dependencies

### Abstraction Quality

Look for rename-only wrappers, one-use abstractions, unjustified interfaces or factories, speculative extensibility, unnecessary config, generic helpers without real reuse, and costly indirection.

### Coupling and Complexity

Look for new cross-module dependencies, hidden coordination, shared mutable state, API leaks, unnecessary flexibility, excess config, avoidable state or branches, duplicate mechanisms, and handling for unrequired scenarios.

### Security and Data Integrity

When applicable, look for trust-boundary validation gaps, authorization assumptions, secret handling, integrity races, partial writes, lossy transforms, rollback or cleanup problems, and insecure defaults.

Keep complexity required for security, integrity, concurrency, compatibility, lifecycle, or correctness.

## Simplification Ladder

Prefer fixes in this order:

1. Delete unnecessary code
2. Reuse existing code
3. Use language or standard library
4. Use platform or framework
5. Use existing dependencies
6. Simplify model or state
7. Add the smallest necessary abstraction

Do not trade clarity for fewer lines.

## Review Discipline

Be strict and evidence-based. Do not stop once findings justify `Request changes`. Surface all independent material issues within the change.

Group findings by root cause. Prefer deletion, reuse, or state simplification over large redesign.

Each finding must:

* Identify the concrete issue
* Explain practical impact
* Give a simpler or safer direction
* Be introduced by, exposed by, or materially relevant to the change
* Be actionable without exposing reasoning

Do not apply fixes unless asked. Do not describe process or mention tool use in output.

## Output

Inside the code block, start with one verdict:

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

State exactly what change was reviewed.

Example: `Reviewed: PR #123 @ <sha>`

### Requested changes

Report all material findings. Normally use 8 or fewer by grouping root causes. Exceed 8 when needed. Never omit a material issue only to meet the limit.

If none:

* None

Format:

```
1. [Severity] [tag] file:line - issue
   Why: impact
   Fix: direction
```

Severity:

* `Blocker`: prevents safe merge
* `Major`: material issue that should be fixed before merge
* `Suggestion`: meaningful improvement that need not block merge

### Approved items

Briefly list accepted decisions. If none:

* No specific approved items

Do not repeat requested changes.

### Open questions

Only genuine design decisions unresolved by implementation or requirements. Repository-inspectable uncertainty does not qualify.

### Code judo

Optionally include one high-impact root-cause simplification reducing code, state, branching, coupling, or abstraction. Omit if none.

## Final Check

Before returning, ensure:

* Complete supplied change reviewed
* Findings limited to introduced or materially affected issues
* Surrounding code used only as evidence
* No validation commands executed
* Findings material and grouped by root cause
* No material issue omitted for finding limit
* Necessary complexity not criticized merely for existing
* Deletion, reuse, native solutions, and state simplification considered
* One code block, correct structure, no reasoning or process text
* No em dashes or en dashes
* Only `Review ready` appears outside code block
