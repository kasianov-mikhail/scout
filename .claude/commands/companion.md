---
description: Set up and cross-link the companion PR in the paired Scout repo(s) for this change
argument-hint: [companion-branch-name]
allowed-tools: Bash(git:*), Bash(gh:*)
---

You are coordinating a change across the Scout family of repos (all under
`kasianov-mikhail/*`), which share contracts and dependencies. For the current change, you
identify the paired repo(s) that must change in lockstep, then set up and cross-link the
companion PR there.

## Topology

- **scout** (`kasianov-mikhail/scout`) — the client Swift package (the SDK). Wire-contract
  surface: `Core/Database/Backend` (`HTTPQueryCoding`, `HTTPRecordCoding`, `HTTPDatabase`),
  guarded by `ServerContractTests`.
- **scout-server** (`kasianov-mikhail/scout-server`) — the Vapor backend. Wire-contract
  surface: the `Wire` types, the controllers, and `API.md`.
- **scout-ip** (`kasianov-mikhail/scout-ip`, the `ScoutIP` iOS app) — consumes the `scout`
  package via SPM (`Package.resolved`).

Companion relationships:

- **scout ↔ scout-server** — bidirectional HTTP wire contract. A change to request/response
  shapes, field names, the queryable-field set, or endpoints on one side needs a matching
  change on the other; keep `API.md` and `ServerContractTests` in sync.
- **scout → scout-ip** — scout-ip consumes the SDK. A scout release or public-API change
  that scout-ip should adopt needs a companion PR in scout-ip that bumps the pinned scout
  dependency (`Package.resolved`) and adapts to the change.

## Live context

- This repo's origin: !`git remote get-url origin 2>/dev/null`
- Current branch: !`git branch --show-current`
- This branch's PR (if any): !`gh pr view --json number,url,title,state 2>/dev/null || echo "no PR yet"`
- Recent commits: !`git log --oneline -8`

## Procedure

1. **Identify this repo** from the origin slug (`kasianov-mikhail/<name>`) — one of scout /
   scout-server / scout-ip. Determine the base branch (strip `origin/` from
   `git symbolic-ref --short refs/remotes/origin/HEAD`; fall back to `main`, then `master`).

2. **Confirm there is a change to propagate.** There must be commits ahead of base. Compute
   the changed files: `git diff --name-only <base>...HEAD`. If there is an open PR here, note
   its URL (you will cross-link it); if there is none, you can still prepare the companion,
   but suggest opening this side's PR first (e.g. `/ship`).

3. **Decide which companion(s) are implicated** from the changed files:
   - In **scout**: a changed path in the wire-contract layer
     (`Core/Database/Backend`, `HTTP*Coding`, `HTTPDatabase`, `ServerContractTests`) implicates
     **scout-server**. A change to scout's **public API** (or a release scout-ip should adopt)
     implicates **scout-ip**. Both can apply at once.
   - In **scout-server**: a change to the `Wire` types, the controllers, or `API.md`
     implicates **scout**.
   - In **scout-ip**: a change that needs a new/changed SDK capability implicates **scout**
     (the SDK change lands there first).
   - If nothing contract- or API-relevant changed, say so — likely no companion is needed —
     and stop.

4. **Locate the companion checkout.** Companion repos are siblings of this repo's **main**
   worktree: `MAIN` = parent of `git rev-parse --git-common-dir`; the companion path is
   `<dirname of MAIN>/<companion-repo-name>`. If it is not there, report the path you
   expected and skip that companion.

5. **For each implicated companion repo** (operate with `git -C <path>` / `gh` in that repo):
   - Only act on a **clean** checkout sitting on its base branch — never clobber in-progress
     work there. If it is dirty or on another branch, report and skip.
   - Create a companion branch (use the argument if given, else mirror this branch's name).
   - Draft the precise **mirroring checklist**: for the wire contract, the exact
     request/response fields, endpoints, and queryable fields to match, plus `API.md` and
     `ServerContractTests`; for scout-ip, the scout dependency bump in `Package.resolved` and
     the API adaptation.
   - Open a **draft** PR there (`gh pr create --draft`, base = its default branch) with a
     description in short prose — no bullet lists, no section headers — that cross-links this
     PR ("Companion of <this-PR-url>").
   - **Cross-link back**: update this side's PR description to reference the companion PR URL.

6. **Report** each companion repo with its branch and PR URL, plus the mirroring checklist.
   Implementing the companion's actual code change is the next step — offer to do it now (the
   checkout is local) or to continue in a session opened in that repo.

## Safety rules

- Separate repos ship separate PRs — never merge across repos; open companions as **drafts**
  and cross-link both descriptions.
- Never clobber a companion checkout: act only on a clean checkout at its base; otherwise
  report and stop for that repo.
- PR descriptions follow the repo style: a few sentences of prose, no bullet lists, no
  section headers; always cross-link the paired PR.
- Commit with each repo's own git `user.name`/`user.email` — never a bot identity, never a
  `Co-Authored-By` trailer. Never force-push.
- When the wire contract changes, keep `API.md` and `ServerContractTests` in sync.
