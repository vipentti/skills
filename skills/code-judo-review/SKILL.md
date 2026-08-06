---
name: code-judo-review
description: Perform an exceptionally strict maintainability and structural-quality review. Use for thermo-nuclear reviews, extreme code-quality audits, or rigorous reviews focused on simplification, abstraction quality, modularity, and spaghetti-code prevention.
disable-model-invocation: true
source: https://github.com/cursor/plugins/tree/main/cursor-team-kit/skills/thermo-nuclear-code-quality-review
license: license of the original applies where relevant
---

# Thermo-Nuclear Code Quality Review

Perform an unusually strict review of the current branch’s implementation quality and maintainability.

The objective is not merely to clean up individual lines. Look for structural changes that preserve behavior while making the implementation substantially simpler, smaller, clearer, and easier to extend.

Actively search for “code judo”: reframing the implementation so that unnecessary branches, states, helpers, wrappers, modes, or layers disappear entirely. Prefer deleting complexity over reorganizing or polishing it.

Review the changed code and the surrounding architecture needed to evaluate it. Do not demand unrelated rewrites.

## Review Standard

For every meaningful change, evaluate whether:

- The same behavior could be implemented with fewer concepts, branches, states, or layers.
- The change improves or degrades the local architecture.
- New conditionals, flags, nullable modes, or special cases indicate a missing abstraction or incorrect state model.
- Logic lives in the canonical module, package, service, or architectural layer.
- Existing helpers or contracts should be reused instead of introducing bespoke alternatives.
- An abstraction meaningfully reduces complexity rather than merely adding indirection.
- Types and boundaries express the real invariant without unnecessary `any`, `unknown`, casts, optionality, or loosely shaped objects.
- The change increases coupling, statefulness, file size, or the amount of context a reader must hold.
- Orchestration is unnecessarily sequential, complicated, or capable of leaving related state partially updated.
- The implementation is direct and maintainable rather than brittle, magical, or dependent on incidental control flow.

## Presumptive Blockers

Treat the following as blockers unless there is a compelling justification:

- The change creates a clear structural or maintainability regression.
- A plausible restructuring would eliminate a substantial amount of incidental complexity.
- Feature-specific checks are scattered through shared or unrelated code paths.
- New ad-hoc branches make an already complicated flow more tangled.
- Logic is placed in the wrong architectural layer or duplicates an existing canonical helper.
- A wrapper, generic mechanism, or abstraction adds indirection without simplifying the design.
- Cast-heavy, optional, or loosely typed boundaries obscure the actual contract.
- Related updates can leave the system in a partially applied state when an atomic structure is practical.
- The PR pushes a file from below 1,000 lines to above 1,000 lines without a strong structural reason and clear internal organization.

The line threshold is a strong warning, not a substitute for architectural judgment.

## Preferred Remedies

Prefer recommendations that remove complexity at its source:

- Reframe the state or data model so branches disappear.
- Move responsibility to the abstraction that naturally owns it.
- Replace scattered special cases with a coherent default flow.
- Reuse an existing canonical helper or contract.
- Delete wrappers and pass-through abstractions that do not clarify the API.
- Extract focused modules, components, helpers, or pure functions.
- Replace condition chains with an explicit typed model or dispatcher.
- Separate orchestration from business logic.
- Collapse duplicate branches into one direct flow.
- Make boundaries explicit so fallback logic and casts are unnecessary.
- Parallelize independent work when it also simplifies orchestration.
- Make related state changes atomic when partial updates would be difficult to reason about.

Do not settle for renaming or rearranging code when the underlying design can be made substantially simpler.

## Review Discipline

Be demanding, but evidence-based.

- Tie every finding to concrete changed code or a directly affected architectural boundary.
- Explain the maintainability cost, not merely the preferred style.
- Recommend a practical direction for fixing the problem.
- Do not manufacture issues to make the review appear strict.
- Do not block on theoretical improvements whose benefit is marginal or whose implementation would be disproportionate.
- Do not flood the review with cosmetic nits while structural issues remain.
- Prefer a small number of high-confidence findings over a long list of weak observations.
- Be direct and serious without being rude.

Passing tests and correct behavior are not sufficient for approval when the implementation clearly damages maintainability.

## Output Format

Start with a verdict:

- **Approve**
- **Request changes**
- **Needs discussion**

Then provide findings in priority order:

1. Structural regressions or major missed simplifications
2. Spaghetti growth and branching complexity
3. Ownership, abstraction, and architectural-boundary problems
4. Type-contract and state-model problems
5. File-size and decomposition concerns
6. Other material maintainability issues

For each finding include:

- **Severity:** Blocker, Major, or Suggestion
- **Location:** Relevant file and code area
- **Problem:** What is structurally wrong
- **Impact:** Why it makes the code harder to understand, change, or verify
- **Direction:** The recommended restructuring or simplification

When applicable, finish with the single strongest “code judo” opportunity: the restructuring most likely to remove the greatest amount of complexity.

If there are no material maintainability issues, say so explicitly rather than inventing findings.

## Approval Bar

Approve only when:

- There is no clear structural regression.
- There is no obvious high-value simplification left unaddressed.
- The change does not introduce unjustified branching, special cases, or file sprawl.
- Abstractions and type boundaries clarify rather than obscure the design.
- Logic remains in its canonical architectural home.
- The implementation leaves the affected code at least as maintainable as before.

