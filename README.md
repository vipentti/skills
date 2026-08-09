# skills

Personal agent skills, in the [`npx skills`](https://github.com/vercel-labs/skills) layout.

```bash
npx skills add vipentti/skills                   # all skills
npx skills add vipentti/skills/skills/treehouse  # just one (full path in repo)
```

The CLI clones over ssh, so a `gh`/ssh-authenticated machine just works.
Add `-g` to install globally, `--agent <name>` to skip the agent picker (`claude-code`, not `claude`).

| skill | what it does |
| --- | --- |
| [treehouse](skills/treehouse/SKILL.md) | create, work in, and clean up git worktrees via the [treehouse](https://github.com/kunchenguid/treehouse) CLI |
| [code-judo-review](skills/code-judo-review/SKILL.md) | strict code-quality review focused on maintainability, structural simplicity, and over-engineering; concrete problems, unnecessary complexity, missed reuse, speculative abstractions, high-value simplifications |
