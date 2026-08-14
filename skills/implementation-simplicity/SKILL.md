---
name: implementation-simplicity
description: >
  Prevent overengineering in software changes. Use when implementing features,
  fixing bugs, refactoring, designing code, choosing dependencies, or reviewing
  implementation approaches. Prefer the smallest, simplest solution that fully
  satisfies the current requirements. Avoid speculative abstractions,
  unnecessary generalization, unrelated refactoring, premature future-proofing,
  and excessive compatibility machinery.
license: MIT
---

# Implementation Simplicity

Apply this skill whenever making or evaluating a software implementation.

The objective is not to minimize lines of code. The objective is to minimize
unnecessary complexity while fully satisfying the current requirements.

Prefer solutions that are direct, local, easy to understand, and inexpensive to
maintain.

## Core Principle

Implement the smallest solution that correctly solves the problem that exists
now.

Do not build for hypothetical future requirements unless those requirements are
explicitly part of the task.

Before adding complexity, ask:

> What current requirement makes this necessary?

If there is no concrete answer, leave it out.

## Decision Ladder

Before writing new code or introducing a new mechanism, consider solutions in
this order.

1. **Does anything need to change?**
   - Confirm that the requested behavior is not already present.
   - Do not change code merely to make it cleaner, more elegant, or more
     generalized unless the task requires that work.

2. **Can the existing codebase already do it?**
   - Reuse existing functions, components, services, utilities, patterns, and
     conventions.
   - Prefer extending an established local pattern over creating a parallel
     abstraction.

3. **Can the standard library do it?**
   - Prefer built-in language facilities over custom utilities or additional
     dependencies.

4. **Can the platform or framework do it natively?**
   - Use capabilities already provided by the runtime, operating system,
     browser, framework, database, build system, or other existing platform.

5. **Can an existing dependency do it?**
   - Prefer dependencies already present in the project when they provide the
     required functionality cleanly.
   - Do not add a new dependency when existing project capabilities are
     sufficient.

6. **Can it be implemented directly with a small amount of clear code?**
   - Prefer explicit, local code over introducing a generalized mechanism.
   - A small amount of duplication can be preferable to an abstraction that has
     only one real use case.

7. **Only then introduce new machinery.**
   - Add a new abstraction, dependency, framework, service, configuration
     layer, extension point, or architectural component only when the current
     requirements justify it.

Use the earliest satisfactory option in this ladder.

## Scope Discipline

Keep changes proportional to the task.

A small feature or bug fix should normally result in a small, localized change.

Do not:

- refactor unrelated code while implementing the requested change;
- rename or reorganize unrelated files;
- convert surrounding code to a preferred architectural style;
- introduce new layers merely to make the implementation look cleaner;
- expand the task into adjacent improvements;
- fix unrelated issues unless they prevent completion of the requested work.

If a supposedly small change begins spreading across many files or subsystems,
reassess whether the approach is unnecessarily complex.

## Avoid Speculative Generalization

Do not generalize based on imagined future requirements.

Avoid introducing:

- interfaces with only one implementation solely for future extensibility;
- factories where direct construction is sufficient;
- plugin systems without an actual plugin requirement;
- generic repositories or service layers for a single concrete use case;
- event buses for direct interactions between a small number of components;
- configuration options nobody currently needs;
- extension points without known consumers;
- generalized helper frameworks for one or two call sites;
- complex type hierarchies for simple data;
- indirection whose only justification is that it may be useful later.

Create an abstraction when multiple real cases demonstrate a useful shared
concept, not because additional cases might exist someday.

## Avoid Premature Future-Proofing

Support the requirements that exist now.

Do not proactively add:

- backwards-compatibility paths that are not required;
- migration machinery without an actual migration;
- fallback implementations without a known failure mode requiring them;
- multiple providers when only one is required;
- version negotiation without multiple supported versions;
- feature flags for behavior that does not need staged rollout;
- configuration for values that are intentionally fixed;
- extensibility hooks without an identified use case.

Future work can introduce these mechanisms when concrete requirements appear.

## Prefer Existing Conventions

Consistency usually has more value than theoretical architectural purity.

When several reasonable implementations exist:

1. prefer the pattern already used nearby;
2. prefer the project's existing dependencies and utilities;
3. prefer the project's established naming and file organization;
4. introduce a new pattern only when the existing one cannot reasonably satisfy
   the requirement.

Do not create a second way of solving a problem without a clear reason.

## Prefer Explicit Code

Prefer straightforward code whose behavior can be understood locally.

Avoid cleverness that reduces apparent code size while increasing cognitive
complexity.

Prefer:

- ordinary control flow;
- explicit data transformations;
- obvious function calls;
- narrowly scoped helpers;
- concrete types when generic types add no value.

Be cautious with:

- metaprogramming;
- reflection;
- dynamic dispatch;
- deeply generic APIs;
- implicit registration;
- hidden global behavior;
- excessive chaining;
- abstractions that require navigating several files to understand simple
  behavior.

Simple does not mean compressed.

## Abstraction Test

Before creating a new abstraction, verify that it provides concrete value now.

Good reasons include:

- multiple current call sites share meaningful behavior;
- the abstraction enforces an important invariant;
- it significantly reduces duplicated complex logic;
- an external boundary genuinely requires interchangeable implementations;
- testing a meaningful boundary would otherwise be impractical;
- the framework or project architecture already requires the abstraction.

Weak reasons include:

- "we might need another implementation later";
- "this is more enterprise-ready";
- "it makes the architecture cleaner";
- "it could be reused someday";
- "it follows a pattern even though there is only one case";
- "it gives us more flexibility."

Do not create an abstraction based only on weak reasons.

## Dependency Test

Before adding a dependency, ask:

1. Is it already available transitively or directly in the project?
2. Can the standard library or existing platform provide the functionality?
3. Is the required behavior small enough to implement safely and clearly?
4. Does the dependency introduce meaningful maintenance, security, binary-size,
   startup-time, or compatibility cost?
5. Is the dependency solving a substantial problem rather than saving a few
   lines of straightforward code?

Do not recreate complex, security-sensitive, or standards-heavy functionality
merely to avoid a dependency.

## Configuration Test

Configuration creates a permanent interface and maintenance obligation.

Do not make something configurable merely because it can vary.

Introduce configuration when:

- users or deployments genuinely need different values;
- environments require different behavior;
- the task explicitly requires configurability;
- the project already exposes the relevant setting as configuration.

Otherwise prefer a clear constant or direct implementation.

## Error Handling

Simplicity does not justify ignoring real failure modes.

Handle errors that are:

- reasonably expected;
- actionable;
- required by project conventions;
- necessary to preserve correctness or user data.

Do not add elaborate recovery systems for failures with no realistic path or
requirement.

Avoid:

- catching exceptions only to rethrow them unchanged;
- retry frameworks for operations that should not retry;
- fallback chains without a documented need;
- defensive checks against impossible states already guaranteed by the type
  system or surrounding invariants.

## Validation and Defensive Code

Do not remove necessary validation merely to reduce code.

Validation is justified at trust boundaries such as:

- user input;
- network input;
- persisted external data;
- untrusted files;
- public APIs;
- security boundaries.

Avoid repeatedly validating invariants that have already been established
inside trusted internal code.

## Security, Safety, and Data Integrity

Never simplify away protections required for:

- authentication;
- authorization;
- input validation at trust boundaries;
- secrets handling;
- data integrity;
- concurrency correctness;
- transaction safety;
- destructive operations;
- protection against data loss;
- secure defaults.

Necessary safety mechanisms are not overengineering.

## Accessibility

Do not remove or bypass accessibility behavior in the name of simplicity.

Use native semantic platform behavior where possible rather than recreating it
with custom code.

## Testing

Tests should be proportional to the behavior being changed.

Prefer tests that verify observable requirements and meaningful edge cases.

Do not:

- create large testing frameworks for a small change;
- extensively mock internal implementation details;
- test trivial language or framework behavior;
- duplicate the same assertion across many abstraction layers;
- add speculative tests for unsupported hypothetical scenarios.

Add regression tests for bugs when practical and consistent with the project's
testing conventions.

## Refactoring

Refactor when it is necessary to implement the requested change safely or when
the task explicitly requests refactoring.

Otherwise, prefer the smallest modification to the existing structure.

A useful local cleanup that directly supports the implementation is acceptable.

A repository-wide cleanup disguised as part of a small feature is not.

## Compatibility

Preserve compatibility when the project or task requires it.

Do not assume every internal behavior is a permanent compatibility contract.

Before adding compatibility machinery, identify:

- what consumer depends on the old behavior;
- whether compatibility is explicitly required;
- how long the compatibility path needs to exist.

If no consumer or requirement exists, prefer changing the implementation
directly.

## Diff Discipline

Treat diff size as a useful warning signal, not an optimization target.

The complexity and size of the diff should be proportional to the requested
change.

When a simple task produces a surprisingly large diff, check for:

- unnecessary refactoring;
- duplicated architecture;
- speculative extensibility;
- excessive file movement;
- unrelated formatting changes;
- generated boilerplate;
- compatibility code without consumers;
- abstractions introduced before they are needed.

A large diff can be correct, but it should have a concrete reason.

## When Complexity Is Justified

Use a more elaborate solution when the requirements genuinely demand it.

Examples include:

- significant security constraints;
- transactional correctness;
- distributed coordination;
- demonstrated performance requirements;
- concurrency requirements;
- multiple real implementations;
- public API compatibility;
- complex domain rules;
- required extensibility;
- regulatory or accessibility obligations.

Do not reject necessary complexity merely because a simpler-looking solution
exists.

The goal is **essential complexity without accidental complexity**.

## During Implementation

Periodically verify:

- Is every new component required by the current task?
- Am I reusing what already exists?
- Have I introduced an abstraction with only one real consumer?
- Am I solving hypothetical future problems?
- Has the implementation expanded beyond the requested scope?
- Could an existing platform capability replace custom code?
- Is there a more direct implementation with the same correctness?
- Would removing this piece make the current requirements fail?

If removing something would not affect the current requirements, strongly
consider removing it.

## During Review

When reviewing an implementation, identify unnecessary complexity separately
from correctness issues.

Look for:

- speculative abstractions;
- unnecessary indirection;
- premature generalization;
- unused flexibility;
- unnecessary dependencies;
- redundant helpers;
- parallel implementations of existing functionality;
- unrelated refactors;
- unnecessary compatibility layers;
- configuration without a current consumer;
- excessive defensive code;
- unnecessary wrappers around existing APIs;
- disproportionately large changes for simple requirements.

For each finding, explain what simpler implementation would satisfy the same
current requirement.

Do not recommend simplification merely for stylistic preference.

## Final Check

Before considering the implementation complete, verify:

1. The current requirements are fully satisfied.
2. Necessary correctness and safety behavior remains intact.
3. Existing project capabilities were reused where appropriate.
4. No unnecessary abstractions or dependencies were introduced.
5. No speculative future requirements were implemented.
6. Unrelated code was not refactored.
7. The diff is reasonably proportional to the task.
8. Every meaningful piece of added complexity has a concrete current
   justification.

If all requirements can be met with less machinery without reducing correctness,
prefer the simpler implementation.
