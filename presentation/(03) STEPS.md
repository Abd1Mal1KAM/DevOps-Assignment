# Pipeline Steps: From Push to Live App

This document walks through exactly what happens, in order, when code is pushed to `main`.

## Repository structure

```
your-repo/
├── .github/workflows/deploy.yml    Pipeline definition (security scans + deploy)
├── app/
│   ├── app.py                      Streamlit application
│   └── requirements.txt            Python dependencies
├── terraform/
│   ├── main.tf                     Security group + EC2 instance
│   ├── provider.tf                 AWS provider configuration
│   ├── variables.tf                Configurable values (e.g. instance type)
│   └── outputs.tf                  Prints the instance's public IP
└── ansible/
    ├── ansible.cfg                 Disables SSH host key prompts
    ├── inventory.ini               List of servers to configure (IP injected at runtime)
    └── playbook.yml                Installs and starts the app
```

## One-time manual setup (done once, before any automation)

1. Start the AWS Academy Learner Lab session and open **AWS Details** to retrieve:
   - Access Key ID, Secret Access Key, Session Token
   - `labsuser.pem` (the SSH private key file)
2. Add these as **GitHub repository secrets** (Settings → Secrets and variables → Actions):
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_SESSION_TOKEN`
   - `SSH_PRIVATE_KEY` (full contents of `labsuser.pem`)

These credentials expire when the Learner Lab session ends, so this step is repeated at the start of each new lab session.

## Automated pipeline steps (triggered by `git push` to `main`)

The pipeline is made up of **five jobs**. The first four are security scanning jobs that all run **in parallel**, independently of each other. Only once *all four* finish successfully does the fifth job — the actual deployment — begin. If any scanning job fails, deployment is skipped entirely.

<!-- ### Phase 1 — Security scanning jobs (run in parallel)

| NOTE: Not sure if i want to do this section. Depends on the length of my current implementation

**Job: `sast-codeql`**
Checks out the repository, then runs GitHub's CodeQL engine against the Streamlit application's Python code, looking for known categories of security vulnerabilities (e.g. unsafe input handling). Results are uploaded to the repository's Security tab.

**Job: `secrets-scan`**
Checks out the repository, then runs **Gitleaks**, which scans the full commit history for anything that looks like a leaked credential — API keys, passwords, tokens accidentally committed to the repo.

**Job: `security-iac`**
Checks out the repository, sets up Terraform, then:

1. `terraform fmt -check` — confirms the `.tf` files are consistently formatted
2. `terraform validate` — confirms the Terraform syntax is structurally correct
3. Runs **Checkov**, which scans `main.tf` for cloud security misconfigurations (e.g. flags the open `0.0.0.0/0` SSH rule as a known, documented trade-off — see `02-project-application.md`)

**Job: `security-ansible`**
Installs Ansible and `ansible-lint`, then lints `playbook.yml` for configuration best-practice issues. Initially run in non-blocking mode (see `02-project-application.md` for why). -->

### Phase 2 — Deploy job (only runs if all four scans above pass)

**Step 1 — Checkout code**
GitHub Actions checks out the repository so the runner has access to the Terraform files, Ansible files, and application code.

**Step 2 — Prepare SSH key**
The `SSH_PRIVATE_KEY` secret is written to a file on the runner (`~/.ssh/labuser.pem`) with restricted permissions, so Ansible can use it to connect later.

**Step 3 — Terraform init**
Downloads the AWS provider plugin and initializes the working directory.

**Step 4 — Terraform apply**

Reads `main.tf` and creates the actual AWS infrastructure:
- A **security group** allowing inbound SSH (port 22) and Streamlit (port 8501)
- An **EC2 instance** running Ubuntu, using Learner Lab's `LabInstanceProfile` and `vockey` key pair

This step uses the AWS credentials from GitHub Secrets (set as environment variables) to authenticate.

**Step 5 — Capture the instance IP**
`terraform output` retrieves the newly created instance's public IP address (defined in `outputs.tf`) so later steps know where to connect.

**Step 6 — Install Ansible**
The GitHub Actions runner installs Ansible (it isn't present by default).

**Step 7 — Build the Ansible inventory**
The IP address captured in Step 5 is written into an inventory file, telling Ansible which server to configure — this is what replaces manually typing the IP into an SSH command.

**Step 8 — Run the Ansible playbook**
Ansible connects to the new EC2 instance over SSH (using `labuser.pem`) and:
1. Updates package lists
2. Installs Python 3 and pip
3. Copies the application code onto the server
4. Installs Python dependencies from `requirements.txt`
5. Creates a `systemd` service so the Streamlit app runs continuously in the background and restarts automatically if it crashes or the server reboots

**Result**: the Streamlit app is now live and reachable at `http://<instance-public-ip>:8501`, having passed four independent security checks first, with zero manual steps taken after the initial `git push`.

## What happens on a subsequent push

Because `terraform apply` is idempotent (it only changes what's different from the current state), pushing again will:
- Leave existing infrastructure untouched if nothing in `main.tf` changed
- Re-run the Ansible playbook, redeploying the latest application code to the existing server

This means updating the app is as simple as pushing a code change — the pipeline handles the rest.