# ADR-0003: CAF naming convention + 5 mandatory tags

- **Status:** Accepted
- **Date:** 2026-08-06
- **Deciders:** Repo owner

## Context

Every Azure resource needs a name and a set of tags. Without a convention:
- Names drift (`kv-prod-eastus` vs. `kv-cpgitops-eastus2-prod`) — hard to script, grep, or audit.
- Tags are inconsistent or missing — cost reports break, incident routing is impossible, cleanup scripts nuke the wrong thing.

An enterprise landing zone would enforce both via Azure Policy. This repo is smaller, but we want to be Policy-ready.

## Decision

### Naming — CAF convention

Every generated resource name follows Microsoft's Cloud Adoption Framework abbreviations:

```
{type}-{prefix}-{env}-{regionShort}
```

- `type` — CAF abbreviation (`rg`, `kv`, `log`, `asp`, `app`, `st`, …).
- `prefix` — workload short name (`cpgitops`), from `var.prefix`.
- `env` — `dev` or `prod`, from `var.environment`.
- `regionShort` — mapped from `var.location` (`eastus` → `eus`).

Names are built once in `terraform/locals.tf` under `local.names.*` and referenced everywhere. No resource block ever hardcodes a name.

Storage Account names skip the dashes and lowercase to satisfy the 3-24 alphanumeric rule (`stcpgitopsdeveus`).

Two `check` blocks in `locals.tf` fail `terraform plan` early if a generated name would exceed Azure's per-type limits (Key Vault ≤ 24 chars, Storage Account 3-24).

### Tags — 5 mandatory

Every resource gets `local.common_tags`:

| Tag | Purpose |
|---|---|
| `env` | `dev` / `prod`. Cost slicing, policy targeting. |
| `workload` | Workload attribution. |
| `owner` | Incident routing / accountability. |
| `costCenter` | Chargeback / cost report grouping. |
| `managedBy` | Always `terraform` — detects ClickOps drift. |

## Consequences

**Positive**
- One place to update — change the convention, everything follows.
- Grep-friendly (`az resource list --tag env=dev`, `az group list --query "[?tags.workload=='cpgitops']"`).
- Ready for an Azure Policy `require-tags` (planned in PR #9) — the policy will be a rubber stamp, not a change.
- `check` blocks give a friendly plan-time error instead of a cryptic Azure API rejection at apply time.

**Negative / trade-offs**
- `var.prefix` is length-constrained (10 chars max) because Key Vault names cap at 24. Acceptable for a single-workload repo.
- Region-short map has to be kept in sync with the `location` variable's allow-list — encoded in comments in both files.
- If the workload ever splits into sub-workloads, the naming scheme needs a `{sub_workload}` slot; would be an ADR-0003a amendment.

## Alternatives considered

- **Free-form names + tags** — rejected: guarantees inconsistency.
- **Random suffixes** (`random_id`) for global-unique resources — deferred. Overkill for single-tenant learning; will revisit if we hit collisions on storage account names.
- **`azurecaf_name` provider** — nice, but adds a third-party provider dependency for a single-file benefit. Local `format`/`replace` is clearer.

## References

- [Microsoft CAF: Recommended abbreviations for Azure resource types](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
- [`terraform/locals.tf`](../../terraform/locals.tf)
- [`.github/copilot-instructions.md`](../../.github/copilot-instructions.md) — encodes both naming and tag rules

---

<sub>📝 This document was drafted with the help of an AI assistant (GitHub Copilot) and reviewed by the repo owner.</sub>
