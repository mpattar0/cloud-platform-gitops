# Terraform Variables — Interview Prep

Repo reference: [terraform/variables.tf](../../terraform/variables.tf)

Goal: master `variable`, `locals`, `output`, precedence, validation, and the
common traps. Practice section at the bottom — do the drills, don't just read.

---

## 1. Core concepts

**Q: What are the three variable "kinds" in Terraform?**

- **Input variables** (`variable {}`) — parameters to a module. Set via CLI
  (`-var`), `.tfvars`, env vars (`TF_VAR_name`), or defaults.
- **Local values** (`locals {}`) — computed constants inside a module, not
  overridable from outside. Use for DRY expressions (naming, tags).
- **Output values** (`output {}`) — return values from a module, consumed by
  the parent module or via `terraform output`.

**Q: `variable` vs `locals` — when to use which?**

- Variable: value comes from **outside** the module (user, CI, parent module).
- Local: value is **derived** inside the module.
- Rule of thumb: if it never changes per-caller, it's a local, not a variable.

---

## 2. Precedence order (lowest → highest)

1. Environment defaults (`variable {}` block `default`)
2. `terraform.tfvars` / `terraform.tfvars.json`
3. `*.auto.tfvars` (loaded alphabetically — later files win)
4. `-var-file` (CLI, in order given)
5. `-var` (CLI, in order given) ← **highest**

`TF_VAR_foo` env vars sit **between** defaults and tfvars.

---

## 3. Types & validation

**Q: What types does Terraform support?**

- Primitives: `string`, `number`, `bool`
- Collections: `list()`, `set()`, `map()`, `tuple()`, `object()`
- Special: `any`, `null`

**Q: Why the `validation {}` block?**

Fails at `terraform plan`, before hitting Azure APIs. Catches typos
(e.g. `westus3` when only `eastus` is allowed) and enforces org policy
(naming rules, allow-lists). Much faster feedback than an ARM 400.

**Q: What's `sensitive = true`?**

Marks the value so it's redacted in plan/apply output and error messages.
It does **not** encrypt it in state — sensitive values still land in
`terraform.tfstate` in plaintext. That's why state must live in a locked,
RBAC-protected backend.

**Q: `nullable = false` vs setting a `default`?**

- `nullable = false` — caller cannot pass `null`; must supply a value or
  accept the default.
- Removing `default` — the value is **required**; Terraform errors if not
  provided.

---

## 4. The `environment` pattern (used in this repo)

**Q: Why does `environment` have no default in `variables.tf`?**

Prevents "guess which env I'm in" accidents. Every `plan`/`apply` must be
explicit — `-var environment=dev` or a `dev.tfvars` file. Enterprise pattern
to prevent apply-to-prod-by-mistake.

**Q: How would you scale this for 10+ envs?**

1. **`.tfvars` per env** (what we're doing): `envs/dev.tfvars`, `envs/prod.tfvars`.
   Same root, separate state keys per env.
2. **Terragrunt** or a wrapper: one root, N environments, DRY via
   `terragrunt.hcl`. Overkill for 2 envs; standard at scale.

---

## 5. Sensitive / secret handling

**Q: How do you pass secrets to Terraform without committing them?**

- `TF_VAR_db_password` env var in CI (from GitHub secret).
- `data "azurerm_key_vault_secret"` — fetch at plan time (still lands in state).
- **Best:** don't manage secrets in Terraform at all. Create the Key Vault +
  secret *slot*; let the app read the secret at runtime.

**Q: If a secret ends up in state, what protects it?**

The **state backend**: Azure Storage with `use_azuread_auth`, private endpoint
in real prod, RBAC-scoped data-plane role, blob versioning, soft delete, no
shared keys. State is a secret file — treat it like one.

---

## 6. Traps interviewers love

**Q: Can a variable reference another variable?**

**No.** `variable` blocks can only reference `var.*` in the `validation` block
(from TF 1.9+, cross-variable validation). The `default` cannot reference
other variables. Use `locals` for derived values.

**Q: What happens if two `.auto.tfvars` files define the same variable?**

Loaded alphabetically; last one wins. Silent override — a subtle CI gotcha.

**Q: `count` vs `for_each` for optional resources driven by a variable?**

Prefer `for_each` (map/set) — stable resource addresses. `count = var.enable ? 1 : 0`
works but re-orders resources if you later add another toggle, causing
destroy/recreate churn.

**Q: What's the "unknown values in count/for_each" trap?**

`count` and `for_each` must be known at plan time. If they depend on an
unknown value (e.g. a resource attribute created in the same apply), plan
fails with "The 'count'/'for_each' value depends on resource attributes that
cannot be determined until apply". Fix: use `-target` for the upstream
resource first, or restructure with `depends_on` + hard-coded keys.

**Q: What's the difference between `map(string)` and `object({...})`?**

- `map(string)` — homogeneous keys, all values same type.
- `object({name=string, size=number})` — heterogeneous, typed per field.
  Use `object` when the shape matters; `map` for arbitrary key-value bags
  like tags.

**Q: Why is `list` different from `set`?**

- `list` — ordered, allows duplicates, indexed by position.
- `set` — unordered, no duplicates, indexed by value.
- `for_each` requires `set(string)` or `map` (needs stable keys). `count`
  uses a `list` (ordered).

---

## 7. Hands-on practice drills

Do these against this repo. Answers/verification commands included.

### Drill 1 — Precedence

Create `dev.auto.tfvars` in `terraform/`:

```hcl
environment = "dev"
prefix      = "cpgitops"
```

Then run:

```powershell
terraform console
> var.environment
> var.prefix
```

Now override on the CLI:

```powershell
terraform plan -var environment=prod
```

Expected: `environment` shows `prod` in plan output (CLI beats `.auto.tfvars`).

### Drill 2 — Validation

Try to break the `location` validation:

```powershell
terraform plan -var environment=dev -var location=westus3
```

Expected: plan fails with your custom error message, before any Azure call.

### Drill 3 — Locals vs variables

Add to `main.tf`:

```hcl
locals {
  name_prefix = "${var.prefix}-${var.environment}"
  tags = {
    env        = var.environment
    workload   = var.prefix
    owner      = var.owner
    costCenter = var.cost_center
    managedBy  = "terraform"
  }
}
```

In `terraform console`:

```
> local.name_prefix
> local.tags
```

Try to override `local.name_prefix` from CLI — you can't. That's the point.

### Drill 4 — Sensitive

Add a temporary variable:

```hcl
variable "fake_secret" {
  type      = string
  default   = "hunter2"
  sensitive = true
}

output "leak_test" {
  value     = var.fake_secret
  sensitive = true
}
```

Run `terraform plan`. Expected: value shown as `(sensitive value)`.
Remove `sensitive = true` from the **output** — plan now leaks it. Lesson:
sensitive flag must propagate through outputs too.

### Drill 5 — TF_VAR env var

```powershell
$env:TF_VAR_environment = "dev"
terraform plan
Remove-Item Env:\TF_VAR_environment
```

Expected: plan uses `dev` without `-var`. Confirms env-var path.

### Drill 6 — Type coercion

Add:

```hcl
variable "port" {
  type    = number
  default = "8080"   # string, not number
}
```

Run `terraform validate`. Terraform will **auto-coerce** the string `"8080"`
to number `8080`. Now try `default = "not-a-number"` → validate fails.

### Drill 7 — Object type

```hcl
variable "app" {
  type = object({
    name = string
    sku  = string
    port = number
  })
  default = {
    name = "web"
    sku  = "F1"
    port = 80
  }
}
```

Remove `port` from the default → `terraform validate` fails: "attribute
`port` is required". Shows object types enforce shape.

---

## 8. One-liners to memorise

- "Variables come from outside the module, locals are derived inside, outputs
  expose values to the parent."
- "Precedence: CLI `-var` beats `-var-file` beats `.auto.tfvars` (alpha order)
  beats `terraform.tfvars` beats `TF_VAR_*` env beats block default."
- "`validation` runs at plan time — fail fast before touching cloud APIs."
- "`sensitive = true` redacts output but does **not** encrypt state. Protect
  state at the backend."
- "Never let a variable's default reference another variable — that's what
  `locals` are for."
- "Prefer `for_each` over `count` for optional resources — stable addresses,
  no destroy/recreate churn on reorder."

---

## 9. Further reading

- [Terraform: Input Variables](https://developer.hashicorp.com/terraform/language/values/variables)
- [Terraform: Local Values](https://developer.hashicorp.com/terraform/language/values/locals)
- [Terraform: Custom Conditions](https://developer.hashicorp.com/terraform/language/expressions/custom-conditions)
- [Terraform: Sensitive Data in State](https://developer.hashicorp.com/terraform/language/state/sensitive-data)
