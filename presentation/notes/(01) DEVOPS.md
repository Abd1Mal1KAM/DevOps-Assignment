# DevOps: General Overview

## What is DevOps?

DevOps is a set of practices and cultural values that combine **Development** (writing software) and **Operations** (deploying, running, and maintaining software). The goal is to remove the traditional wall between "people who write code" and "people who run it in production," so that changes can be built, tested, and released faster, more reliably, and with less manual effort.

Before DevOps, a typical workflow looked like this:

1. Developers write code and hand it off to a separate Ops team.
2. Ops manually configures servers and deploys the code — often days or weeks later.
3. If something breaks, there's finger-pointing between teams, and fixes are slow.

DevOps replaces this with **automation** and **shared responsibility**: the same pipeline that tests your code also deploys it, with minimal manual intervention.

## Core principles

- **Automation** — repetitive tasks (testing, building, provisioning infrastructure, deploying) are scripted rather than done by hand. This removes human error and saves time.
- **Continuous Integration (CI)** — every time code is pushed, it's automatically built and tested. This catches bugs early, before they reach production.
- **Continuous Delivery/Deployment (CD)** — once code passes CI, it's automatically packaged and released to a live environment, rather than waiting for a manual release process.
- **Infrastructure as Code (IaC)** — servers, networks, and other infrastructure are defined in configuration files (e.g. Terraform) instead of being manually clicked together in a web console. This makes infrastructure reproducible, version-controlled, and reviewable, just like application code.
- **Monitoring and feedback** — once something is live, logging and monitoring let the team know quickly if something goes wrong, closing the loop back to development.

## Why this matters

The practical benefit is **speed with safety**: teams can release changes frequently (sometimes many times a day) without each release being a risky, all-hands manual event. Every step — build, test, provision, deploy — is defined in files that live in version control, so the exact same process runs every time, and anyone on the team can see and review exactly what will happen before it happens.

## Key tools in a typical DevOps pipeline

| Concern | Example tool | What it does |
| --- | --- | --- |
| Version control | Git / GitHub | Tracks code changes, enables collaboration |
| CI/CD orchestration | GitHub Actions | Runs automated steps when code is pushed |
| Infrastructure as Code | Terraform | Defines and provisions cloud infrastructure (servers, networks, security groups) |
| Configuration management | Ansible | Installs software and configures servers after they exist |
| Cloud platform | AWS | Hosts the actual infrastructure (in this project: AWS Academy Learner Lab) |

The next document (`02-project-application.md`) explains how each of these specifically fits into this project.
