# Copilot Instructions — cloud-platform-gitops

This repository is a **personal learning / interview-prep** project running on a
**pay-as-you-go Azure subscription**. Cost control is a hard requirement.

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
