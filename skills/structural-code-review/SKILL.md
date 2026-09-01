---
name: structural-code-review
description: Review a completed implementation specifically for structural maintainability, cohesion, module boundaries, and coupling. Use for structural review, not general correctness or validation review.
license: MIT
---

# Structural Code Review

Review the completed implementation specifically for **code structure and maintainability**.

Do not redo correctness review unless a correctness issue directly results from poor structure. Focus on whether responsibilities, boundaries, and dependencies make future changes easy to understand and modify.

## Review constraints

Perform static, read-only inspection.

* Do not run tests, builds, linters, formatters, type checkers, static analyzers, benchmarks, coverage tools, application binaries, or other validation commands.
* Do not modify files, apply fixes, install dependencies, or change repository state.
* Read-only file inspection, searches, repository navigation, and diff or history inspection are allowed.
* Review tests only for structural concerns such as placement, excessive inline bulk, duplicated helpers or fixtures, and inappropriate coupling.

## Review goals

Inspect changed files and relevant surrounding modules for:

* oversized or rapidly growing files
* files containing multiple unrelated responsibilities
* natural module boundaries that were missed
* large functions, types, or implementation blocks with separable concerns
* excessive inline tests that obscure production code
* duplicated test helpers or fixtures that should be shared
* platform-specific logic mixed with generic logic
* generic `utils`, `helpers`, or miscellaneous modules becoming dumping grounds
* abstractions placed in the wrong module
* unnecessary coupling between otherwise independent components

## File-size guidance

Use resulting file size as a review signal, not a refactoring target.

* Below ~600 lines: size alone is normally not a concern.
* 600-800 lines: consider whether responsibilities are accumulating.
* 800-1000 lines: actively look for sensible extraction opportunities.
* Above ~1000 lines: explicitly assess whether the file should remain whole.
* Above ~1500 lines: expect a strong reason for keeping the file whole.

These are review triggers, not hard limits. Do not recommend splitting a large file when it represents one cohesive responsibility and splitting would make the code harder to navigate.

Tests count toward structural complexity. If inline tests dominate a source file or obscure production code, consider whether dedicated test modules or files provide a clearer boundary.

## Review approach

Look beyond the diff when necessary. Inspect neighboring modules so findings account for existing architecture and ownership boundaries.

Prefer concrete boundaries over generic advice.

Bad:

> This file is too large and should be split.

Good:

> `search.rs` owns query parsing, traversal, result ranking, and output formatting. Extract ranking and its tests into `search/ranking.rs`; keep orchestration in `search.rs`.

Do not recommend refactoring merely to reduce line count. Every proposed change should improve at least one of:

* cohesion
* responsibility ownership
* navigation
* test organization
* reuse
* isolation of platform-specific behavior
* coupling
* future changeability

## Output

Start with exactly one verdict:

* **Review approved** - no actionable structural findings.
* **Review approved with suggestions** - only non-blocking structural improvements.
* **Request changes** - one or more structural problems should be corrected before completion.
* **Needs discussion** - appropriate structure depends on an architectural or ownership decision that cannot be resolved from available context.

Report only actionable structural findings.

For each finding include:

1. **Location** - file or module and relevant symbol or responsibility.
2. **Problem** - specific structural issue.
3. **Impact** - how it makes maintenance or future changes harder.
4. **Recommended change** - concrete extraction, relocation, boundary, or reorganization.

If no actionable findings exist, say so rather than inventing refactoring work.

## Final check

Before returning, ensure:

* review stayed focused on structure and maintainability
* relevant surrounding architecture was inspected where needed
* every finding has a concrete structural benefit
* no validation commands were executed
* no repository state was modified
