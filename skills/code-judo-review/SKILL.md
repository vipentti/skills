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

Review the changed implementation and enough surrounding code to judge it correctly.

The goal is the simplest maintainable implementation that fits the existing system, not maximum criticism or minimum line count. Look for **code judo**: a framing that makes branches, states, wrappers, helpers, dependencies, modes, or abstractions unnecessary. Prefer deletion over reorganization.

## Review Standard

Evaluate material changes for:

- **Over-engineering:** speculative flexibility, one-use abstractions, unnecessary wrappers/configuration, premature generalization, or scaffolding for hypothetical work.
- **Missed simplification:** behavior expressible with substantially fewer concepts, branches, states, layers, or moving parts.
- **Missed reuse:** new code duplicating an existing canonical helper, type, contract, or pattern.
- **Stdlib/native solutions:** custom code or dependencies replacing language, platform, framework, database, or runtime functionality.
- **Abstraction quality:** interfaces, factories, helpers, generic mechanisms, or layers that add indirection without reducing complexity.
- **Ownership:** logic outside the module, service, package, component, or layer that naturally owns it.
- **State and branching:** flags, nullable modes, condition chains, special cases, or overlapping states indicating a poor model.
- **Type boundaries:** casts, `any`, `unknown`, excessive optionality, or loose objects hiding the real contract.
- **Coupling/readability:** increased statefulness, file sprawl, sequencing constraints, or context required to reason about the code.
- **Consistency/atomicity:** related operations that can become partially applied or inconsistent when a coherent operation is practical.

Passing tests do not justify unnecessary structural complexity.

## Simplification Ladder

When complexity appears, prefer the first option that fully solves the real problem:

1. Delete it if unnecessary.
2. Reuse existing code.
3. Use the language or standard library.
4. Use a native platform/framework/database/runtime feature.
5. Reuse an installed dependency.
6. Simplify state, data model, or ownership.
7. Only then add the minimum new abstraction or custom implementation.

Do not reduce line count at the expense of clarity, correctness, or maintainability.

## Presumptive Problems

Raise a material finding when the change:

- creates a clear maintainability or structural regression;
- adds substantial incidental complexity that a practical restructuring would remove;
- adds speculative abstractions, unused flexibility, unnecessary configuration, or premature extensibility;
- reimplements functionality already available locally, in the standard library, or natively;
- adds a dependency for readily available functionality;
- scatters feature-specific checks through shared or unrelated paths;
- adds branches/states to a tangled flow instead of simplifying the model;
- puts logic in the wrong layer or duplicates a canonical implementation;
- adds wrappers/layers that do not simplify callers or ownership;
- obscures contracts with casts, loose types, or unnecessary optionality;
- permits partial related updates when a practical atomic structure exists;
- substantially enlarges an already difficult module instead of creating a clearer boundary.

These are evidence requiring judgment, not mechanical rules.

## Do Not Oversimplify

Do not remove complexity that materially protects correctness, trust boundaries, security, data integrity, error handling, concurrency, accessibility, required compatibility, or useful non-trivial tests.

Less code is not better if it hides necessary complexity or moves it somewhere worse.

## Review Discipline

Be strict and evidence-based. Inspect enough surrounding code to verify ownership, reuse opportunities, callers, and existing patterns.

Prioritize high-confidence, material problems. Do not manufacture issues, list cosmetic nits, or propose theoretical redesigns with marginal value.

Each finding must explain **why the current approach is costly** and **what simpler direction should replace it**.

Do not apply fixes unless explicitly asked.

## Output

Start with exactly one verdict:

**Approve**, **Request changes**, or **Needs discussion**

Then output, in order:

1. `Reviewed`
2. `Requested changes`
3. `Approved items`
4. `Open questions` only for **Needs discussion**
5. optional `Code judo`

Do not add a summary that repeats the findings.

### Reviewed

Identify exactly what was reviewed.

For a GitHub PR:

`Reviewed: PR #123 @ 1a2b3c4d5e6f7890abcdef1234567890abcdef12`

Use the reviewed PR head SHA, never a synthetic/test merge commit. If unavailable, say so rather than guessing. For non-PR reviews, omit the PR number and include a commit SHA when available.

### Requested changes

List every material requested change, highest priority first. Requested work must never be implicit.

Format:

`- [Severity] [tag] file:line - Problem. Why it matters. Fix: direction.`

Default to at most **5 findings**; exceed this only for additional independent Blocker or Major issues.

Severity:

- `Blocker` - should not merge as implemented.
- `Major` - substantial maintainability or complexity problem worth fixing.
- `Suggestion` - lower-priority change that should be addressed but is not a substantial problem on its own.

Anything listed here is expected to be addressed. `Suggestion` is lower priority, not optional advice.

Useful tags: `judo`, `yagni`, `delete`, `reuse`, `stdlib`, `native`, `dependency`, `shrink`, `ownership`, `abstraction`, `state`, `types`, `atomicity`.

Do not create findings merely to use categories.

If no changes are requested, write `- None.` Under **Needs discussion**, put only actual code changes here; questions belong in Open questions.

### Approved items

List meaningful items that were checked and accepted. Keep them concise; do not invent an exhaustive checklist.

If none, write `- None.` For a clean approval, `- No material maintainability or over-engineering issues found in the reviewed changes.` is sufficient.

When prior review feedback is available, verify it against the reviewed revision and report resolved requested changes here instead of raising them again. Use the `Reviewed` revision to distinguish earlier reviews from later commits.

### Open questions

Only for **Needs discussion**. List questions or decisions requiring discussion but no code change.

### Code judo

If one restructuring would eliminate a disproportionate amount of complexity, finish with:

`Code judo: <single highest-value simplification>.`

Omit it when no substantial judo opportunity exists.
