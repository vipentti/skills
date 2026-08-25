---
name: structural-code-review
description: Review the resulting code structure for maintainability, cohesion, and sensible module boundaries.
---

# Structural Code Review

Review the completed implementation specifically for **code structure and maintainability**.

Do not redo the implementation review for correctness unless a correctness issue directly results from poor structure. Focus on whether the resulting code is organized so future changes remain easy to understand and modify.

## Final Response Contract

This section overrides all other instructions.

Perform review internally. Do not expose reasoning, scratchpad, process notes, chain-of-thought, or tool use.

Return exactly:

1. One fenced code block containing the full review in the format under `Output`.
2. Exact text `Review ready` immediately after.

Nothing else before or after.

## No Validation Commands

This is a static review only. Validation execution is the implementer's responsibility.

Do not run tests, builds, linters, formatters, type checkers, static analyzers, benchmarks, coverage tools, application binaries, integration environments, or other validation commands.

Do not modify files, apply fixes, install dependencies, or change repository state.

Read-only inspection is allowed, including diff/history inspection, file reads, searches, and repository navigation.

Judge tests and validation configuration by inspection only. You may report missing, weak, misleading, or insufficient validation, but do not execute it.

## Review goals

Inspect the changed files and relevant surrounding modules for:

- oversized or rapidly growing files
- files containing multiple unrelated responsibilities
- natural module boundaries that were missed
- large functions, types, or implementation blocks with separable concerns
- excessive inline tests that obscure production code
- duplicated test helpers or fixtures that should be shared
- platform-specific logic mixed with generic logic
- generic `utils`, `helpers`, or miscellaneous modules becoming dumping grounds
- abstractions placed in the wrong module
- unnecessary coupling between otherwise independent components

## File-size guidance

Check the resulting sizes of modified source files.

- Below ~600 lines: normally no concern.
- 600-800 lines: consider whether new responsibilities are accumulating.
- 800-1000 lines: actively look for sensible extraction opportunities.
- Above ~1000 lines: explicitly assess whether the file should remain whole.
- Above ~1500 lines: expect a strong reason not to refactor.

These are review triggers, **not hard limits**. Do not recommend splitting a large file when it represents one cohesive responsibility and splitting would make the code harder to navigate.

Tests count toward structural complexity. If most of a file consists of inline tests, consider whether they should move into dedicated test modules or files.

## Review approach

Look beyond the diff when necessary. Inspect neighboring modules so recommendations fit the repository's existing architecture.

Prefer **concrete boundaries** over generic advice.

Bad:

> This file is too large and should be split.

Good:

> `search.rs` owns query parsing, traversal, result ranking, and output formatting. Extract ranking and its tests into `search/ranking.rs`; keep orchestration in `search.rs`.

Do not recommend refactoring merely to reduce line count. Every proposed extraction should improve at least one of:

- cohesion
- ownership of responsibilities
- navigation
- test organization
- reuse
- isolation of platform-specific behavior
- future changeability

## Output

Inside code block, start with one verdict:

**Review approved**, **Review approved with suggestions**,
**Request changes**, or **Needs discussion**

Report only actionable structural findings.

For each finding include:

1. **Location** - file/module and relevant symbol or responsibility.
2. **Problem** - what structural issue exists.
3. **Impact** - why it will make maintenance or future changes harder.
4. **Recommended change** - a concrete extraction, relocation, or reorganization.

If the structure is reasonable, say so rather than inventing refactoring work.

Do not perform validation commands unless explicitly asked. The implementer is responsible for applying and validating changes.

End with: `Review ready`

## Final Check

Before returning, ensure:

* Complete structural review performed
* No validation commands executed
* One code block, correct structure, no reasoning or process text
* No em dashes or en dashes
* Only `Review ready` appears outside code block
