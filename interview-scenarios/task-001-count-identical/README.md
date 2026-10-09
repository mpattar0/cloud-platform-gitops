# Task 001 — Three Instances with Identical Configuration

**Status:** Scaffold only; no solution, validation, or plan has been completed.

**Roadmap focus:** B1 — `count`, object values, outputs, and resource addresses.

**Supporting tool:** Built-in `terraform_data`; no external provider or cloud
resource is needed. **Azure cost: $0.**

## Interview question

> How would you create three instances of the same Terraform resource with
> identical configuration, without writing the resource block three times?

## Your task

Write the solution in this task directory, not in the integration stack.
The starter configuration currently contains comments only.

1. Declare compatibility with Terraform 1.15.x, matching the repository.
2. Declare exactly one `terraform_data` resource block, named `example`.
3. Use `count` to request three instances.
4. Give every instance the same `input` object:
   - `environment`: `dev`
   - `workload`: `orders`
5. Add an output named `instance_inputs` containing the three input objects.
   Use a `for` expression or a splat expression.
6. Do not add an Azure provider, credentials, or remote backend.

This resource has no cloud name to make unique. The three Terraform instances
are distinguished by their state addresses even though their inputs match.
Real cloud resources may also require distinct names.

## Predict before planning

- How many resources should a plan against empty state propose adding?
- What are their full Terraform addresses?
- Does `count.index` start at zero or one?
- Does an output create a fourth resource?
- What is the difference between one resource block and three resource instances?

## Acceptance criteria

- [ ] Configuration is restricted to this task root.
- [ ] Exactly one resource block requests three instances.
- [ ] All three instances have identical input values.
- [ ] Formatting and validation pass.
- [ ] A plan against empty state reports **3 to add, 0 to change, 0 to destroy**.
- [ ] The planned `instance_inputs` output contains three identical objects.
- [ ] No Azure resource is provisioned and no local apply/destroy is run.
- [ ] Explain the instance addresses and why `count` fits this exercise.

## Your evidence and interview notes

### Validation and plan result

Not recorded yet.

### Mistakes and corrections

Not recorded yet.

### Interview answer in your own words

Not written yet.

## References

- [HashiCorp: count](https://developer.hashicorp.com/terraform/language/meta-arguments/count)
- [HashiCorp: terraform_data](https://developer.hashicorp.com/terraform/language/resources/terraform-data)
- [HashiCorp: splat expressions](https://developer.hashicorp.com/terraform/language/expressions/splat)

---

📝 This document was drafted with AI assistance (GitHub Copilot). Repo-owner review is pending.