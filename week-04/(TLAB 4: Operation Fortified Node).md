# TLAB 4: Operation Fortified Node

## Overview

This lab demonstrates the deployment of a **hardened, three-tier containerized architecture** using Docker Compose on a host-only isolated Linux VM. The objective was to evict a squatter container, orchestrate a segmented WordPress + MariaDB stack, verify network isolation, and produce a machine-readable audit report.

---

## Architecture

```
[ Host Machine ]
      |
      | Host-Only Network (192.168.56.x)
      |
[ Ubuntu VM — Isolated Sandbox ]
      |
      ├── public_net (Docker bridge — internet-facing)
      │       └── web (WordPress) → Port 80:80
      │
      └── private_net (Docker internal — no external routing)
              ├── web (WordPress) — can talk to DB
              └── db  (MariaDB)  — completely hidden
```

- **WordPress** is dual-homed: accessible publicly on Port 80 and connected to the private database network.
- **MariaDB** is air-gapped from the outside world — only reachable by containers on `private_net`.
- `private_net: internal: true` enforces Docker-level isolation — no external traffic can reach the database.

---

## Files

| File | Description |
|---|---|
| `docker-compose.yml` | Defines the full three-tier stack — services, networks, and volumes |
| `hyperstack_audit.json` | Machine-readable audit report with real findings from the isolation test |

---

## What I Did — Phase by Phase

### Phase 0 — Hardware Prep
Configured the VM with a **Host-only Network Adapter** in VirtualBox to isolate it from the internet while keeping it reachable from the host machine. Recorded the VM's `192.168.56.x` IP for use in the isolation test.

### Phase 1 — Eviction
Identified and removed a pre-planted `decoy_web` nginx container that was squatting on Port 80, blocking the intended stack from deploying.

### Phase 2 — Hyper-Stack Orchestration
Wrote a `docker-compose.yml` from scratch defining:
- Two isolated Docker networks (`public_net` and `private_net`)
- A named volume (`db_data`) for database persistence
- Two services: `db` (MariaDB) on the private network only, and `web` (WordPress) bridging both

### Phase 3 — Perimeter Audit
- Ran `nmap` to confirm Port 80 was open and Port 3306 (MariaDB) was closed/filtered
- Entered the WordPress container and attempted to ping the host-only VM IP
- **Result: Ping FAILED** — confirming the container has no route to the host-only network. Isolation verified ✅

### Phase 4 — Artifact Creation
Produced `hyperstack_audit.json` with real operator data, container ID, IP addresses, and honest isolation test findings.

### Phase 5 — Deployment
Pushed both artifacts to GitHub and submitted via `session-submit`.

---

## Audit Report

```json
{
  "operator": "YOUR_INITIALS",
  "host_ip": "10.0.2.15",
  "vm_sandbox_ip": "192.168.56.x",
  "web_container_id": "YOUR_CONTAINER_ID",
  "isolation_test": "PASSED",
  "persistence_verified": true
}
```

---

## Key Concepts Demonstrated

- **Network segmentation** — separating public-facing and private services at the Docker network layer
- **Volume persistence** — named volumes ensure database data survives container restarts
- **Container isolation** — `internal: true` networks block all external routing
- **Audit documentation** — producing structured, machine-readable security reports
- **Port scanning** — using `nmap` to verify the attack surface of a running stack

---

## Tools Used

- Docker & Docker Compose
- MariaDB / WordPress (official images)
- nmap
- VirtualBox Host-only Networking
- Git / GitHub

