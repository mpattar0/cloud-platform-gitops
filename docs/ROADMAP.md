# Mastery Roadmap

> Living document. Version-controlled — this is the durable source of truth for
> the long-term learning goal. Day-to-day PR tracking lives in `PROGRESS.md`
> (gitignored, local only).

---

## 🎯 North-star

**Become interview-ready as a senior Cloud / Integration / DevOps engineer on the Microsoft Azure stack, with Terraform + GitHub Actions as the primary automation toolchain.**

Success = I can walk into a senior interview and, for any topic below, either:

1. Point to code I wrote in this repo, **or**
2. Explain the design tradeoffs aloud in interview-quality language, **or**
3. Both.

**Non-goals:** exam certifications (may pursue separately), multi-cloud (AWS/GCP), Kubernetes deep-dive (separate track).

---

## 📚 Three parallel mastery tracks

Track A, B, C run in parallel. Each PR in `PROGRESS.md` advances **at least one** track — usually all three.

### Track A — GitHub Actions
### Track B — Terraform
### Track C — Azure services (breadth + depth)

Progress bar per topic uses:

- `[ ]` — not started
- `[~]` — in progress / partially covered
- `[x]` — mastered (built + can defend in interview)

---

## Track A — GitHub Actions mastery

### A1. Workflow fundamentals
- [x] `on:` triggers — `push`, `pull_request`, `workflow_dispatch`, `schedule`
- [x] Jobs, steps, `runs-on`, `needs`, `if`
- [x] Matrix strategy (`strategy.matrix`)
- [x] Reusable env: `env:` block
- [ ] Reusable workflows (`workflow_call`) — one workflow that others reuse
- [ ] Composite actions (`action.yml` under `.github/actions/`)
- [ ] Container jobs (`container:`)
- [ ] Self-hosted runners (concept only — no ops overhead in learning repo)

### A2. Security
- [x] OIDC federated credentials → Azure (no long-lived secrets)
- [x] Least-privilege `permissions:` block per workflow
- [x] Environment protection rules + required reviewers
- [x] `vars.` vs `secrets.` (identifiers vs secrets)
- [ ] SHA-pinned actions vs tag-pinned (repo prefers tags for readability)
- [ ] GitHub Advanced Security — CodeQL, secret scanning, dependency review
- [ ] Signed commits, verified releases

### A3. CI/CD patterns
- [x] Plan-on-PR / apply-on-merge for Terraform
- [x] Nightly `schedule:` for destroy
- [x] Concurrency groups (shared across workflows for state serialization)
- [x] `workflow_dispatch` inputs (choice, string) with confirmation guards
- [ ] Multi-env promotion — `dev` → `stage` → `prod` with sequential gates
- [ ] Slash-command triggers (`/plan`, `/apply` PR comments)
- [ ] Artifact upload/download (`actions/upload-artifact`, `actions/download-artifact`)
- [ ] Cache (`actions/cache`) for Terraform providers + tflint plugins

### A4. Observability
- [ ] Step summaries (`$GITHUB_STEP_SUMMARY` markdown output)
- [ ] Job outputs → downstream job inputs
- [ ] `actions/github-script` for PR comments / labels / status
- [ ] Custom status badges in README

### A5. Advanced
- [ ] Environments as approval gates for prod
- [ ] Deployment protection rules (branch policies)
- [ ] Reusable workflow library (call from other repos)

---

## Track B — Terraform mastery

### B1. Core language
- [x] Providers, resources, data sources
- [x] Variables, locals, outputs
- [x] `count` vs `for_each` (map keys for stable identity)
- [x] Conditional expressions, `dynamic` blocks
- [x] Type constraints — `object`, `map`, `list`, `set`, `tuple`
- [x] Validation blocks (with RE2 regex constraint)
- [x] Module inputs/outputs (pure-function pattern)
- [~] Complex `for` expressions with filtering + splat — VNet module uses filtered maps and nested `for` expressions; splat practice remains
- [ ] `templatefile()` for scripts / cloud-init
- [ ] `sensitive` marking on outputs

### B2. State
- [x] Remote backend on Azure Storage (blob-lease locking)
- [x] Blob versioning + soft delete for state DR
- [x] `terraform state list / show / mv / rm`
- [ ] `terraform import` (bring existing resource into state)
- [ ] `terraform apply -replace` (formerly `taint`)
- [ ] Cross-state reads (`terraform_remote_state` data source)
- [ ] State migration between backends
- [ ] `terraform state pull` + surgical edits for corruption recovery

### B3. Modules
- [x] Directory-per-module (`terraform/modules/*/`)
- [x] Version pinning inside module (`versions.tf`)
- [x] Enterprise-shaped SKU variables (cheap default, prod-code override)
- [ ] Module versioning via git tags (`source = "git::...?ref=v1.2.0"`)
- [ ] Module composition — modules calling other modules
- [ ] Public module registry publish (interview signal)

### B4. Workflows & environments
- [x] Directory-per-env `environments/team-*/dev.tfvars`
- [ ] `terraform workspace` (know when NOT to use it — interview trap)
- [ ] Environment-specific backend config (`init -backend-config`)
- [ ] Terragrunt (concept only — know the DRY problem it solves)

### B5. Testing & quality
- [ ] `terraform fmt -check` in CI
- [ ] `terraform validate` in CI
- [ ] `tflint` with Azure ruleset
- [ ] `tfsec` / `checkov` security scanning
- [ ] `terratest` (Go-based integration tests) — one module at least
- [ ] `terraform test` (native v1.6+ testing framework)

### B6. Advanced
- [ ] Custom providers (concept only — Go)
- [ ] Provider aliases (multi-subscription / multi-region)
- [ ] `moved` blocks for refactoring without destroy
- [ ] `check` blocks for post-apply assertions
- [ ] `terraform_data` (replacement for `null_resource`)
- [ ] Sentinel / OPA policy-as-code (concept only)

---

## Track C — Azure services

Grouped by role in an enterprise system. Ordered by how often each shows up in interviews.

### C1. Foundational (must know cold)
- [x] Resource Group
- [x] Log Analytics Workspace (PerGB2018, quota, retention)
- [x] Key Vault (RBAC-auth, purge protection, soft delete)
- [ ] Storage Account (LRS/ZRS/GRS tradeoffs, blob/queue/table/file)
- [ ] Managed Identity (system-assigned vs user-assigned)
- [ ] RBAC + Azure AD (role definitions, role assignments, scope hierarchy)
- [ ] Application Insights (workspace-based, sampling, connection strings)

### C2. Networking
- [~] Virtual Network + Subnet (address planning, delegation) — deployed via CI; delegation and interview practice remain
- [~] Network Security Group + rules (priority, direction, service tags) — optional subnet NSGs and inbound deny deployed; rule tradeoffs and service tags still need practice
- [ ] Private DNS zones + linking
- [ ] Service Endpoints (free VNet lockdown)
- [ ] Private Endpoints (paid, prod pattern)
- [ ] Route tables + UDRs (concept only)
- [ ] Application Gateway v2 (WAF, backend pools) — deploy-demo-teardown
- [ ] Front Door Standard (concept + cost profile)
- [ ] NAT Gateway (concept — expensive)
- [ ] VNet Peering (concept + design tradeoffs)

Evidence checked 2026-09-10: roadmap PR #4 shipped as
[GitHub PR #16](https://github.com/mpattar0/cloud-platform-gitops/pull/16),
merged 2026-08-12, with a successful
[CI apply (dev)](https://github.com/mpattar0/cloud-platform-gitops/actions/runs/31580515333).
This proves implementation, not completed interview mastery or current live infrastructure.

### C3. Messaging & events (enterprise integration core)
- [ ] Service Bus namespace (Basic/Standard/Premium tradeoffs)
- [ ] Service Bus queue
- [ ] Service Bus topic + subscription + rules
- [ ] Service Bus sessions (FIFO, ordered processing)
- [ ] Dead-letter queues + retry policy
- [ ] Storage Queue (simpler alternative — know when to pick which)
- [ ] Event Grid — system topics vs custom topics
- [ ] Event Grid subscriptions (webhook, Function, Logic App, Service Bus)
- [ ] Event Hub namespace + hubs (Kafka-compatible)
- [ ] Event Hub consumer groups + partitions
- [ ] Change Feed patterns (Cosmos, Blob) — concept only

### C4. Compute (serverless-first)
- [ ] Function App Consumption (Y1) — cold starts, scaling
- [ ] Function App Premium (EP1) — pre-warmed, VNet integration
- [ ] Function triggers — HTTP, Queue, Timer, EventGrid, ServiceBus, EventHub
- [ ] Function bindings — input/output patterns
- [ ] App Service Plan (F1 → P1v3 tier ladder)
- [ ] App Service — HTTPS-only, TLS 1.2, custom domain
- [ ] Deployment slots (blue/green pattern)
- [ ] Container Apps (concept + cost profile)
- [ ] AKS (out of scope for this repo — separate track)

### C5. Workflow / low-code
- [ ] Logic Apps Consumption — trigger + action model
- [ ] Logic Apps Standard — hosted on App Service Plan, VNet integration
- [ ] Managed connectors (SFTP, Salesforce, SAP, SQL)
- [ ] API Connections (`azurerm_api_connection`)
- [ ] Stateful vs stateless workflows
- [ ] Concurrency + throttling

### C6. API management
- [ ] APIM Consumption vs Developer vs Standard v2 vs Premium
- [ ] API + Operation + Product + Subscription hierarchy
- [ ] Policy chain — inbound, backend, outbound, on-error
- [ ] JWT validation policy (AAD-issued tokens)
- [ ] Rate-limit + quota policies
- [ ] Named Values (KV-backed secrets)
- [ ] Backends (Function App, Logic App via MI)
- [ ] Developer portal customization
- [ ] Self-hosted gateway (concept)

### C7. Data + storage
- [ ] Blob Storage — access tiers (hot/cool/archive), lifecycle policies
- [ ] Table Storage vs Cosmos DB tradeoffs
- [ ] Azure SQL — Serverless tier, elastic pools
- [ ] Cosmos DB — serverless mode, RUs, consistency levels
- [ ] Cache — Redis Basic C0 vs Enterprise
- [ ] Azure Data Factory (concept only)

### C8. Observability
- [ ] Diagnostic settings (RG, KV, SB, Function, APIM — all to LA)
- [ ] KQL queries — basic + join + summarize
- [ ] Log Analytics workbooks (dashboards)
- [ ] Alerts (metric-based + log-based)
- [ ] Action groups (email, webhook, Function)
- [ ] Application Insights — request/dependency/exception tracking
- [ ] Distributed tracing (OpenTelemetry via App Insights)
- [ ] Cost Management + budget alerts

### C9. Governance & security
- [ ] Azure Policy — built-in + custom policy definitions
- [ ] Policy assignments (scope + parameters)
- [ ] Policy remediation tasks
- [ ] Management groups (concept)
- [ ] Blueprints (deprecated — know why)
- [ ] Defender for Cloud (free tier only)
- [ ] Resource locks (`ReadOnly`, `CanNotDelete`)
- [ ] Tag policies (require + inherit)

### C10. Identity
- [ ] Azure AD tenant + directory objects
- [ ] Service principals + app registrations
- [ ] Federated credentials (already used for OIDC)
- [ ] Groups + role-assignable groups
- [ ] Conditional Access (concept only)
- [ ] Privileged Identity Management — PIM (concept only)

---

## 🎓 Cert-004 objective coverage

Secondary goal: fully cover **HashiCorp Terraform Associate (004)** exam
objectives (Terraform 1.12) as a lens over the mastery roadmap — not a
parallel workstream. Reference:
[associate-study-004](https://developer.hashicorp.com/terraform/tutorials/certification-004/associate-study-004).

Tick to ✅ **only** when a merged PR contains runnable evidence (code, workflow,
or runbook with output).

| # | Objective | Status | Evidence / gap |
|---|---|---|---|
| 1 | Explain IaC concepts | ✅ | `README.md`, ADRs 0001–0003, cost-driven module design |
| 2 | Terraform's purpose (providers, state, versioning, lock file) | ✅ | `providers.tf` pinned `required_version`/`required_providers`, remote state on Azure Storage, `.terraform.lock.hcl` committed |
| 3 | Core Terraform workflow (`init`/`fmt`/`validate`/`plan`/`apply`/`destroy`) | ✅ | Local `fmt`/`validate`/`plan`; CI apply-on-merge + nightly destroy workflows |
| 4 | Read + write configuration | 🟡 | Have: `for_each`, `dynamic`, validation regex, locals, outputs, type constraints; merged VNet module (GitHub PR #16) adds filtered/nested `for` expressions and custom CIDR validation on complex subnet inputs. **Gap:** `templatefile()`, `sensitive = true` outputs, `check` blocks |
| 5 | Use + create modules | 🟡 | Have: 5 local modules with inputs/outputs, pinned `versions.tf`. **Gap:** consume a registry module, git-tag versioning (`?ref=v1.0.0`), module composition (module calling module) |
| 6 | State management | 🟡 | Have: remote backend, blob-lease locking, `state list/show/mv/rm`. **Gap:** `terraform import`, `terraform apply -replace`, `moved` blocks, `terraform_remote_state`, backend migration, refresh-only mode |
| 7 | Maintain infrastructure | 🟡 | Have: state CLI basics. **Gap:** hands-on `import` + `-replace` on real resources, `TF_LOG` debugging session, troubleshooting runbook (planned PR #25) |
| 8 | HCP Terraform | ❌ (out of scope) | Deliberate: using OSS + Azure Storage backend. Document as ADR (planned) with the tradeoff rationale — the exam still tests concepts, so re-read the HCP section before sitting |

**Score:** 3 ✅ / 4 🟡 / 1 ❌ (out of 8).

**High-leverage gap-closer PRs** (each flips one objective to ✅):

- **Objective 4** — add `sensitive = true` to KV outputs + a `check` block asserting KV RBAC mode; small commit on existing module
- **Objective 5** — refactor one module to consume a public registry module (e.g. `Azure/naming/azurerm`) with a pinned version
- **Objective 6 + 7** — PR #25 runbook must actually run `import`, `-replace`, and demonstrate a `moved` block on real dev resources (not just describe them)

---

## 🧭 How to plan a study session

At the start of every session:

1. **Check `PROGRESS.md`** — what's the current PR?
2. **Cross-reference this roadmap** — what tracks does that PR advance?
3. **Pick one focused goal** — e.g. *"today: tick B2 import + replace by using them on the real dev stack"*
4. **Do 15-30 min of drill / reading** on the relevant interview questions in [terraform-master-qa.md](interview/terraform-master-qa.md) before writing code
5. **Write the code / commit / push / merge / verify**
6. **Update `PROGRESS.md` + tick the roadmap boxes**

Rough session cadence (part-time, 1 hr/day):

- **Every session:** advance current PR
- **Every 3rd session:** revisit an earlier topic and try to explain it aloud without notes (real interview simulation)
- **Every 5th session:** write a runbook / ADR / README section — communication practice
- **Weekly:** re-read your top 3 weakest topics in this roadmap

---

## 🎓 Interview signal at each phase

| End of Phase (see `PROGRESS.md`) | Tracks progressed | Roles I can credibly interview for |
|---|---|---|
| Phase 2 | A1–A3, B1–B3, C1, C8 | Junior DevOps / Cloud Engineer |
| Phase 3 | +C3 | Integration Engineer (Azure) |
| Phase 4 | +C4, C5 | Mid-level Cloud Engineer / Integration Dev |
| Phase 5 | +C6 | Senior Integration Engineer / API Platform Engineer |
| Phase 6 | +C2, +C10 | Senior Cloud Engineer / Solutions Architect (Associate) |
| Phase 7 | +B5, +C9 | Staff Engineer / Solutions Architect |

---

## 🚫 What's deliberately excluded from this repo

Not because they're unimportant — because they're separate tracks:

- **AKS / Kubernetes** — deserves its own repo + curriculum
- **Multi-cloud (AWS, GCP)** — after Azure is solid
- **Data engineering** (Synapse, Fabric, Databricks) — separate track
- **AI/ML services** (OpenAI, ML Studio, AI Search) — separate track
- **Windows Server / VM administration** — legacy, out of scope for cloud-native
- **Certification exam prep** — parallel activity, uses this repo as evidence

---

## 📝 How this file is used

- **Copilot Chat** — reads this on every turn (see `.github/copilot-instructions.md`) and plans the day
- **You** — use it as the master checklist; tick items only when you can defend them in an interview
- **Interviewers** — you can share the raw file link as evidence of structured self-study

---

📝 This document includes AI-assisted drafting and updates (GitHub Copilot). The 2026-09-10 progress reconciliation is pending repo-owner review.
