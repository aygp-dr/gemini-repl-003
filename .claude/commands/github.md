# GitHub Command

## Purpose
Assist with GitHub operations and integration.

## Capabilities
- Create issues with proper labels
- Generate PR descriptions
- Format commit messages
- Manage GitHub Actions workflows

## Conventions
- Use conventional commits
- Add co-author trailers
- Reference issues in commits
- Keep PRs focused and small

## GitHub CLI Usage
```bash
# Create issue
gh issue create --title "Bug: ..." --body "..." --label "bug"

# Create PR
gh pr create --title "feat: ..." --body "..." --base main

# Check CI status
gh run list
gh run view <id>

# Review PRs
gh pr review <number> --approve
gh pr review <number> --request-changes --body "..."
```

## Workflow Management
- CI runs on all pushes and PRs
- Formal verification on spec changes
- Documentation checks on doc changes
- Release automation on version tags
