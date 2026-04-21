# 🗺️ S20 — Mapping the Shadows: Active Scanning & Network Enumeration

> **Course:** Cybersecurity Operations | Week 7, Session 20
> **Category:** Active Reconnaissance | Network Enumeration
> **Tools Used:** Nmap, Docker, Linux CLI, Git

---

## 📌 Overview

This lab simulates a real-world authorized penetration test against an unknown internal subnet. Given only a network range (`172.99.0.0/24`), the mission was to locate all active hosts, enumerate their open ports, and identify exact software versions running on each target — documenting every finding in a structured artifact.

The environment consisted of three isolated Docker containers acting as target hosts, spun up inside an Ubuntu VM to replicate a live internal network.

---

## 🎯 Objectives

- Perform a **ping sweep** to discover live hosts on an unknown subnet
- Execute **version scans** to identify open ports and running services
- Conduct an **all-ports scan** to catch services on non-standard ports
- Apply independent judgment to enumerate a third unknown host
- Document findings in a structured artifact and submit via Git

---

## 🧪 Lab Environment

| Component | Detail |
|---|---|
| **Network Range** | `172.99.0.0/24` |
| **Target Hosts** | 3 Docker containers (`172.99.0.5`, `.6`, `.7`) |
| **Platform** | Ubuntu VM (local) |
| **Tool** | Nmap |
| **Isolation Method** | Docker bridge network |

---

## ⚙️ Phase 1 — Ping Sweep: Finding Live Hosts

Before scanning ports, the first step is identifying which hosts are actually alive on the network. Scanning dead addresses wastes time and creates unnecessary noise.

```bash
nmap -sn 172.99.0.0/24
```

**Flag breakdown:**
- `-sn` — Disables port scanning; performs host discovery only (ICMP ping + ARP)

**Result:** Three live hosts identified at `.5`, `.6`, and `.7`

```
Nmap scan report for 172.99.0.5 — Host is up
Nmap scan report for 172.99.0.6 — Host is up
Nmap scan report for 172.99.0.7 — Host is up
```

---

## ⚙️ Phase 2 — Deep Dive: Service & Version Enumeration

### 🔵 Target Alpha — `172.99.0.5` (Version Scan)

```bash
sudo nmap -sV 172.99.0.5
```

**Flag breakdown:**
- `-sV` — Probes open ports to determine service name and exact version

| Port | State | Service | Version |
|---|---|---|---|
| *(see artifact)* | open | *(see artifact)* | *(see artifact)* |

---

### 🟡 Target Beta — `172.99.0.6` (All-Ports Scan)

```bash
sudo nmap -sV -p- 172.99.0.6
```

**Flag breakdown:**
- `-p-` — Scans all 65,535 ports instead of just the default top 1,000
- Purpose: Catches services deliberately running on non-standard ports

| Port | State | Service | Version |
|---|---|---|---|
| *(see artifact)* | open | *(see artifact)* | *(see artifact)* |

---

### 🔴 Target Gamma — `172.99.0.7` (Operator's Choice)

```bash
sudo nmap -A 172.99.0.7
```

**Flag breakdown:**
- `-A` — Aggressive scan: enables version detection, OS detection, script scanning, and traceroute in one command

| Port | State | Service | Version |
|---|---|---|---|
| *(see artifact)* | open | *(see artifact)* | *(see artifact)* |

---

## 📄 Artifact

The full scan documentation is stored in:

```
nmap_scan_results.txt
```

This file contains:
- All three hosts with their open ports and exact service versions
- Answers to theory questions on scanning methodology and ethics

---

## 💡 Key Concepts Learned

### 1. Ping Sweep vs. Port Scan
A ping sweep (`-sn`) is always the first step — it maps *who is alive* before you knock on any doors. Running full port scans against an entire /24 blindly is loud, slow, and unprofessional.

### 2. The `-sV` Flag
Version detection is the core of service enumeration. Without it, Nmap only guesses the service type. With it, you get the exact software and version — critical for identifying known CVEs and vulnerabilities.

### 3. The `-p-` Flag
Default Nmap scans only the top 1,000 most common ports. Real-world attackers and administrators know that services are often intentionally moved to obscure ports. The `-p-` flag closes that gap entirely.

### 4. Why `-A` Can Be Dangerous
The aggressive scan flag bundles heavy operations that flood a target with traffic. On **fragile legacy systems** — old industrial controllers, medical devices, or end-of-life servers — this volume of probes can:
- **Crash or freeze** the system
- **Reboot it unexpectedly**
- **Kill running services mid-operation**

> In a real engagement, always use the lightest scan that achieves the objective. Escalate only when needed and with explicit authorization.

### 5. Scope & Authorization
Every scan in this lab was performed within a pre-authorized, isolated Docker environment. In professional penetration testing, scanning without written authorization is illegal under the Computer Fraud and Abuse Act (CFAA) and equivalent laws. Scope defines the boundary — never cross it.

---

## 🛠️ Commands Reference

| Command | Purpose |
|---|---|
| `nmap -sn 172.99.0.0/24` | Ping sweep — discover live hosts |
| `sudo nmap -sV <IP>` | Version scan — identify open ports and services |
| `sudo nmap -sV -p- <IP>` | Scan all 65,535 ports with version detection |
| `sudo nmap -A <IP>` | Aggressive scan — version + OS + scripts + traceroute |
| `cat ~/nmap_scan_results.txt` | View completed artifact |
| `session-submit --session 20 --artifact ~/nmap_scan_results.txt` | Submit artifact |

---

## 📁 Repository Structure

```
week-07
  |-- s20-mapping-the-shadows/
      │
      ├── README.md                  ← This file
      └── nmap_scan_results.txt      ← Completed scan artifact (submitted)
```

---

## ✅ Outcome

- Successfully discovered all 3 active hosts via ping sweep
- Identified open ports and exact service versions on all targets
- Demonstrated command flag selection based on scan objectives
- Documented findings in a clean, structured artifact
- Submitted via `session-submit` and pushed to GitHub

---

## ⚠️ Disclaimer

All scanning activity in this lab was performed in a **controlled, isolated, and fully authorized** virtual environment created specifically for educational purposes. No external systems, networks, or devices were targeted. This work is intended solely for learning cybersecurity defense and ethical penetration testing concepts.

---

*Week 7 | Session 20 | Active Scanning — Network Enumeration*