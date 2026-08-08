# Terraform Interview Master — Q&A

Consolidated & deduplicated from:

- K21 Academy — [Top 70 Terraform Interview Questions and Answers (2026)](https://k21academy.com/terraform/terraform-interview-questions/)
- DataCamp — [Top 21 Terraform Interview Questions (2026)](https://www.datacamp.com/blog/terraform-interview-questions)
- Nidhi Ashtikar (Medium) — [Terraform Interview Prep: 51 Q&A](https://nidhiashtikar.medium.com/terraform-interview-prep-51-key-questions-and-answers-89adc1542fbe)

Answers are rewritten short/accurate (many upstream answers are outdated — e.g. `terraform taint` was removed in 1.0; corrections are noted inline). Where a concept is already implemented in this repo, it's linked so you can point to it in the interview.

Use this file as a self-quiz: read the question, answer aloud, then check.

---

## 1. Fundamentals

**Q1. What is Terraform?**
Open-source IaC tool by HashiCorp. You declare desired infrastructure state in HCL; Terraform computes a plan, then reconciles real resources to match. Cloud-agnostic — same workflow across AWS/Azure/GCP/on-prem via **providers**.

**Q2. What is IaC and why does it matter?**
Managing infrastructure through version-controlled, machine-readable files instead of clicks. Benefits: repeatability, peer review, drift detection, disaster recovery, environment parity.

**Q3. Declarative vs procedural?**
Terraform is **declarative** — you describe the end state, not the steps. Ansible is procedural (imperative tasks). Declarative is idempotent and lets Terraform diff current vs desired.

**Q4. Terraform vs CloudFormation?**
- Terraform: multi-cloud, HCL, external state (S3+DDB, TFC), open source.
- CloudFormation: AWS-only, JSON/YAML, AWS-managed state, free.
Pick Terraform for multi-cloud / vendor neutrality; CFN if you're all-in on AWS and want native integration.

**Q5. Terraform vs Ansible?**
Terraform provisions infrastructure (create VMs, VNets, DBs). Ansible configures inside the OS (packages, files, services). Complementary — Terraform stands up the box, Ansible configures it. Terraform tracks state; Ansible does not.

**Q6. Terraform vs Pulumi?**
Same problem (IaC with state), different language. Pulumi uses general-purpose languages (TS/Python/Go); Terraform uses HCL (DSL). HCL is simpler and easier to review; Pulumi is more expressive for complex logic.

---

## 2. Core workflow & commands

**Q7. The core workflow?**
**Write → Plan → Apply.** (Then destroy when done.)

**Q8. Essential commands?**
| Command | Purpose |
|---|---|
| `terraform init` | Download providers, initialize backend, install modules |
| `terraform fmt` | Canonical formatting (run before every commit) |
| `terraform validate` | Syntax + internal consistency (no cloud calls) |
| `terraform plan` | Show diff between state and config |
| `terraform apply` | Reconcile real infra to config |
| `terraform destroy` | Delete everything in state |
| `terraform output` | Print output values |
| `terraform show` | Human-readable state/plan |
| `terraform state <sub>` | Advanced state ops (`list`, `mv`, `rm`, `pull`, `push`) |
| `terraform import` | Bring existing resource under management |
| `terraform refresh` | Reconcile state file with real infra (deprecated as standalone flag; use `plan -refresh-only`) |
| `terraform graph` | Emit dependency DAG (Graphviz) |

**Q9. What does `terraform init` actually do?**
1. Initializes the **backend** (where state lives).
2. Downloads and installs **provider plugins** into `.terraform/providers/`.
3. Installs **child modules** into `.terraform/modules/`.
4. Writes `.terraform.lock.hcl` pinning provider versions.

Safe to re-run. Add `-upgrade` to bump providers within the constraint range.

**Q10. Difference: `plan` vs `apply`?**
`plan` is read-only and prints intended changes. `apply` executes them. In CI: `plan` on PR, `apply` on merge — enforced with required reviewers ([ADR 0002](../adr/0002-plan-on-pr-apply-on-merge.md)).

**Q11. `terraform validate` vs `terraform plan`?**
`validate` checks syntax and references locally, no cloud calls, no state read. `plan` talks to the provider and current state to compute a real diff.

**Q12. What is `.terraform.lock.hcl`?**
Provider dependency lock file (like `package-lock.json`). Pins exact provider versions and checksums so every machine/CI run installs identical plugins. Commit it.

---

## 3. State

**Q13. What is the state file?**
`terraform.tfstate` — JSON mapping of resource addresses in your config to real remote object IDs, plus attribute cache. Terraform needs it to compute diffs and detect drift.

**Q14. Why remote state?**
- Team collaboration (shared source of truth)
- **State locking** (prevents concurrent applies corrupting state)
- Encryption at rest
- Backups / versioning
Local state is fine for solo learning; never for teams.

**Q15. Remote backend options?**
- **Azure Storage** (this repo) — blob + lease-based locking
- AWS S3 + DynamoDB (S3 for state, DDB for lock)
- GCS
- Terraform Cloud / Enterprise

**Q16. What is state locking? Which backends support it?**
A mutex on the state file preventing two applies at once. Azure Storage uses **blob leases**; S3 needs a **DynamoDB** table; TFC has it built in. Without locking → race conditions → corrupted state.

**Q17. Detecting drift?**
`terraform plan` compares real infra to state. If someone edited a resource in the portal, plan shows a diff. Fix by (a) reverting the manual change, or (b) updating HCL to match reality and re-applying.

**Q18. How do you fix a corrupted state?**
- Blob versioning → roll back to prior version (this repo enables it on the state SA).
- `terraform state rm` / `import` to reconcile manually.
- Never edit `tfstate` by hand.

**Q19. `terraform state` subcommands?**
- `list` — show managed resources
- `show <addr>` — inspect one
- `mv` — rename / move (e.g., after refactor into a module)
- `rm` — stop managing (does not delete real resource)
- `pull` / `push` — download/upload raw state

**Q20. What does `terraform import` do? Limitations?**
Adds an existing real resource to state so Terraform can manage it. Since **1.5** you can also declare `import` blocks in HCL; **1.6+** can generate config with `plan -generate-config-out=…`. Limits: some resources unsupported; you still write HCL manually for older versions; risk of drift if HCL doesn't match real attributes.

---

## 4. Providers, modules, variables

**Q21. What is a provider?**
A plugin translating Terraform resource types into API calls for a platform (azurerm, aws, kubernetes, github, random…). Declared under `required_providers` with a version constraint — see [providers.tf](../../terraform/providers.tf).

**Q22. Provider aliases — when?**
Multiple configurations of the same provider (e.g., two Azure subscriptions, two AWS regions). Declare `provider "azurerm" { alias = "hub" }` and reference with `provider = azurerm.hub` on a resource.

**Q23. What are modules?**
Reusable, encapsulated bundles of resources with inputs (`variables`) and outputs. Every dir with `.tf` files is technically a **root module**; anything called via `module "x" { source = … }` is a **child module**. See [terraform/modules/log-analytics](../../terraform/modules/log-analytics).

**Q24. Ways to source a module?**
- Local path: `./modules/log-analytics`
- Terraform Registry: `hashicorp/consul/aws`
- Git: `git::https://github.com/org/repo.git//path?ref=v1.2.0`
- HTTP archive / S3 / GCS
Always **pin a version or ref**.

**Q25. Variable definition & precedence?**
Sources (highest to lowest): CLI `-var` / `-var-file`, `TF_VAR_*` env vars, `*.auto.tfvars`, `terraform.tfvars`, defaults in `variable` block.

**Q26. Variable types?**
Primitives (`string`, `number`, `bool`), collections (`list`, `set`, `map`), structural (`object`, `tuple`). Add `validation` blocks for guardrails. See [terraform-variables.md](./terraform-variables.md).

**Q27. Output variables — why?**
Expose values from a module to its caller, or from root state for consumption by other tooling (`terraform output -json`). Mark `sensitive = true` to redact from logs.

**Q28. Local values (`locals`)?**
Named expressions computed once, reused for readability — not inputs. See [locals.tf](../../terraform/locals.tf) for the CAF naming pattern.

**Q29. Data sources?**
Read-only queries to fetch info about existing resources (e.g., `data "azurerm_client_config" "current"`). Not managed by Terraform.

**Q30. `count` vs `for_each`?**
- `count = N` — list-indexed; adding/removing middle items reshuffles indices → risky.
- `for_each = toset([...]) / map` — key-indexed; stable identity, safer for real resources. Prefer `for_each`.

**Q31. Dynamic blocks?**
Programmatically generate nested blocks (e.g., multiple `ingress` rules) using `dynamic "ingress" { for_each = var.rules ... }`.

**Q32. Conditional expressions?**
Ternary: `var.env == "prod" ? "P1v2" : "F1"`.

---

## 5. Dependencies & lifecycle

**Q33. How does Terraform know resource ordering?**
Builds a **DAG** from resource references. If `resource B` uses `resource A`'s attribute, A is created first — an **implicit dependency**.

**Q34. `depends_on`?**
Explicit dependency for cases the graph can't infer (side-effects only, no attribute link). Use sparingly.

**Q35. `lifecycle` meta-arguments?**
- `create_before_destroy = true` — for zero-downtime replacements
- `prevent_destroy = true` — safety net against accidental deletion (fails plan if destroy is proposed)
- `ignore_changes = [tags]` — ignore drift on named attributes
- `replace_triggered_by = [...]` — force replace when a referenced value changes

**Q36. Tainted resources / forced replacement?**
`terraform taint`/`untaint` are **removed** (Terraform 1.0+). Modern equivalent: `terraform apply -replace="module.x.aws_instance.web"`.

**Q37. How to safely rename a resource?**
`terraform state mv <old_addr> <new_addr>` — updates state without destroying the real resource. Then update HCL.

---

## 6. Provisioners

**Q38. What are provisioners?**
Escape hatches to run commands after a resource is created (`local-exec`, `remote-exec`, `file`). **Last resort** — they break the declarative model and are non-idempotent. Prefer cloud-init, user-data, or a config-management tool.

**Q39. `local-exec` vs `remote-exec`?**
`local-exec` runs on the machine running Terraform. `remote-exec` runs on the target resource over SSH/WinRM.

**Q40. What is `null_resource`?**
A "no-op" resource whose only purpose is to attach provisioners or `triggers` that fire on value changes. Superseded in many cases by the `terraform_data` resource (1.4+).

---

## 7. Workspaces & environments

**Q41. What are Terraform workspaces?**
Named state slices within one backend/config. `terraform workspace new dev` gives a separate state file for the same code.

**Q42. When NOT to use workspaces?**
Complex multi-env / multi-subscription. Workspaces share the same code and backend key — divergent envs get messy. Prefer **directory-per-env** with separate `*.tfvars` and backend keys, which is the model this repo uses via [environments/](../../environments/).

---

## 8. Secrets & security

**Q43. How to handle secrets in Terraform?**
- Never hardcode
- Env vars: `TF_VAR_db_password`
- External store: **Key Vault** / **Vault** / **AWS Secrets Manager** via `data` source
- Mark variable/output `sensitive = true`
- Encrypt remote state at rest; restrict access

**Q44. Is `sensitive = true` enough?**
No — it only hides values from CLI output. The value is still stored **in plaintext** in the state file. Protect the state itself (encryption, RBAC, private endpoint).

**Q45. How does this repo authenticate to Azure from CI?**
GitHub OIDC federated credentials — no client secrets. See [ADR 0001](../adr/0001-oidc-over-secrets.md) and [runbooks/oidc-bootstrap.md](../runbooks/oidc-bootstrap.md).

---

## 9. Team collaboration & CI/CD

**Q46. What happens if two engineers apply at the same time?**
Without locking → state corruption. With a locking backend (AzureRM blob lease / DDB / TFC) → the second `apply` blocks until the first releases the lock.

**Q47. Standard CI/CD pattern?**
`plan` on PR (read-only, posts diff as comment), `apply` on merge to `main` — gated by required reviewers on a protected environment. Auth via OIDC. Fail the pipeline on `fmt`, `validate`, `tflint`, `tfsec`/`checkov`.

**Q48. How to run rolling / zero-downtime updates?**
- `create_before_destroy` for immutable replacement
- `for_each` across instances behind a load balancer, apply in slices
- Combine with health checks and blue/green at the LB level

**Q49. Recovering from a failed `apply`?**
1. Read the error — often a provider/API issue.
2. Re-run `plan`; Terraform is idempotent, partial state is fine.
3. If a resource is stuck, `-replace` it or `state rm` + `import`.
4. Roll back code via VCS; re-apply prior config.

**Q50. Terraform Cloud vs Enterprise?**
TFC = SaaS (HashiCorp-hosted): remote runs, state, VCS integration, policy. TFE = self-hosted TFC with private registry, SSO/SAML, air-gap options.

**Q51. What is Sentinel? Enforcement levels?**
Policy-as-code from HashiCorp (paid TFC/TFE). Runs between plan and apply.
- **Advisory** — warns, passes
- **Soft-mandatory** — fails, admin can override
- **Hard-mandatory** — fails, no override
Open-source alternative: **OPA / Conftest** or **Checkov**.

**Q52. What is Terragrunt?**
Third-party wrapper (gruntwork.io) that keeps configs DRY: shared backend config, per-env `terragrunt.hcl`, `run-all` across modules. Solves the "many envs, similar code" problem workspaces don't handle well.

---

## 10. Debugging & troubleshooting

**Q53. How do you enable Terraform debug logs?**
`TF_LOG=TRACE` (most verbose; also `DEBUG`, `INFO`, `WARN`, `ERROR`). Redirect with `TF_LOG_PATH=./tf.log`.

**Q54. Troubleshooting steps?**
1. `terraform validate` and `terraform fmt -check`
2. `terraform plan` — read the diff carefully
3. `TF_LOG=DEBUG terraform plan` for provider-level detail
4. `terraform state list` / `show` to inspect state
5. Check provider docs for the resource
6. `terraform graph | dot -Tpng` to visualize dependencies

**Q55. Common state pitfalls?**
- Deleting a `.tf` file removes it from *config* but not from state → resource lingers. Fix with `state rm` or actually destroy.
- Renaming without `state mv` → Terraform destroys + recreates.
- Editing state manually → checksum drift → don't.

---

## 11. Bonus: repo-specific talking points

Things you can point to as "here's how I did it in production-style":

- **OIDC-only auth** — no long-lived secrets ([ADR 0001](../adr/0001-oidc-over-secrets.md))
- **Plan on PR / apply on merge** with required reviewers ([ADR 0002](../adr/0002-plan-on-pr-apply-on-merge.md))
- **CAF naming + mandatory tags** enforced in `locals` ([ADR 0003](../adr/0003-caf-naming-and-mandatory-tags.md), [locals.tf](../../terraform/locals.tf))
- **Remote state on Azure Storage** with blob versioning + soft delete
- **Pinned everything**: `required_version`, `required_providers`, `.terraform.lock.hcl` committed
- **Directory-per-env** ([environments/](../../environments/)) instead of workspaces
- **Bicep parity** ([bicep/](../../bicep/)) — same resource in two IaC tools for comparison

---

## Suggested drill order

1. Fundamentals + workflow (§1–2) — day 1
2. State (§3) — most-asked topic
3. Modules/variables/data (§4)
4. Lifecycle + dependencies (§5)
5. Secrets, CI/CD, collaboration (§8–9)
6. Debugging + repo talking points (§10–11)

Ask me to run you through any section as **mock interview** — I'll fire questions, you answer, I'll grade + explain gaps.

---

📝 This document was drafted with the help of an AI assistant (GitHub Copilot) and reviewed by the repo owner.
