<#
.SYNOPSIS
Deletes local branches whose PRs were merged into main.

.DESCRIPTION
Enterprise-hygiene helper. Complements two other layers already in place:
  1. GitHub `deleteBranchOnMerge = true` — deletes the remote branch on merge.
  2. Local `git config --global fetch.prune = true` — drops stale
     remote-tracking refs (origin/feat/xxx) on every fetch/pull.
  3. THIS SCRIPT — deletes the local branch pointer after the remote is gone.

Workflow after every PR merge:

    .\scripts\gitcleanup.ps1

Steps performed:
  a. Bail out if working tree has uncommitted changes.
  b. Switch to main; pull latest.
  c. Fetch with prune to sync remote-tracking refs.
  d. Delete every local branch that is fully merged into main
     (safe delete: `git branch -d`, which refuses unmerged branches).

.PARAMETER Force
Use `git branch -D` instead of `-d`. DANGEROUS — deletes branches even if they
contain commits not present on main. Only use when you know the branch was
merged via squash/rebase (which leaves the original commits "unmerged" from
git's perspective).

.EXAMPLE
    .\scripts\gitcleanup.ps1

.EXAMPLE
    .\scripts\gitcleanup.ps1 -Force
    # For branches merged via squash — safe-delete would refuse them.
#>
[CmdletBinding()]
param(
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

# --- guard: uncommitted changes ------------------------------------------------
$dirty = git status --porcelain
if ($dirty) {
    Write-Host "❌ Working tree is dirty. Commit or stash before running cleanup." -ForegroundColor Red
    git status --short
    exit 1
}

# --- switch to main + sync -----------------------------------------------------
Write-Host "→ checkout main" -ForegroundColor Cyan
git checkout main
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "→ pull" -ForegroundColor Cyan
git pull
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "→ fetch --prune (sync stale remote-tracking refs)" -ForegroundColor Cyan
git fetch --prune

# --- find merged local branches ------------------------------------------------
# `git branch --merged main` lists branches whose tip is reachable from main.
# We exclude:
#   - the current branch marker (line starts with '* ')
#   - the 'main' branch itself
$stale = git branch --merged main |
ForEach-Object { $_.Trim() } |
Where-Object { $_ -and $_ -notmatch '^\*' -and $_ -ne 'main' }

if (-not $stale) {
    Write-Host "✅ No merged local branches to delete." -ForegroundColor Green
    exit 0
}

# --- delete them ---------------------------------------------------------------
$flag = if ($Force) { '-D' } else { '-d' }
Write-Host ""
Write-Host "→ deleting merged local branches (git branch $flag):" -ForegroundColor Yellow
$stale | ForEach-Object {
    Write-Host "   - $_"
    git branch $flag $_
}

# --- also handle squash-merged branches (optional info message) ----------------
# Branches merged via GitHub's "Squash and merge" show as UNMERGED here because
# git sees a different commit SHA. If you use squash-merge, re-run with -Force
# after confirming with `gh pr list --state merged`.
if (-not $Force) {
    $unmerged = git branch --no-merged main |
    ForEach-Object { $_.Trim() } |
    Where-Object { $_ -and $_ -notmatch '^\*' -and $_ -ne 'main' }
    if ($unmerged) {
        Write-Host ""
        Write-Host "Local branches NOT merged into main (may be squash-merged PRs):" -ForegroundColor DarkGray
        $unmerged | ForEach-Object { Write-Host "   - $_" -ForegroundColor DarkGray }
        Write-Host "   Run '.\scripts\gitcleanup.ps1 -Force' if you are sure they were merged upstream." -ForegroundColor DarkGray
    }
}

Write-Host ""
Write-Host "✅ Cleanup complete." -ForegroundColor Green
