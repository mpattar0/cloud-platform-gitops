# Copilot Instructions — cloud-platform-gitops

This repository is a **personal learning / interview-prep** project running on a
**pay-as-you-go Azure subscription**. Cost control is a hard requirement.

## Roadmap enforcement (READ FIRST EVERY TURN)

This repo has **two roadmap files** — read them in this order at the start of every turn:

1. **`docs/ROADMAP.md`** — long-term mastery roadmap (git-tracked, durable).
   Defines the 3 parallel tracks: GitHub Actions (A), Terraform (B), Azure services (C).
   Each topic marked `[ ]`, `[~]`, or `[x]`. This is the north-star curriculum.

2. **`PROGRESS.md`** — day-to-day PR tracker (local, gitignored).
   Contains the "📍 Current Phase" and next-up PR.

**Before responding to any request that could produce code, files, or a plan
of action, you MUST:**

1. Read `docs/ROADMAP.md` — locate which tracks + topics the request advances.
2. Read `PROGRESS.md` — locate the current phase and next unchecked PR.
3. **Silently verify alignment.** If the request drifts from the current phase:
   - Flag it in one sentence (e.g. *"That's C6 — we're on C1/C8 in Phase 2, PR #3. Jump ahead?"*)
   - Offer: (a) proceed anyway, (b) return to current PR, (c) update roadmap.
4. **Suggest a study focus for the session** when the user asks for one — pick
   ONE roadmap topic that aligns with the next PR and propose a 15-30 min drill
   before writing code.
5. **After completing a PR (merge to `main`)**:
   - Tick the PR checkbox in `PROGRESS.md`
   - Update the corresponding topics in `docs/ROADMAP.md` (`[ ]` → `[~]` or `[x]`)
   - Add one-line note under the phase if a design decision was made

**Never invent progress.** Only mark items complete when the user confirms merge
or CI apply succeeded.

**Roadmap has priority over user momentum.** If the user asks for something
off-plan, name it before doing it. It's OK to do off-plan work — but only after
the user acknowledges the drift.

## North-star goal (from ROADMAP.md)

Become interview-ready as a senior Cloud / Integration / DevOps engineer on
Azure, using Terraform + GitHub Actions. Every module: variable-driven SKU
(dev cheap, prod code-only), 5 mandatory tags, validation, plan-on-PR /
apply-on-merge, ADR for decisions.

## Cost rules (MUST follow)

1. **Default to free or minimum-cost tiers.** Never propose Premium / Standard
   SKUs when a Free / Basic tier works.
2. **Flag the cost of every Azure resource** you suggest, in a single line
   (e.g. `~$0.02/month`, `Free tier: 5 GB/month`). If unsure, say so.
3. **Prefer PaaS free tiers** over IaaS. No VMs unless explicitly requested.
4. **Avoid these unless the user explicitly asks:**
   - Public IPs (charged per hour, even when idle)
   - DNS zones (~$0.50/mo per zone)
   - Application Gateway, Front Door Premium, API Management Standard+
   - Log Analytics without a **daily cap** and short retention
   - GRS / RA-GRS / ZRS storage (use `Standard_LRS`)
   - Any Premium SKU (Storage, Key Vault, Service Bus, etc.)
5. **Always include a teardown step** (`az group delete --name <rg> --yes --no-wait`)
   when walking the user through creating resources.
6. **Storage accounts**: `Standard_LRS`, `StorageV2`, TLS 1.2 min, HTTPS only,
   public blob access disabled, versioning + soft delete for state buckets only.
7. **Log Analytics**: `PerGB2018`, retention ≤ 30 days, daily cap `0.1 GB`.
8. **Key Vault**: `standard` SKU, RBAC auth mode, purge protection **off** for
   dev/learning (so RG deletes cleanly).
9. **App Service**: prefer `F1` (Free). Use `B1` only when F1 is insufficient
   (e.g. custom domain / always-on required) and call out the ~$13/mo cost.
10. **Never suggest** paid features like Defender for Cloud Standard, Sentinel,
    Purview, Azure Firewall, Bastion, ExpressRoute, or reserved capacity.

## Preferred defaults

| Concern              | Choice                                              |
| -------------------- | --------------------------------------------------- |
| Region               | `eastus` (cheapest + broadest SKU availability)     |
| IaC tools            | Terraform (root) + Bicep (module comparisons)       |
| Auth to Azure from CI| GitHub OIDC federated credentials (no secrets)      |
| State backend        | Azure Storage `Standard_LRS` + blob versioning      |
| Naming               | CAF: `{type}-{prefix}-{workload}-{env}-{region}`    |
| Tags (mandatory)     | `env`, `workload`, `owner`, `costCenter`, `managedBy` |

## Enterprise-standard practices to always apply

- **OIDC only** — never generate client secrets for service principals.
- **Least privilege RBAC** — scope role assignments to the RG, not subscription,
  unless the user has explicitly opted into subscription-wide Contributor.
- **Pin versions** — `required_version`, `required_providers`, action SHAs.
- **PR-driven workflow** — one branch per logical change, CI gates on
  `fmt`, `validate`, `tflint`, `tfsec` / `checkov`, `bicep lint`, `gitleaks`.
- **Environments with required reviewers** for `apply` / `deploy` jobs.
- **ADRs** in `docs/adr/` for every significant decision.

## Interaction style

- The user is walking through steps interactively; give **one small step at a
  time** and wait for confirmation before moving on.
- Always show the exact command(s) to paste, then ask for `done` or error output.
- Prefer PowerShell examples (Windows host).

## Teardown discipline (MUST follow)

11. **Non-free resources are torn down at the end of the same working session.**
    Azure bills per resource-hour, not per operation — `create`/`delete` are free but every hour the resource exists costs money.
12. **Same-day teardown default:**
    ```powershell
    az group delete --name rg-cpgitops-<env>-<region> --yes --no-wait
    ```
    (State SA in `rg-cpgitops-tfstate` stays intact.)
13. **Safe to leave running** (free / effectively free at learning volume):
    Resource Group, VNet/Subnet/NSG/UDR, Log Analytics workspace with `daily_quota_gb` set,
    Storage Account (LRS, empty), Key Vault (standard), App Service F1.
14. **Cost-per-hour traps — always destroy same day, ideally same hour:**
    NAT Gateway, VPN Gateway, App Gateway v2, Bastion, Azure Firewall, Private Endpoints,
    Public IPs, App Service B1+, Load Balancer Standard.
15. **Set a Cost Management budget alert** on the subscription (~$5/month, alerts at 50/80/100%) — it's free.
