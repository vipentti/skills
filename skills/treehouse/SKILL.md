---
name: treehouse
description: Create, work in, and clean up isolated git worktrees using the treehouse CLI. Use when the user asks to set up a treehouse or a worktree, work on a branch in isolation, or clean up / return / destroy a worktree.
---

# Treehouse worktrees

[treehouse](https://github.com/kunchenguid/treehouse) keeps a pool of reusable git worktrees so
several agents can work on the same repo in parallel. Use the lease workflow — never the
interactive subshell (`treehouse get` with no flags, `treehouse enter <name>` with no flags),
which you cannot drive.

If `treehouse` is not on PATH, stop and point the user at the install instructions above.

## Acquire

From inside the target repo:

```bash
treehouse get --lease --json --lease-holder "<short task label>"
```

JSON goes to stdout, banners to stderr. Read the worktree **path** and **lease id** out of it and
report both to the user. A leased worktree is never handed to another `get` and never pruned until
you return it.

If the repo has no pool config yet, `treehouse init` writes `treehouse.toml`. Ask before committing
that file — it may be the user's personal setup, not the project's.

## Work in it

Run every command with the absolute worktree path: `cd <path> && ...` or `git -C <path> ...`. Do
not assume the shell's cwd persists between calls. Create or switch the feature branch inside the
worktree, not in the main checkout.

To recover the path in a later session, use `treehouse status --json` and match on the lease holder
label. `treehouse enter <name> --print-path` prints the path of an existing worktree by its pool
name.

## Clean up

Before returning, check the work has landed:

```bash
git -C <path> status --porcelain          # must be empty
git -C <path> log --oneline @{u}..        # must be empty, or the branch merged/pushed
```

If there is uncommitted or unpushed work, **stop and tell the user** — do not return the worktree.

Otherwise release it back to the pool:

```bash
treehouse return --force --if-lease-id <lease-id> <path>
```

`--if-lease-id` makes this a no-op if someone else now holds the worktree.

Only when the user explicitly asks to throw the work away:

```bash
treehouse destroy <path> --include-leased --include-unlanded --yes
```

Without `--yes`, `destroy` is a dry run that prints what it would remove — a safe way to preview.
