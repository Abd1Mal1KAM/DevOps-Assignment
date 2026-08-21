# Presentation Script — Talking Notes

These are talking points, not a word-for-word script — say them in your own words so it sounds natural on camera. Cues in `[brackets]` tell you what to show on screen at that moment. Rough timings assume a ~20 minute total recording, with more weight on Section 2 as agreed.

---

## Opening (30 sec)

- State your name, module, and that you chose the **AWS Academy Learner Lab** path for this assessment.
- One sentence on what you built: a Streamlit web app, deployed via an automated CI/CD pipeline to AWS, with security scanning built in (DevSecOps).

---

## Section 1 — What is DevOps? (~4 minutes)

**1. Define it (30–40 sec)**

DevOps merges two historically separate teams — Development and Operations — into one continuous, collaborative process. Ebert et al. (2016) describe it as an organisational shift away from siloed teams working separately, toward cross-functional teams delivering features continuously.

`[SHOW: Image 5 — the DEV/OPS infinity loop]`

- Point out the loop shape itself is deliberate: Plan → Create → Verify → Package (Dev side) flows straight into Release → Configure → Monitor → back to Plan (Ops side). It's not a line with an end point — it's continuous.

**2. The culture-shift angle, not just tools (30–40 sec)**

Say explicitly: DevOps is as much a **culture shift** as a technical one. Ebert et al. (2016) frame it as a shift toward collaboration between development, quality assurance, and operations — not simply installing new software.

- This is a good moment to mention the four cultural challenges Ebert et al. identify: breaking work into small independently-deployable chunks, maintaining visibility of what's deployed and its dependencies, building environments derived from legacy processes, and bridging the cultural gap between "thorough but slow" Ops thinking and "fast but rough" Dev thinking.

**3. Continuous Integration specifically (45 sec–1 min)**

`[SHOW: Image 1 — Continuous Integration diagram]`

- Walk through the loop as drawn: developers check in code → build tool checks it out and builds it → CI server reports build status back → notification goes to developers, and status flows to clients/testers/team leads.
- Say plainly: this is what automatically tests every change immediately, rather than waiting until a big release to discover something's broken.
- Ground this in the practice's origin: Fowler (2006) defines Continuous Integration as team members integrating their work frequently — at least daily — with each integration automatically verified by a build and test run, specifically to catch integration errors as early as possible.

**4. CI → CD → Continuous Deployment, and the difference between them (45 sec–1 min)**

`[SHOW: Image 4 — Code/Build/Release loop]`

- Distinguish the three terms clearly, since markers often check students actually understand the difference:
  - **Continuous Integration** — code is merged and tested automatically, frequently.
  - **Continuous Delivery** — code is automatically prepared into a releasable state, but a human still approves the final release.
  - **Continuous Deployment** — goes one step further: every change that passes tests is deployed automatically, with no manual approval step.

`[SHOW: Image 3 — the check-in/build/test/release sequence diagram]`

- Use this to show what happens when something fails partway (the red bars) versus when everything passes and it flows through to release (green, ending in Approval → Release). This is a nice visual of "fail fast" — problems are caught and fed back immediately rather than discovered later.

**5. Where the app actually runs — service models (30–40 sec)**

`[SHOW: Image 2 — IaaS/PaaS/SaaS table]`

- Ground this in the standard definition rather than just describing the table: Mell and Grance (2011), in NIST's foundational cloud computing publication, define three service models — with Infrastructure as a Service giving the consumer control over operating systems, storage, and deployed applications, while the provider retains control of the underlying physical infrastructure.
- Place AWS in this picture: AWS EC2, which this project uses, is IaaS — you get high control, but you (not AWS) manage the OS, applications, and data. Contrast with PaaS (e.g. Heroku, where the provider manages more) to show you understand *why* your Terraform/Ansible setup is necessary — with IaaS, nothing runs unless you provision and configure it yourself.

**6. Why automation specifically, backed by evidence (20–30 sec)**

Ebert et al. (2016) note that quality deliveries with short cycle times require a high degree of automation, and that companies like Amazon and Google achieve cycle times of minutes precisely because of this. You can pair this with the DORA/Accelerate research point if you want a second, more recent source: organisations with mature DevOps automation practices recover from failures faster and fail less often than those without.

**7. The philosophy underneath the tools (30–40 sec)**

Before moving into the demo, it's worth naming the underlying principles the tools serve — this signals depth beyond "here are some tools." Kim et al. (2016), in The DevOps Handbook, frame DevOps around three underlying principles: fast flow of work from development through to the customer, fast feedback loops running in the opposite direction, and a culture of continual learning and experimentation. Say explicitly that everything you're about to demonstrate — the pipeline, the security gates, the infrastructure choices — is really just a small-scale, individual-project expression of those three ideas, and you'll come back to this framing in your reflection.

---

## Section 2 — How This Applies to My Project (~9–10 minutes)

This is the section that needs the most depth — concept-by-concept, tied explicitly to your actual pipeline and diagrams.

**1. Overview of what was built (30–45 sec)**

`[SHOW: drawio diagram 03-aws-infrastructure]`

- One pass over the diagram: GitHub Actions runner outside AWS, the Learner Lab boundary, temporary credentials, `LabInstanceProfile`, security group, EC2 instance, the Streamlit service, and the end user's browser request.
- Say this is the *destination* — the rest of this section explains how it's built automatically, not manually.

**2. Infrastructure as Code (1–1.5 min)**

Ebert et al. (2016) identify treating infrastructure as code as the most important shift in the deployment phase of DevOps — infrastructure becomes shareable, testable, and version-controlled, rather than manually configured machine by machine.

- Point at your `terraform/main.tf`: the security group and EC2 instance are fully defined in code.
- Say explicitly *why* this matters for your specific case: because Learner Lab environments are temporary and get reset, IaC means you can destroy and recreate the exact same environment with one command — `terraform apply` — rather than manually reconfiguring everything from scratch every session. This is a strong, specific, personal example — better than a generic definition.

**3. Configuration management — why Ansible specifically (1 min)**

Ebert et al. (2016) compare configuration-management tools directly: Puppet requires a master server with agents on every client, Chef requires writing Ruby-based recipes, but Ansible is the simplest to adopt because it needs no agents installed on target machines — it pushes configuration over plain SSH, with configuration written in YAML rather than a full programming language.

- This is a genuinely strong citation to use live: it directly justifies *why* Ansible was the right choice for a temporary Learner Lab EC2 instance — no agent installation step, just SSH (which you already need for deployment anyway), and playbooks are easy to read and adapt.
- Point at `ansible/playbook.yml` and briefly narrate what it installs and configures (Python, dependencies, the `systemd` service).

**4. Continuous Integration / Continuous Deployment in the actual pipeline (1.5–2 min)**

`[SHOW: drawio diagram 02-pipeline-architecture]`

- Walk the diagram top to bottom: a `git push` to `main` is the trigger — this is the CI principle in action, code is tested automatically the moment it changes, not on some manual schedule.
- Point out this pipeline is closer to **Continuous Deployment** than Continuous Delivery, per the distinction made in Section 1 — there's no manual approval gate before `terraform apply` runs; if the scans pass, it deploys automatically.
- Name the actual jobs: Terraform init/apply, capturing the instance's public IP as an output, building the Ansible inventory dynamically, then running the playbook over SSH.

**5. DevSecOps — shifting security left (2–2.5 min)**

This is a good moment to explicitly extend the concepts from Section 1: not just DevOps, but a security-aware version of it, and it's also a strong place to build in explicit *reflection*, which is its own 20% criterion.

- Define the underlying principle before naming tools: Seelam (2019) describes "shift-left" security as embedding automated security checks directly into CI/CD pipelines — SAST scanning, secrets detection, and IaC policy checks — so that vulnerabilities are caught pre-deployment rather than after release, reducing both risk and remediation cost.
- Name the four scanning jobs and what each does: CodeQL (static analysis of the app code), Gitleaks (secrets scanning across commit history), Checkov (Terraform/IaC misconfiguration scanning), ansible-lint (playbook best-practice checking).
- Explain the **gate mechanism**: the `needs:` keyword in GitHub Actions makes the deploy job wait for all four scans to pass first. If any fail, nothing gets deployed.
- **Reflect explicitly here** — don't just describe, evaluate: Checkov flags the open `0.0.0.0/0` security group rule as a real finding. Say plainly that in a production environment this finding would need remediating (e.g. restricting to a known IP range or a bastion host), but that for a temporary Learner Lab sandbox, the trade-off was made consciously for convenience within the assessment's time constraints. Then connect it outward: this exact tension — velocity versus security rigor — is the central challenge Seelam (2019) identifies in real-world DevSecOps adoption, so what you hit here is a small-scale version of a genuine industry problem, not a one-off assignment quirk.

**6. AWS Learner Lab-specific constraints and design decisions (1.5–2 min)**

`[SHOW: drawio diagram 03-aws-infrastructure again, or keep it up from earlier]`

- Temporary credentials: Access Key, Secret Key, and Session Token, refreshed manually every lab session and stored as GitHub Secrets — explain this is a real limitation compared to a production AWS account with persistent IAM users or OIDC federation.
- Restricted IAM: you can't create new IAM roles, so the project uses the pre-existing `LabInstanceProfile` rather than a custom one — this directly shaped the choice of the SSH+Ansible deployment pattern over an approach needing custom IAM roles (e.g. Systems Manager).
- This section doubles as reflection content — you're not just describing what you built, you're explaining *why* it looks the way it does given real constraints, which is exactly what the Design & Architecture criterion is asking for.

**7. Brief bridge to the live demo (15–20 sec)**

- "I'll now walk through the actual code and run the pipeline live, so you can see this working end to end..." → hand off to your code walkthrough (Section 3, which you already know cold).

---

## Section 3 — Reflection on DevOps Practice (~3–4 minutes)

This is its own 20% marking criterion, separate from just describing the pipeline — the brief specifically wants insight into challenges and benefits, tied to industry relevance, with examples. Come back to this after your code walkthrough.

**1. Frame it with the Three Ways (30–40 sec)**

Callback to the framing from Section 1: Kim et al. (2016) organise DevOps around three principles — fast flow, fast feedback, and continual learning. Use these as three lenses to reflect honestly on your own build, rather than just repeating what you did.

**2. Flow — what worked, what didn't (45 sec–1 min)**

- What worked: the pipeline removes the manual handoff of SSHing in and configuring the server by hand every time — Terraform and Ansible run end-to-end from a single `git push`.
- Be honest about the gap: Learner Lab's temporary credentials reintroduce exactly the kind of manual handoff DevOps tries to eliminate — you have to manually refresh GitHub Secrets every session. Naming this as a real friction point, not glossing over it, is what separates description from reflection.

**3. Feedback — what worked, what didn't (45 sec–1 min)**

- What worked: the four parallel security-scanning jobs give feedback *before* deployment, not after — a direct, working example of the fast feedback loops Kim et al. (2016) describe as essential to safe, continuous delivery.
- Be honest about the gap: there's no feedback loop running the other direction — once the app is live, nothing monitors it or reports back into the pipeline (no logging, alerting, or telemetry). Kim et al. (2016) treat this as equally important to pre-deployment feedback, and it's a genuine, specific limitation of this build, not a hypothetical one — a clear "what I'd do differently" for your reflection.

**4. Continual learning — a concrete example from building this (30–45 sec)**

Pick one real moment from actually building this pipeline where something didn't work as expected and you had to adapt — for example, hitting AWS Learner Lab's IAM restrictions and having to redesign around the pre-existing `LabInstanceProfile` instead of creating a custom role. Frame this explicitly as a small-scale version of the "continual learning and experimentation" principle: a real constraint surfaced, you diagnosed it, and you adapted the design — that's the DevOps learning loop in miniature.

**5. Zooming out — industry relevance, backed by evidence (1–1.5 min)**

This is where a strong secondary source lifts the mark significantly, since it moves you from "my personal opinion" to "an evidenced argument."

Shahin, Babar and Zhu (2017) conducted a systematic literature review of 69 industry and academic studies on CI, continuous delivery, and continuous deployment, and identified the critical factors that determine whether organisations succeed or struggle with these practices. Their top-ranked factors were testing effort and time, team awareness and transparency, good design principles, and having a skilled and motivated team — with cost, tooling limitations, and appropriate infrastructure also featuring heavily among the challenges they catalogued.

Reflect on which of these applied to your project and which didn't, since a solo assignment isn't the same context as an enterprise team:

- **Directly applied**: tooling and infrastructure limitations — your own experience getting AWS Learner Lab access working, and adapting around its IAM restrictions, is a small personal instance of exactly the "lack of suitable tools and technologies" and "appropriate infrastructure" factors Shahin et al. (2017) identify as critical at industry scale.
- **Didn't really apply at solo scale**: team awareness, coordination, and cross-team dependencies — Shahin et al. (2017) found these to be major challenges specifically because most real deployments involve multiple people and teams; working alone removes that dimension entirely, which is itself worth noting as a limitation of what this project can demonstrate about DevOps in a team context.

**6. Your own example (space reserved)**

[Insert your own concrete example/source here — this is a good place for direct workplace or personal-experience evidence to sit alongside the academic sources above.]

**7. Close (15–20 sec)**

One sentence tying back to your opening: the same principles — flow, feedback, continual learning — that define DevOps at Amazon or Google scale are visible, even at this small scale, in the choices this pipeline had to make.

---

## References to cite aloud (Harvard format for your written list)

```plaintext
Ebert, C., Gallardo, G., Hernantes, J. and Serrano, N. (2016) 'DevOps', 
IEEE Software, 33(3), pp.94–100.

Forsgren, N., Humble, J. and Kim, G. (2018) Accelerate: The Science of Lean 
Software and DevOps: Building and Scaling High Performing Technology 
Organizations. Portland, OR: IT Revolution Press.

Morris, K. (2016) Infrastructure as Code: Managing Servers in the Cloud. 
Sebastopol, CA: O'Reilly Media.
```

When citing verbally, say it naturally — e.g. *"As Ebert et al. explain in their 2016 IEEE Software article..."* — rather than reading the full reference out loud mid-sentence.

---

## Quick self-check before recording

- [ ] Every concept named in Section 1 gets pointed at specific code/diagram in Section 2 — don't leave any concept undemonstrated.
- [ ] At least 2–3 spoken citations land naturally in Section 1, and 2–3 more in Section 2 (Ebert et al. is your strongest, most directly relevant source — use it more than once, in different places).
- [ ] Don't just describe what you built — say *why*, especially in the Learner Lab constraints section. That's where Design & Architecture marks live.
- [ ] Time yourself once through Section 1 + Section 2 alone before adding Section 3, to see how much room you actually have left.
