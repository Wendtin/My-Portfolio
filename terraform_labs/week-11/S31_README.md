# 🚧 The Barricade — Host Firewall & DMZ Lockdown

**Session 31 | Week 11 | Cybersecurity Lab Series**

---

## 📋 Overview

This lab simulates a real-world perimeter hardening scenario in which a corporate web server must be secured against lateral movement from a compromised DMZ node. The exercise covers two complementary layers of firewall engineering: a rapid UFW deployment for host-based security posture, followed by precision raw `iptables` rules to enforce strict DMZ network segmentation.

The artifact produced is a deployable shell script (`firewall_config.sh`) containing the engineered iptables rules, committed to version control as a reproducible infrastructure deliverable.

---

## 🎯 Objectives

- Configure a **Default Deny** security posture using UFW
- Selectively allow only required inbound services (SSH, HTTPS)
- Engineer raw `iptables` rules to simulate a **DMZ lockdown**
- Restrict lateral movement from the web server to the internal subnet
- Preserve a single egress exception for legitimate database communication
- Package and submit a firewall configuration script as a portfolio artifact

---

## 🛠️ Tools & Technologies

| Tool | Purpose |
|---|---|
| **UFW** (Uncomplicated Firewall) | Host-based firewall management |
| **iptables** | Low-level Linux kernel packet filtering |
| **Docker** | Containerized DMZ lab environment |
| **Bash** | Scripting and rule automation |
| **Git / GitHub** | Version-controlled artifact submission |

---

## 🏗️ Lab Environment

The provisioner script deploys a containerized DMZ network simulating the following topology:

```
[ Internet ]
     │
     ▼
[ dmz_web container ]  ←── Target: Web Server (this machine)
     │
     │  10.0.5.0/24 (Internal Subnet)
     ▼
[ 10.0.5.50 ]          ←── Internal Database (MySQL on port 3306)
[ 10.0.5.x  ]          ←── Other internal hosts (lateral movement risk)
```

---

## ⚙️ Phase 1 — UFW: "The Rule Maker"

A quick host-based firewall was configured inside the `dmz_web` container using UFW to establish a baseline security posture.

### Commands Executed

```bash
# Set default deny on all inbound, allow all outbound
ufw default deny incoming
ufw default allow outgoing

# Open only required service ports
ufw allow 22/tcp    # SSH — remote administration
ufw allow 443/tcp   # HTTPS — encrypted web traffic

# Enable and verify
ufw enable
ufw status verbose
```

### Verified Output

```
Status: active
Default: deny (incoming), allow (outgoing), deny (routed)

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW IN    Anywhere
443/tcp                    ALLOW IN    Anywhere
```

> UFW was disabled before Phase 2 to prevent rule conflicts with raw iptables.

---

## ⚙️ Phase 2 — iptables: "The DMZ Lockdown"

Raw `iptables` rules were applied to enforce strict network segmentation at the packet filter level, preventing lateral movement from the web server to other internal hosts.

### Rules Engineered

```bash
# Rule 1 — Allow inbound HTTP and HTTPS (internet → web server)
iptables -A INPUT -p tcp -m multiport --dports 80,443 -j ACCEPT

# Rule 2 — Egress exception: web server → internal DB only (must precede the DROP)
iptables -A OUTPUT -p tcp -d 10.0.5.50 --dport 3306 -j ACCEPT

# Rule 3 — Drop all other outbound traffic to the internal subnet
iptables -A OUTPUT -d 10.0.5.0/24 -j DROP
```

### Rule Order Rationale

iptables evaluates rules **top-down — first match wins**. The `ACCEPT` rule for `10.0.5.50:3306` must appear **before** the broad `DROP` for `10.0.5.0/24`. If the DROP were first, the database exception would never be reached and legitimate SQL traffic would be silently discarded.

### Verified Output (`iptables -L -v -n`)

```
Chain INPUT
    ACCEPT  tcp  --  anywhere  anywhere  multiport dports 80,443

Chain OUTPUT
    ACCEPT  tcp  --  anywhere  10.0.5.50   tcp dpt:3306
    DROP    all  --  anywhere  10.0.5.0/24
```

---

## 📄 Artifact — `firewall_config.sh`

```bash
#!/bin/bash
# DMZ LOCKDOWN SCRIPT (iptables)

# Flush existing rules
iptables -F

# Allow Web Server to receive internet traffic on ports 80 and 443
iptables -A INPUT -p tcp -m multiport --dports 80,443 -j ACCEPT

# EXCEPTION: Allow outbound to SQL/DB on port 3306
iptables -A OUTPUT -p tcp -d 10.0.5.50 --dport 3306 -j ACCEPT

# Prohibit initiating connection to internal subnet (10.0.5.0/24)
iptables -A OUTPUT -d 10.0.5.0/24 -j DROP
```

---

## 🔑 Key Security Concepts

**Default Deny** — The foundational firewall principle: block everything by default and only open what is explicitly required. Reduces attack surface to the minimum necessary.

**DMZ (Demilitarized Zone)** — A network segment that sits between the public internet and an internal network. Hosts here are semi-trusted; if compromised, they should not be able to pivot inward.

**Lateral Movement** — A post-exploitation technique where an attacker pivots from a compromised host (e.g., the web server) to other internal systems (e.g., databases, domain controllers). The DROP rule on `10.0.5.0/24` directly mitigates this.

**Egress Filtering** — Controlling what traffic is allowed *out* of a host, not just what comes in. Often overlooked, it is critical for containing a compromised node.

**iptables Rule Ordering** — Rules are stateless and evaluated sequentially. Placing a broad DROP before a specific ACCEPT will silently break legitimate traffic. Specific rules must always precede general ones.

---

## 📁 Repository Structure

```
.
├── firewall_config.sh   # Deployable DMZ lockdown script (primary artifact)
└── README.md            # Lab documentation
```

---

## 🚀 Reproduction Steps

```bash
# 1. Run the provisioner (inside Ubuntu VM)
curl -sL https://gist.githubusercontent.com/grobbins-cell/f69144b6d08241d8d9dd633bda734558/raw/165deec34576f841bfb8f89ce8a7d5c69dacf92c/s31_provision.sh | tr -d '\r' | sudo bash

# 2. Enter the DMZ container
docker exec -it dmz_web /bin/bash

# 3. Apply the firewall script
bash firewall_config.sh

# 4. Verify rules
iptables -L -v -n
```

---

*Lab completed as part of a structured cybersecurity curriculum. All work performed in an isolated, legal lab environment.*