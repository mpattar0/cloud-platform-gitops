# Terraform Interview Scenarios

Independent, hands-on interview exercises in the same repository. Add one task
at a time; write the solution yourself before reviewing it with GitHub Copilot.

## Task index

| Task | Interview focus | Status |
| --- | --- | --- |
| [Task 001 — Count: identical configuration](task-001-count-identical/README.md) | Create three instances using one resource block; explain indexed identity | Scaffold only; solution not written |

Possible next exercises, to add individually when requested:

- `for_each` with identical settings and stable named identities.
- `for_each` with different configurations from a map.
- Removing an entry: numeric index shifting versus stable map keys.
- Variables, validation, conditionals, outputs, and module inputs.

## How tasks are organized

- One numbered task directory per question, using the naming pattern
  **task-NNN-short-description**.
- Each task directory is an independent Terraform root, with its own exercise
  brief and configuration. Reusing configuration filenames across directories
  is fine: Terraform selects a directory, not an individual file.
- Terraform combines all top-level `.tf` files in the selected directory.
  Sibling task directories are not loaded automatically.
- Run Terraform from the selected task directory, or select it with `-chdir`.
  Do not run an exercise from the integration stack's root.
- Tasks do not inherit the stack's variables, locals, provider configuration,
  or backend. Declare only the dependencies each exercise needs.

## Safety and cost rules

- Start with the built-in `terraform_data` resource. It does not provision cloud
  resources or require Azure credentials. **Azure cost: $0.**
- Never copy the integration stack's remote backend into a task or reuse its
  backend key. Each task must keep a separate state boundary.
- Local practice is limited to formatting, validation, and planning. Do not run
  local apply or destroy. Any future stateful demonstration needs a separately
  reviewed GitHub Actions workflow targeting only that task.
- A plan against empty state cannot prove deletion or replacement behavior.
  Those exercises require previously applied state and will be added separately.
- Do not commit generated state, saved plans, caches, or credentials. Commit
  dependency lock files when a task uses external providers.
- The current integration-stack workflows target the existing Terraform root.
  They are not task runners; do not dispatch them to try to execute an exercise.
- A task is not complete merely because its directory exists. Record actual
  validation/plan evidence and an interview explanation before updating status.
- These exercises reinforce roadmap topics; they do not mark roadmap PRs as
  merged or deployed.

## Practice cycle

1. Read the question and predict the expected plan.
2. Write the configuration yourself.
3. Format, validate, and inspect a plan in the selected task root.
4. Explain each expression and resource address aloud.
5. Record the result, mistakes, and a concise interview answer in the task notes.
6. Add the next task only when ready.

---

📝 This document was drafted with AI assistance (GitHub Copilot). Repo-owner review is pending.