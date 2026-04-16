
# TITAN SMALL BUSINESS SERVICES: SECURITY ARCHITECTURE DOCUMENT (SAD)
**Operator:** [WEND Tin Basile Sam]
**Date:** [04/15/2026]

## 1. Perimeter Hardening (UFW & SSH)
* **SSH Status:** [SSH key authentication was commented before making changes. (1) nano /etc/ssh/sshd_config
(2) uncoment and set: PermitRootLogin no (3) Uncomment ans set: PasswordAuthentication no (4) sudo systemctl restart ssh]
* **Firewall Logic:** [(1) sudo ufw allow 22 (2) sudo ufw allow 8080 (3) sudo ufw enable]

## 2. The Automated Auditor (Python)
* **Script Logic:** 
import os
# Run df -h and capture output
output = os.popen("df -h").read()

# Write output to /var/log/sys_audit.log
with open("/var/log/sys_audit.log", "w") as f:
    f.write(output)

print("Audit complete. Output written to /var/log/sys_audit.log")
* **Telemetry Path:** `/var/log/sys_audit.log`

## 3. Containerized App (Docker)
* **Network Isolation:** [The database (db) container is isolated through a rigorous two-layer security architecture that leverages Docker’s native network segmentation. First, the db service is restricted to a dedicated backend network, effectively air-gapping it from the wiki (Nginx) container, which resides on a separate frontend network. Because these services do not share a common network bridge, the frontend cannot directly resolve or address the database. Second, the backend network is explicitly configured with the internal: true flag. This instruction mandates that Docker block all routing between the containerized database and the host machine or external internet, ensuring the db has no inbound or outbound path beyond its isolated environment.]
* **Stack Health:** [docker-compose ps
NAME            IMAGE     COMMAND                  SERVICE   CREATED          STATUS          PORTS
wendkali-db-1   mysql     "docker-entrypoint.s…"   db        44 seconds ago   Up 41 seconds   3306/tcp, 33060/tcp
]

## 4. Executive Summary
[The Hardened Outpost implements a layered defense strategy across three tiers of the stack. At the perimeter, SSH is locked to key-based authentication only and UFW enforces a default-deny firewall policy, ensuring no unauthorized access paths exist at the operating system level. The automated auditor provides continuous Domain Controller telemetry, creating a lightweight but persistent monitoring loop that writes to a centralized log for incident review. At the application layer, Docker network segmentation and the internal: true flag enforce a true air-gap around the database, ensuring that even if the frontend container were compromised, lateral movement to the backend data store would be architecturally blocked.]
