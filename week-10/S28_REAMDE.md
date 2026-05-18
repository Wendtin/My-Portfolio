# 🚨 S28 — The Crime Scene: DFIR Live Triage & Chain of Custody

**Course:** Cybersecurity Operations  
**Week:** 10 | **Session:** 28  
**Category:** Digital Forensics & Incident Response (DFIR)

---

## 🧠 Overview

This lab simulates a First Responder scenario inside a compromised corporate
network (TitanCorp). A server is suspected of hosting an active Command &
Control (C2) beacon. The objective is to perform live triage without destroying
volatile data, then cryptographically lock the collected forensic artifacts to
establish a legally defensible Chain of Custody.

---

## 🎯 Learning Objectives

- Perform non-destructive live triage on a compromised host
- Use `netstat` to identify suspicious network connections and map them to
  running processes
- Recognize indicators of compromise (IoCs) — specifically, processes listening
  on known C2 ports (e.g., port 4444)
- Generate MD5 and SHA256 cryptographic hashes to create tamper-evident
  fingerprints of forensic artifacts
- Understand why dual-hash verification (MD5 + SHA256) is used in professional
  forensic workflows
- Document findings in a structured Chain of Custody log

---

## 🛠️ Tools & Techniques Used

| Tool / Command | Purpose |
|----------------|---------|
| `docker exec -it` | Access a live, isolated compromised container |
| `netstat -antp` | Enumerate active TCP connections with PIDs |
| `md5sum` | Generate MD5 fingerprint of forensic evidence |
| `sha256sum` | Generate SHA256 fingerprint of forensic evidence |
| `nano` | Document findings in the Chain of Custody log |
| `git` | Version-control and publish the artifact |

---

## 🔬 Lab Phases

### Phase 1 — Live Triage
Accessed a quarantined Docker container simulating a compromised host.
Used `netstat -antp` to enumerate all active TCP connections and identify a
suspicious process listening on **port 4444** — the default Metasploit
Meterpreter C2 port. Recorded the process name and PID without disturbing
the running system state.

### Phase 2 — Evidence Capture
Navigated to the staged evidence directory (`~/DFIR_Evidence/`) and generated
cryptographic hashes for both artifacts:

- **MD5** hash of `memory_dump.raw` — fast fingerprint, collision-vulnerable,
  included for legacy compatibility
- **SHA256** hash of `system_artifacts.zip` — collision-resistant, current
  forensic gold standard

Both hashes were recorded in a structured `collection_log.txt` establishing
Chain of Custody for the collected evidence.

---

## 🔑 Key Concepts

**Chain of Custody** — A documented, unbroken record proving that evidence
has not been altered from the moment of collection through analysis and
presentation. Cryptographic hashes are the technical backbone of this process.

**Why Port 4444?** — Port 4444 is the default listener for Metasploit's
Meterpreter payload. It is one of the most commonly flagged ports in threat
intelligence feeds and a textbook IoC during incident triage.

**MD5 vs SHA256** — MD5 produces a 128-bit hash and is computationally fast
but susceptible to collision attacks. SHA256 produces a 256-bit hash with
no known practical collisions. Professional forensic tools (FTK, Autopsy,
EnCase) record both for completeness and legal defensibility.

---

## 📁 Artifact

- `collection_log.txt` — Chain of Custody log containing the malicious process
  name, PID, MD5 hash of the memory dump, and SHA256 hash of the artifact
  package.

---

## 📸 Evidence

> ![alt text](s28_crime_scene-1.png) or 

https://github.com/Wendtin/My-Portfolio/blob/main/week-10/s28_crime_scene.png?raw=true
---

*Part of an ongoing cybersecurity operations portfolio documenting hands-on
lab work in penetration testing, DFIR, and network security.*
