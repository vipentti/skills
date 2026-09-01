---
name: simple-implementation
description: Use when implementing features, fixing bugs, refactoring, or making other code changes. Prefer the simplest correct implementation. Reuse existing code and native capabilities, avoid speculative abstractions and dependencies, and add only machinery required by current requirements.
license: MIT
---

# Implementation Simplicity

## Core Principle

Solve current problem correctly while minimizing unnecessary complexity, not lines of code.

Before adding complexity, ask:

> What current requirement makes this necessary?

If there is no concrete answer, leave it out. Keep changes local and consistent
with nearby code unless requirement makes a broader change necessary.

## Simplification Ladder

Consider options in this order. Prefer earlier options when they satisfy
requirement equally well and fit established project conventions:

1. **No change:** Confirm requested behavior is not already present.
2. **Reuse local code:** Use existing functions, components, services, utilities,
   patterns, and conventions.
3. **Use standard library:** Prefer built-in language facilities.
4. **Use native platform:** Prefer runtime, framework, browser, operating system,
   database, or build system.
5. **Use an installed dependency:** Reuse one already in project when it provides
   behavior cleanly.
6. **Write direct code:** Prefer small, explicit implementation over a new
   generalized mechanism. Limited duplication can be clearer than premature
   abstraction.
7. **Add new machinery:** Introduce an abstraction, dependency, service,
   configuration layer, or architectural component only when current
   requirements justify it.

## Compact Guardrails

Avoid these unless required now:

* interfaces with one implementation, factories for direct construction, or
  generic layers for a single concrete case;
* plugin systems, extension points, event buses, providers, or type hierarchies
  without current consumers;
* configuration for intentionally fixed values or feature flags without a
  rollout need;
* compatibility paths, migrations, fallbacks, retries, or version negotiation
  without a known consumer or failure mode;
* new dependencies for behavior handled clearly by existing code, standard
  library, or platform;
* wrappers, helpers, indirection, metaprogramming, or reflection that make
  simple behavior harder to follow;
* unrelated refactors, file movement, renaming, formatting, or adjacent
  improvements;
* testing frameworks, extensive mocks, or speculative tests disproportionate to
  changed behavior.

Prefer established project conventions and explicit code that can be understood
locally. Refactor only when task requests it or a scoped refactor is needed to
implement change correctly and simply. Treat a surprisingly large diff as a
prompt to reconsider approach, not as proof that approach is wrong.

### Do Not Oversimplify Necessary Correctness

Simplicity never justifies removing behavior needed for correctness, safety, or
stated requirements. Preserve appropriate:

* error handling for realistic and actionable failures;
* validation at trust boundaries;
* authentication, authorization, secure defaults, and secrets handling;
* data integrity, concurrency, transaction, and destructive-operation safety;
* public compatibility, accessibility, and domain or regulatory obligations;
* tests for observable requirements, meaningful edge cases, and practical bug
  regressions.

Complexity is justified when concrete requirements demand it. Do not recreate
complex, security-sensitive, or standards-heavy functionality merely to avoid a
dependency.

## Final Checklist

Before considering implementation complete, verify:

1. Current requirements are fully satisfied.
2. Existing project, standard library, platform, and dependency capabilities were
   reused where appropriate.
3. Every abstraction, dependency, configuration option, and compatibility path
   has a concrete current justification.
4. Necessary correctness, safety, accessibility, and meaningful tests remain.
5. No hypothetical future requirement or unrelated refactor entered change.
6. Implementation and diff are proportional to task.
