---
name: code-judo-review
description: Perform a strict code-quality review focused on maintainability, structural simplicity, and over-engineering. Find concrete problems, unnecessary complexity, missed reuse, speculative abstractions, and high-value simplifications. Prefer a small number of concise, actionable findings with reasoning.
disable-model-invocation: true
source:
  - https://github.com/cursor/plugins/tree/main/cursor-team-kit/skills/thermo-nuclear-code-quality-review
  - https://github.com/DietrichGebert/ponytail
license: MIT; derived from Cursor cursor-team-kit and DietrichGebert/ponytail
---

# Code Judo Review

Perform a strict review of the changed implementation and the surrounding code needed to understand it.

The goal is not maximum criticism or minimum line count. The goal is the simplest maintainable implementation that correctly fits the existing system.

Actively look for **code judo**: a different framing that makes branches, states, wrappers, helpers, dependencies, modes, or entire abstractions unnecessary.

Prefer deleting complexity over reorganizing it.

## Review Standard

Evaluate material changes for:

- **Over-engineering:** speculative flexibility, one-use abstractions, unnecessary wrappers, configuration nobody needs, premature generalization, or scaffolding for hypothetical future work.
- **Missed simplification:** behavior that could be expressed with substantially fewer concepts, branches, states, layers, or moving parts.
- **Missed reuse:** new code duplicating an existing canonical helper, type, contract, or pattern.
- **Stdlib/native solutions:** custom code or dependencies replacing functionality already provided by the language, platform, framework, database, or runtime.
- **Abstraction quality:** interfaces, factories, generic mechanisms, helpers, or layers that add indirection without reducing complexity.
- **Ownership:** logic living outside the module, service, package, component, or layer that naturally owns it.
- **State and branching:** flags, nullable modes, condition chains, special cases, or partially overlapping states indicating a poor model.
- **Type boundaries:** casts, `any`, `unknown`, excessive optionality, or loose objects hiding the real contract.
- **Coupling and readability:** changes that increase statefulness, file sprawl, sequencing constraints, or the amount of context required to reason about the code.
- **Consistency and atomicity:** related operations that can become partially applied or inconsistent when a simpler coherent operation is practical.

Correct behavior and passing tests do not justify unnecessary structural complexity.

## Simplification Ladder

When complexity appears, prefer the first option that fully solves the real problem:

1. Delete it if it does not need to exist.
2. Reuse something already present in the codebase.
3. Use the language or standard library.
4. Use a native platform, framework, database, or runtime feature.
5. Reuse an already-installed dependency.
6. Simplify the state, data model, or ownership so less code is necessary.
7. Only then introduce the minimum new abstraction or custom implementation required.

Do not optimize for line count at the expense of clarity, correctness, or maintainability.

## Presumptive Problems

Raise a material finding when the change:

- creates a clear maintainability or structural regression;
- introduces substantial incidental complexity that a practical restructuring would remove;
- adds speculative abstractions, unused flexibility, unnecessary configuration, or premature extensibility;
- reimplements functionality already available locally, in the standard library, or natively;
- adds a dependency for functionality that is already readily available;
- scatters feature-specific checks through shared or unrelated paths;
- adds branches or states to an already tangled flow instead of simplifying the model;
- places logic in the wrong architectural layer or duplicates a canonical implementation;
- adds wrappers or abstraction layers whose existence does not simplify callers or ownership;
- obscures contracts through casts, loose types, or unnecessary optionality;
- allows related state to become partially updated when a practical atomic structure exists;
- substantially enlarges an already difficult-to-navigate module rather than creating a clearer boundary.

Treat these as evidence requiring judgment, not mechanical rules.

## Do Not Oversimplify

Do not recommend removing complexity that materially protects:

- correctness at real edge cases;
- trust-boundary validation;
- security controls;
- data integrity or loss prevention;
- necessary error handling;
- concurrency correctness;
- accessibility;
- required compatibility;
- useful tests for non-trivial behavior.

"Less code" is not a valid recommendation if it merely hides necessary complexity or moves it somewhere worse.

## Review Discipline

Be strict but evidence-based.

Inspect enough surrounding code to verify ownership, reuse opportunities, callers, and existing patterns before making a finding.

Prioritize high-confidence problems that would materially improve the implementation. Do not manufacture issues, list cosmetic nits, or propose theoretical redesigns with marginal benefit.

A finding should explain both **why the current approach is costly** and **what simpler direction should replace it**.

Do not apply fixes unless explicitly asked.

## Output

Start with exactly one verdict:

**Approve**, **Request changes**, or **Needs discussion**

The output must then include, in order: a Reviewed line, a Requested changes section, and an Approved items section. Under **Needs discussion**, follow these with an Open questions section. Optionally finish with a Code judo line. Do not add a summary that repeats the findings.

### Reviewed

Identify exactly what was reviewed. For a GitHub pull request, include the pull request number and the exact head commit SHA of the reviewed revision, in compact form:

`Reviewed: PR #123 @ 1a2b3c4d5e6f7890abcdef1234567890abcdef12`

Use the PR head commit actually reviewed, never a synthetic or test merge commit; a PR may gain commits after a review, so the reader must be able to tell exactly which revision was covered. If the commit SHA cannot reasonably be determined, state explicitly that it is unavailable rather than guessing. For non-PR reviews, no PR number is required; include a commit SHA when the reviewed revision can reasonably be determined.

### Requested changes

List every material change the review is actually requesting, highest priority first. Do not leave requested work implicit in prose or require the implementing agent to infer it from reasoning; each entry carries the reasoning and fix direction.

Use one compact entry per finding:

`- [Severity] [tag] file:line - Problem. Why it matters. Fix: direction.`

Default to at most **5 findings**. Exceed this only when additional independent Blocker or Major findings materially affect the review.

Severity:

`Blocker` - should not merge as implemented.  
`Major` - substantial maintainability or complexity problem worth fixing.  
`Suggestion` - worthwhile lower-priority change that should be addressed, but is not independently merge-blocking.

Anything listed under **Requested changes** is expected to be addressed. `Suggestion` means lower-priority requested work, not optional advice.

Useful tags include:

`judo`, `yagni`, `delete`, `reuse`, `stdlib`, `native`, `dependency`, `shrink`, `ownership`, `abstraction`, `state`, `types`, `atomicity`.

Do not create findings merely to use every category.

Example entry:

`- [Major] [yagni] src/store.ts:42 - Generic provider interface has one implementation and no demonstrated extension point. It adds another contract and indirection without reducing complexity. Fix: use the concrete store directly until a second implementation requires abstraction.`

If no changes are requested under the chosen verdict, write `- None.`: an approval explicitly states that no changes are requested. Under **Needs discussion**, list only items that actually require a code change; questions and decisions belong in Open questions.

### Approved items

List the material items that were checked and accepted, concise and limited to meaningful aspects of the reviewed change. Do not manufacture an exhaustive checklist to make the approval look substantial. If there are no meaningful approved items to record, write `- None.` rather than inventing items. If no material problems were found, record that concisely, e.g. `- No material maintainability or over-engineering issues found in the reviewed changes.`

When prior review feedback is available in the review context, verify previously requested changes against the reviewed revision and report resolved ones here as approved rather than raising them again. The Reviewed line lets a later review of a follow-up commit distinguish the previously reviewed revision from subsequent commits.

### Open questions

Only under **Needs discussion**: list questions and decisions that require discussion but no code change, so an implementing agent never mistakes a discussion item for a requested change.

### Code judo

When one restructuring would eliminate a disproportionate amount of complexity, finish with:

`Code judo: <single highest-value simplification>.`

Omit this line when there is no substantial judo opportunity.
