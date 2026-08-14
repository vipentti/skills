---
name: implementation-simplicity
description: >
  Prevent overengineering in features, fixes, and refactors. Prefer the smallest
  direct solution that meets current requirements and preserves correctness.
license: MIT
---

# Implementation Simplicity

## Core Principle

Solve the current problem correctly while minimizing unnecessary complexity, not lines of code.

Before adding complexity, ask:

> What current requirement makes this necessary?

If there is no concrete answer, leave it out. Keep changes local and consistent
with nearby code unless the requirement makes a broader change necessary.

## Simplification Ladder

Consider options in this order and use the earliest one that fully satisfies the
requirement:

1. **No change:** Confirm the requested behavior is not already present.
2. **Reuse local code:** Use existing functions, components, services, utilities,
   patterns, and conventions.
3. **Use the standard library:** Prefer built-in language facilities.
4. **Use the native platform:** Prefer the runtime, framework, browser, operating
   system, database, or build system.
5. **Use an installed dependency:** Reuse one already in the project when it
   provides the behavior cleanly.
6. **Write direct code:** Prefer a small, explicit implementation over a new
   generalized mechanism. Limited duplication can be clearer than a premature
   abstraction.
7. **Add new machinery:** Introduce an abstraction, dependency, service,
   configuration layer, or architectural component only when current
   requirements justify it.

## Compact Guardrails

Avoid these unless they are required now:

- interfaces with one implementation, factories for direct construction, or
  generic layers for a single concrete case;
- plugin systems, extension points, event buses, providers, or type hierarchies
  without current consumers;
- configuration for intentionally fixed values or feature flags without a
  rollout need;
- compatibility paths, migrations, fallbacks, retries, or version negotiation
  without a known consumer or failure mode;
- new dependencies for behavior handled clearly by existing code, the standard
  library, or the platform;
- wrappers, helpers, indirection, metaprogramming, or reflection that make
  simple behavior harder to follow;
- unrelated refactors, file movement, renaming, formatting, or adjacent
  improvements;
- testing frameworks, extensive mocks, or speculative tests disproportionate to
  the changed behavior.

Prefer established project conventions and explicit code that can be understood
locally. Refactor only when the task requests it or the change cannot be made
safely without it. Treat a surprisingly large diff as a prompt to reconsider
the approach, not as proof that the approach is wrong.

### Do Not Oversimplify Necessary Correctness

Simplicity never justifies removing behavior needed for correctness, safety, or
the stated requirements. Preserve appropriate:

- error handling for realistic and actionable failures;
- validation at trust boundaries;
- authentication, authorization, secure defaults, and secrets handling;
- data integrity, concurrency, transaction, and destructive-operation safety;
- public compatibility, accessibility, and domain or regulatory obligations;
- tests for observable requirements, meaningful edge cases, and practical bug
  regressions.

Complexity is justified when concrete requirements demand it. Do not recreate
complex, security-sensitive, or standards-heavy functionality merely to avoid a
dependency.

## Final Checklist

Before considering the implementation complete, verify:

1. Current requirements are fully satisfied.
2. Existing project, standard library, platform, and dependency capabilities were
   reused where appropriate.
3. Every abstraction, dependency, configuration option, and compatibility path
   has a concrete current justification.
4. Necessary correctness, safety, accessibility, and meaningful tests remain.
5. No hypothetical future requirement or unrelated refactor entered the change.
6. The implementation and diff are proportional to the task.
7. Removing any added machinery would cause a current requirement to fail.

Prefer less machinery whenever it meets the same requirements with equal correctness.
