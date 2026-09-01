---
name: deep-code-judo-review
description: Perform an unusually strict code-quality and maintainability review of a supplied diff, commit range, branch, or pull request, focused on code-judo simplification: deleting accidental complexity, reducing state and branching, improving ownership and boundaries, reusing canonical code, and tightening abstractions and contracts. Use when explicitly asked for code judo, a deep code-quality audit, a thermonuclear-style review, or an especially rigorous maintainability review. Do not use for routine code review, plan review, or implementation.
source:
- https://github.com/cursor/plugins/tree/main/cursor-team-kit/skills/thermo-nuclear-code-quality-review
- https://github.com/DietrichGebert/ponytail
license: MIT; derived from Cursor cursor-team-kit and DietrichGebert/ponytail
---

# Deep Code Judo Review

## Final Response Contract

If sections of this skill conflict about output, this contract controls.

Perform review internally. Do not expose reasoning, scratchpad, process notes, chain-of-thought, or tool use.

Return exactly:

1. One fenced code block containing full review in format under `Output`.
2. Exact text `Review ready` immediately after.

Nothing else before or after.

## Objective

Find material implementation-quality problems and high-value simplifications in reviewed change.

Apply **code judo**: reduce accidental complexity while preserving required behavior. Prefer deletion, reuse, simpler state, clearer ownership, and direct code over additional mechanisms or abstractions.

Findings must be specific, evidence-based, actionable, and tied to reviewed change. Do not manufacture findings.

## Scope

Review supplied diff, commit range, branch, or pull request plus enough surrounding code to judge changed behavior correctly.

Always inspect complete change and materially changed files.

Surrounding code is evidence, not independent review scope. Report a pre-existing issue only when change makes it materially worse, newly reachable, newly relied upon, or otherwise directly relevant.

Do not turn review into repository-wide cleanup.

Where relevant:

* Follow changed callers, consumers, call paths, and cross-module interactions.
* Inspect related types, config, tests, state, helpers, and repository patterns.
* Check for existing equivalent or canonical functionality.
* Inspect failure paths, lifecycle, compatibility, and external effects.
* Judge whether changed or added tests prove intended behavior.

## Static Review

This is a read-only review.

Do not run tests, builds, linters, formatters, type checkers, static analyzers, benchmarks, coverage tools, application binaries, or integration environments.

Do not modify files, install dependencies, apply fixes, or otherwise change repository state.

Read-only file, diff, history, search, and repository inspection is allowed.

## Review Standard

Evaluate applicable dimensions, prioritizing structural simplification and maintainability.

### Simplification

Look for implementations that can remove concepts, branches, helpers, modes, wrappers, configuration, indirection, or duplicate mechanisms.

Prefer fixes in this order:

1. Delete unnecessary code or mechanisms
2. Reuse canonical existing code
3. Use language or standard library
4. Use platform or framework
5. Use existing dependencies
6. Simplify model or state
7. Add smallest necessary abstraction

Prefer simplest maintainable solution, not fewest lines.

### State and Control Flow

Look for:

* Excessive flags or booleans encoding one state machine
* Stored derived state
* Independently updated representations of same state
* Removable branches and special cases
* Unclear transitions or lifecycle
* Partial or inconsistent updates
* Unnecessary sequential orchestration

Prefer models that make invalid or unnecessary states impossible instead of adding conditionals around them.

### Ownership and Boundaries

Look for:

* Logic in wrong layer or module
* Feature behavior scattered across unrelated paths
* Callers owning behavior belonging to callee or domain owner
* Low-level modules knowing policy they should not own
* Generic utilities accumulating domain behavior
* New dependencies or coordination between otherwise independent components
* API details leaking across boundaries

Move behavior toward module that naturally owns concept.

### Reuse

Look for duplicate validation, parsing, normalization, formatting, state handling, orchestration, or other functionality already provided by repository.

Prefer canonical repository mechanisms over near-duplicates.

### Abstractions and Contracts

Look for:

* Rename-only or pass-through wrappers
* One-use abstractions without a clear boundary benefit
* Unjustified interfaces, factories, or generic helpers
* Speculative extensibility or unnecessary configuration
* Unsafe casts or weakly shaped data
* Unnecessary optionality
* Runtime checks replacing clear static contracts
* APIs flexible beyond actual requirements

Each abstraction and extension point must earn its complexity.

### Coupling and Complexity

Look for:

* Hidden coordination
* Shared mutable state
* Bidirectional knowledge
* Increasing future touch points
* Ad-hoc branches added to already busy flows
* Multiple mechanisms solving same problem
* Handling for scenarios requirements do not demand

Prefer deleting complexity over redistributing it.

### Tests

Inspect tests when relevant to changed behavior.

Look for:

* Missing behavioral, negative, failure, or regression coverage where confidence materially depends on it
* Tests coupled to implementation rather than behavior
* Tests that do not prove intended contract
* Test structure reflecting or reinforcing unnecessary production complexity

Request additional tests only when they materially improve confidence.

### Correctness, Security, and Integrity

Do not ignore material correctness, security, data-integrity, lifecycle, concurrency, or compatibility problems encountered during review.

Code-judo simplification must not remove complexity required for:

* Correct behavior
* Trust-boundary validation
* Authorization
* Atomicity and integrity
* Concurrency
* Cleanup or rollback
* Lifecycle requirements
* Compatibility
* Explicit product requirements

## Inspection Signals

Treat these as reasons to inspect closely, not automatic defects:

* New abstractions, wrappers, configuration, dependencies, flags, modes, APIs, helpers, or interfaces
* New state or duplicate representations
* Special-case branching
* Feature logic spread across layers
* Runtime type checks or unsafe casts
* Responsibility growth in already complex modules
* Bespoke functionality resembling existing repository mechanisms

Judge practical complexity and maintenance cost, not mere existence.

## Review Discipline

Be strict and evidence-based.

Do not stop after finding enough issues to justify `Request changes`. Cover complete relevant change surface and surface independent material issues in same review.

Group findings by root cause. Do not split one design problem into many symptoms.

Exclude cosmetic, naming, formatting, style-only, and speculative redesign feedback.

Each finding must:

* Identify concrete issue
* Explain practical impact
* Give simpler or safer direction
* Be introduced, exposed, or materially affected by reviewed change

Do not apply fixes unless explicitly asked.

## Output

Inside code block, start with one verdict:

**Review approved**, **Review approved with suggestions**,
**Request changes**, or **Needs discussion**

Choose verdict as follows:

* `Review approved`: no material findings
* `Review approved with suggestions`: only non-blocking `Suggestion` findings
* `Request changes`: one or more definite `Major` or `Blocker` findings
* `Needs discussion`: no definite blocking defect is established, but an unresolved requirement or design decision prevents approval

Then, in order:

1. Reviewed
2. Requested changes
3. Approved items
4. Open questions, when applicable
5. Code judo, optional

No extra sections or commentary.

### Reviewed

State exactly what was reviewed.

Example: `Reviewed: PR #123 @ <sha>`

### Requested changes

Report all material findings, grouped by root cause. Never omit material issue to satisfy numeric limit.

If there are no findings:

* None

Format:

```text
1. [Severity] [tag] file:line - issue
   Why: impact
   Fix: direction
```

Severity:

* `Blocker`: prevents safe merge
* `Major`: material issue that should be fixed before merge
* `Suggestion`: meaningful improvement that need not block merge

### Approved items

Briefly list accepted decisions worth preserving.

If none:

* No specific approved items

Do not repeat findings.

### Open questions

Include only genuine requirement or design questions that repository inspection cannot resolve.

Do not use questions as substitutes for findings when evidence already establishes a problem.

Omit section when none.

### Code judo

Optionally include one high-impact root-cause simplification that substantially reduces code, state, branching, coupling, or abstraction.

Omit if none.

## Final Check

Before returning, ensure:

* Complete relevant change surface reviewed
* Findings tied to introduced, exposed, or materially affected behavior
* Surrounding code used as evidence rather than independent scope
* No validation commands or repository mutations performed
* Findings material, evidence-based, and grouped by root cause
* No material issue omitted because review already blocks
* Necessary complexity preserved
* Deletion, reuse, native solutions, and model or state simplification considered
* Verdict matches findings
* One code block, correct structure, no reasoning or process text
* No em dashes or en dashes
* Only `Review ready` appears outside code block
