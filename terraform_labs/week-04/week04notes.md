# Week 04 — Virtualization & Containers

**Fellow:** Wend Tin Basile Sam
**Date:** May 27, 2026
**Repository:** https://github.com/Wendtin/My-Portfolio
**TKH Innovation Fellowship 2026 | Phase 1 | Cybersecurity**

## Overview

Week 04 covered virtualization concepts and container-based deployment
using Docker. Sessions focused on spinning up isolated environments,
deploying web services inside containers, hardening container
configurations, and auditing the resulting infrastructure. A
docker-compose deployment was produced and hardened as the primary
lab deliverable.

## Tools Used

| Tool | Purpose |
|------|---------|
| Docker | Container creation and management |
| docker-compose | Multi-container orchestration |
| bash | Deployment and hardening scripting |
| curl | Service verification inside containers |
| git | Version control and portfolio submission |

## Key Concepts

- Container vs. virtual machine architecture
- Docker image layers and container lifecycle
- docker-compose service definition and networking
- Container hardening: non-root users, read-only filesystems
- Infrastructure auditing in containerized environments

## Artifacts

- `docker-compose.yml` — container orchestration configuration
- `deploy_web.sh` — automated web service deployment script
- `hyperstack_audit.json` — infrastructure audit output
- `sandbox_report.txt` — sandbox environment analysis report
- `tlab_report.txt` — TLAB submission report
- `README(The Disposable Web Server).md` — session writeup
- `README(TLAB 4: Operation Fortified Node).md` — TLAB writeup
- `TheConductorAndTheFleet.md` — session narrative artifact

## Challenges

Networking between containers presented the most significant challenge,
particularly understanding how Docker bridge networks resolve hostnames
between services. Debugging connectivity issues between containers
required careful inspection of docker-compose network definitions and
container logs.

## References

Docker Inc. (2024). *Docker documentation*. https://docs.docker.com

Poulton, N. (2023). *Docker deep dive* (2023 ed.). Independently
published.