## 🧪 Swift

Lints and tests the package on a matrix of simulators.
Required to pass before merging.
Notifies scout-ip when tests pass on main.

## 🔧 Auto Fix

Triggers when Swift workflow fails.
Runs Claude Code to diagnose the failure and create a fix PR.

## 🔀 Resolve Conflicts

Triggers on push to main.
Finds open PRs with merge conflicts and runs Claude Code to resolve them.
