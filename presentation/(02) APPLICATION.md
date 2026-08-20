# How DevOps Applies to This Project

## Project summary

This project deploys a **Streamlit web application** to **AWS**, using a fully automated CI/CD pipeline. Every time changes are pushed to the `main` branch, GitHub Actions automatically:

1. Provisions the required AWS infrastructure (Terraform)
2. Installs and starts the application on that infrastructure (Ansible)

No manual steps (no clicking around the AWS Console, no manually SSHing in to install things) are required after the initial setup — that manual work has been replaced with automation, which is the core DevOps principle in practice.

## Why each tool was chosen

**Git / GitHub** — the project's source of truth. All application code, infrastructure definitions, and pipeline configuration live in one repository, version-controlled and reviewable.

**Terraform (Infrastructure as Code)** — instead of manually creating an EC2 instance and security group through the AWS Console, these are defined declaratively in `.tf` files:

- `terraform/main.tf` defines a **security group** (controls what network traffic is allowed in/out) and an **EC2 instance** (the virtual server the app runs on).
- Running `terraform apply` reads these files and creates exactly the infrastructure described — reproducibly, every time.

**Ansible (Configuration Management)** — once the EC2 instance exists, it's a bare server with nothing installed. Ansible connects over SSH and runs a **playbook** (`ansible/playbook.yml`) that:

- Installs Python and pip
- Copies the application code onto the server
- Installs Python dependencies
- Configures the app to run automatically as a background service (via `systemd`), so it starts on boot and restarts if it crashes

**GitHub Actions (CI/CD orchestration)** — ties Terraform and Ansible together into one automated pipeline (`.github/workflows/deploy.yml`), triggered automatically on every push to `main`. This is what actually makes it "continuous" — no one has to remember to run these steps manually.

**AWS Academy Learner Lab** — the cloud environment used to host the infrastructure. This is a sandboxed, temporary-credential AWS environment provided for learning purposes (see the note below on its specific constraints).

## A note on AWS Academy Learner Lab constraints

Learner Lab is not a normal AWS account, and this shaped some of the technical decisions in this project:

- **Temporary credentials**: Learner Lab issues an Access Key, Secret Key, and Session Token that expire every few hours. These are stored as GitHub Secrets and must be refreshed manually each session — in a production environment, this would instead use a persistent, more secure credential method (see "limitations" note below).
- **Restricted IAM permissions**: students cannot create new IAM roles or policies. The project uses Learner Lab's pre-existing `LabInstanceProfile` instead of creating a custom one.
- **SSH-based deployment over IAM-based deployment**: because of the IAM restriction, this project uses the SSH + Ansible deployment pattern (connecting directly to the server with a key pair) rather than an approach that would need custom IAM roles (e.g. using AWS Systems Manager).

## Limitations and what a production setup would do differently

Worth noting explicitly, since it demonstrates understanding of the trade-offs involved:

- **Static credentials in GitHub Secrets** are a security compromise made necessary by Learner Lab. A production pipeline would typically use **OIDC federation**, where GitHub Actions assumes an IAM role directly with no long-lived keys stored anywhere — Learner Lab doesn't allow creating the IAM identity provider trust relationship this requires.
- **Manual credential refresh** — every time the Learner Lab session resets, the GitHub Secrets must be updated by hand. In a real AWS account, credentials wouldn't expire this way.
- **Open security group rules** (e.g. `0.0.0.0/0` for SSH) are fine for a temporary lab environment, but a production setup would restrict this to specific IP ranges or use a bastion host / VPN.

<!-- ## DevSecOps: adding security scanning to the pipeline

| NOTE: Not sure if i want to do this section. Depends on the length of my current implementation

Beyond plain CI/CD, this project extends the pipeline with a **DevSecOps** approach — the practice of building security checks directly into the pipeline itself, rather than treating security as a separate, later step. This is often summarised as "shifting left": catching problems as early as possible, ideally before anything is ever deployed, rather than finding them after the fact.

Four automated scanning stages run **before** the deploy stage, and deployment only proceeds if all of them pass:

| Stage | Tool | What it checks |
| --- | --- | --- |
| `sast-codeql` | GitHub CodeQL | Scans the Streamlit application's Python code for security vulnerabilities (e.g. injection flaws, unsafe data handling) |
| `secrets-scan` | Gitleaks | Scans the whole repository history for accidentally committed secrets — API keys, passwords, tokens |
| `security-iac` | Checkov | Scans the **Terraform** files for cloud misconfigurations (e.g. overly permissive security group rules) |
| `security-ansible` | ansible-lint | Checks the **Ansible playbook** for best-practice and configuration issues |

This is implemented using GitHub Actions' `needs:` keyword, which makes one job wait on others finishing successfully first:

```yaml
deploy:
  needs:
    - sast-codeql
    - secrets-scan
    - security-iac
    - security-ansible
```

If any scanning stage fails, the `deploy` job never runs — infrastructure is never provisioned and the app is never deployed until the underlying issue is fixed. This turns security from a manual, occasional review into an automatic gate that runs on every single push.

### Why this matters here specifically

Checkov is expected to flag this project's `0.0.0.0/0` security group rules as a finding, since Checkov's default rules assume a production-grade environment. That flag is correct in principle — it is a real weakening of network security — but it's a deliberate, documented trade-off for a temporary Learner Lab sandbox rather than an oversight (see the limitations section above). Being able to explain *why* a scanner's finding is being knowingly accepted, rather than blindly suppressing it, is itself a core DevSecOps skill.

Similarly, `ansible-lint` is initially run in **non-blocking** mode (`ansible-lint . || true`) rather than gating the pipeline immediately. This reflects a realistic rollout pattern: a new linting rule is often introduced in "report only" mode first, so the existing findings can be reviewed and triaged, before being switched to "blocking" once the team is confident it's only catching genuine issues rather than stylistic noise. -->

The next document (`03-pipeline-steps.md`) walks through exactly what happens, step by step, from `git push` to the app being live.
