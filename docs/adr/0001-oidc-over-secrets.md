# ADR-0001: Use OIDC federated credentials, not service principal secrets

- **Status:** Accepted
- **Date:** 2026-07-25
- **Deciders:** Repo owner

## Context

CI (GitHub Actions) needs to authenticate to Azure to run `terraform apply` and eventually `bicep deploy`. Historically this was done with a service principal client_id + client_secret stored as a GitHub Actions secret.

Problems with the secret-based approach:
- Long-lived credential sitting at rest in GitHub — leak risk (logs, forks, misconfigured workflows).
- Rotation is a manual chore, so in practice secrets are rarely rotated.
- Revocation is coarse — the whole SP dies.
- No per-branch / per-environment scoping — any workflow with `secrets.` access gets the full blast radius.

## Decision

Use **GitHub OIDC + Entra federated credentials**:

1. Create a single Entra app registration (`cpgitops-github-oidc`) with a service principal.
2. Attach **federated credentials** to the app — each is a trust rule that says "accept OIDC tokens from GitHub whose `sub` claim matches this exact pattern."
3. In the workflow, `azure/login@v2` exchanges the GitHub OIDC token for an Azure AD access token. No stored secret involved.
4. Grant RBAC to the service principal, scoped as narrowly as practical (Contributor on subscription for now; Storage Blob Data Contributor on the state SA only).

Registered federated subjects:
- `repo:mpattar0@<orgId>/cloud-platform-gitops@<repoId>:ref:refs/heads/main`
- `repo:...:pull_request`
- `repo:...:environment:dev`
- `repo:...:environment:prod`

## Consequences

**Positive**
- No secrets in the repo. Ever. `gitleaks` and Vault Radar have nothing to find.
- Tokens are short-lived (~10 min) and per-run — leaking one is functionally impossible and useless.
- Fine-grained trust — a workflow running for a PR from a fork cannot get a token for `main`.
- Aligns with GitHub + Microsoft security guidance and CIS benchmarks.

**Negative / trade-offs**
- Bootstrap is more involved (must create the SP, RBAC, and 4 FICs before any CI works). Documented in [`docs/runbooks/oidc-bootstrap.md`](../runbooks/oidc-bootstrap.md).
- Immutable-subject format (org ID + repo ID) is required by new Entra tenants and is not obvious — first-time setups typically hit auth errors until this is fixed.
- Local development still uses `az login` (interactive). Fine for a one-person repo; in an enterprise you'd use short-lived workload identity for humans too.

## Alternatives considered

- **SP client_id + client_secret in GitHub Secrets** — rejected (see Context).
- **Managed identity on a self-hosted runner** — overkill and defeats the point of free hosted runners.
- **Wildcard federated credential** (`claims_matching_expression`) — newer, less portable across tenants, harder to audit. Rejected in favor of explicit per-scenario FICs.

## References

- [Runbook: `docs/runbooks/oidc-bootstrap.md`](../runbooks/oidc-bootstrap.md)
- [GitHub docs: About security hardening with OpenID Connect](https://docs.github.com/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect)
- [Microsoft docs: Workload identity federation](https://learn.microsoft.com/entra/workload-id/workload-identity-federation)

---

<sub>📝 This document was drafted with the help of an AI assistant (GitHub Copilot) and reviewed by the repo owner.</sub>
