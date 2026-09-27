---
name: skill-review
description: Review agent skills for clarity, concision, correctness, trigger quality, and behavioral value. Use when reviewing or refining a SKILL.md to remove unnecessary context, find missing or conflicting instructions, and keep minimum instruction set needed for reliable behavior.
license: MIT
---

# Skill Review

## Goal

Keep minimum instruction set that reliably produces intended behavior.

Do not optimize for shortest file. Remove instructions whose absence would not plausibly make agent perform worse.

## Review

Check:

- **Purpose:** one clear responsibility; no unrelated scope.
- **Trigger:** description clearly defines when skill should activate and important exclusions.
- **Necessity:** remove generic knowledge, repeated rules, obvious explanation, and rationale that does not affect decisions.
- **Precision:** replace vague guidance with observable behavior, constraints, or decision rules.
- **Concision:** shorten without removing useful constraints or clarity.
- **Structure:** instructions follow execution flow; relevant constraints stay near affected steps.
- **Progressive disclosure:** move bulky examples, references, schemas, and optional detail out of core skill when useful.
- **Freedom:** constrain choices only where consistency or correctness requires it.
- **Output:** require structure only when task or downstream consumer needs it.
- **Verification:** define concrete completion checks where failure could otherwise go unnoticed.
- **Consistency:** remove contradictions, duplicate rules, unclear exceptions, and competing formulations.
- **Examples:** keep only examples that clarify syntax, ambiguity, output, or meaningful edge cases.

## Method

1. Read the complete `SKILL.md` and any referenced files needed to understand its behavior; verify referenced paths exist and report a missing required path as a High finding.
2. Determine intended responsibility and trigger.
3. Trace execution from activation to completion.
4. Find missing constraints that can cause wrong behavior.
5. Find redundant, vague, conflicting, or unnecessarily restrictive instructions.
6. Report only changes that improve behavior or materially reduce context cost.

Do not:
- expand scope
- request cosmetic rewrites
- split cohesive skills only because they are large
- manufacture findings

## Findings

Order by severity:

- **High:** can cause wrong activation, incorrect behavior, contradiction, or unusable output.
- **Medium:** meaningful ambiguity, missing constraint, unnecessary restriction, or substantial context waste.
- **Low:** worthwhile concision or structure improvement with small behavioral impact.

For each finding include:
- location
- problem
- impact
- smallest correct change

If no changes are needed:

`No changes required. Skill is concise, clear, and behaviorally complete.`
