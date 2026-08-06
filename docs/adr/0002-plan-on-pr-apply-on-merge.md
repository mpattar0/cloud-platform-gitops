# ADR-0002: Plan on PR, apply on merge to main

- **Status:** Accepted
- **Date:** 2026-08-06
- **Deciders:** Repo owner

## Context

Terraform can change Azure infrastructure. We need a workflow that:
- Lets a human review exactly what will change before it happens.
- Prevents accidental applies from a laptop.
- Provides a clean audit trail (who approved what, when).
- Blocks direct writes to prod without a second pair of eyes (even though "second pair" is currently the same person — the mechanism must be in place for the future).

## Decision

Adopt a two-workflow GitOps pattern:

1. **`terraform-plan.yml`** — triggers on `pull_request` for paths `terraform/**`.
   - Runs `fmt -check`, `init`, `validate`, `plan -var environment=dev`.
   - Posts the plan as a **collapsible comment on the PR**.
   - Read-only against Azure — safe by design.

2. **`terraform-apply.yml`** — triggers on `push` to `main` for paths `terraform/**`, plus `workflow_dispatch` for manual prod runs.
   - `environment: dev|prod` binds the job to a GitHub environment, inheriting its protection rules (reviewer required on `prod`, deployment branch restricted to `main`).
   - Re-runs `plan -out=tfplan` against latest `main` state, then `apply tfplan` immediately after.
   - `concurrency: cancel-in-progress: false` — never kill an in-flight apply.

**Local rule:** `terraform apply` and `terraform destroy` are forbidden on developer laptops. `fmt`, `validate`, and `plan` (read-only, no `-out`) are OK for iteration.

## Consequences

**Positive**
- Every infrastructure change has a PR, a plan comment, a reviewer, and a merge commit — full audit trail without extra tooling.
- State is only mutated by CI running under the OIDC SP with least-privilege RBAC. Human laptops never touch state directly.
- `prod` protection is enforced at the GitHub environment layer (reviewer + branch filter), which is orthogonal to the workflow YAML — an attacker who edits the workflow still can't bypass the reviewer gate.
- Fresh `plan` inside `apply` catches drift between PR review time and merge time.

**Negative / trade-offs**
- Iteration is slower — you can't "just apply and see." Mitigated by the plan comment being fast and by allowing local `plan`.
- Two workflows to maintain instead of one. Acceptable — they have very different risk profiles.
- Single reviewer (self) doesn't actually block anything on this personal repo. Mechanism is correct; interview talking point: "in a real team, `prod` would require a reviewer from a different sub-team."

## Alternatives considered

- **Terraform Cloud / Enterprise or Atlantis** — external plan/apply runner. Overkill for one person and adds cost / another moving part.
- **Single workflow that plans and applies on merge** — no separate PR gate. Rejected: losing the plan comment loses the review UX.
- **Manual `workflow_dispatch` for both plan and apply** — no automatic PR gate. Rejected: humans forget.

## References

- [`.github/workflows/terraform-plan.yml`](../../.github/workflows/terraform-plan.yml)
- [`.github/workflows/terraform-apply.yml`](../../.github/workflows/terraform-apply.yml)
- [GitHub docs: Using environments for deployment](https://docs.github.com/actions/deployment/targeting-different-environments/using-environments-for-deployment)

---

<sub>📝 This document was drafted with the help of an AI assistant (GitHub Copilot) and reviewed by the repo owner.</sub>
