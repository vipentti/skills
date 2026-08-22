# skills

Personal agent skills, in the [`npx skills`](https://github.com/vercel-labs/skills) layout.

```bash
npx skills add vipentti/skills                              # all skills
npx skills add vipentti/skills --skill treehouse            # just one
npx skills add vipentti/skills --skill code-judo-review     # just one
npx skills add vipentti/skills --skill simple-implementation # just one
npx skills add vipentti/skills --skill planlet-workflow      # just one
```

The CLI clones over ssh, so a `gh`/ssh-authenticated machine just works.
Add `-g` to install globally, `--agent <name>` to skip the agent picker (`claude-code`, not `claude`).

| skill | what it does |
| --- | --- |
| [treehouse](skills/treehouse/SKILL.md) | create, work in, and clean up git worktrees via the [treehouse](https://github.com/kunchenguid/treehouse) CLI |
| [code-judo-review](skills/code-judo-review/SKILL.md) | strict code-quality review focused on maintainability, structural simplicity, and over-engineering; concrete problems, unnecessary complexity, missed reuse, speculative abstractions, high-value simplifications |
| [simple-implementation](skills/simple-implementation/SKILL.md) | implement features, fixes, and refactors with the least machinery needed while preserving correctness |
| [planlet-workflow](skills/planlet-workflow/SKILL.md) | execute Planlets task by task with verification, one commit per task, and a separate completion commit |
| [herdr-review-loop](skills/herdr-review-loop/SKILL.md) | dispatch a second-agent reviewer over Herdr, exchange findings files, and loop until approval |
