# 🔍 Operation Phantom Pursuit — Digital Forensics & Incident Response Lab

## 📌 Overview

Operation Phantom Pursuit is a hands-on Digital Forensics and Incident Response (DFIR) investigation performed inside a simulated enterprise environment. This lab demonstrates the complete incident response lifecycle, including SIEM analysis, live system triage, chain of custody procedures, and disk forensics using industry-standard forensic tools.

The objective of this investigation was to identify the source of a security breach, investigate an active command-and-control (C2) connection, preserve forensic evidence, and recover a deleted malware artifact from a compromised disk image.

---

# 🛠️ Technologies & Tools Used

* Kali Linux
* Docker
* ELK Stack (Elasticsearch, Logstash, Kibana)
* The Sleuth Kit (TSK)
* SHA256 Hashing
* Linux Networking Utilities
* Git & GitHub

---

# 🎯 Lab Objectives

## Phase 1 — SIEM Correlation

* Accessed Kibana SIEM dashboard
* Configured enterprise log index patterns
* Investigated critical security alerts
* Identified the attacker's source IP address

### Key Skills Demonstrated

* SIEM navigation
* Log analysis
* Threat identification
* Event correlation

---

## Phase 2 — Live Triage & Chain of Custody

* Connected to the quarantined host container
* Identified suspicious process listening on port 4444
* Documented malicious PID
* Generated SHA256 hash of forensic disk image to preserve evidence integrity

### Key Skills Demonstrated

* Live incident response
* Process analysis
* Network connection analysis
* Evidence preservation
* Chain of custody procedures

---

## Phase 3 — Disk Forensics & Malware Recovery

* Investigated forensic disk image using The Sleuth Kit
* Enumerated filesystem contents with `fls`
* Identified deleted malware artifact (`beacon.exe`)
* Performed inode and sector analysis
* Attempted payload recovery using:

  * `icat`
  * `istat`
  * `blkcat`
  * `strings`

### Key Skills Demonstrated

* Disk forensics
* Deleted file recovery
* FAT16 filesystem analysis
* Metadata examination
* Malware artifact investigation

---

# 🔬 Forensic Workflow

## 1️⃣ SIEM Investigation

Used Kibana to investigate enterprise alerts and identify the initial compromise indicators.

## 2️⃣ Live Host Triage

Performed live analysis on the compromised host container to identify suspicious network activity and malicious processes.

## 3️⃣ Evidence Preservation

Generated SHA256 hash values to ensure forensic evidence integrity and maintain chain of custody.

## 4️⃣ Disk Analysis

Used forensic analysis tools to investigate the FAT16 disk image and recover deleted malware artifacts.

---

# 📂 Repository Structure

```bash
My Portfolio/
│
├── Incident_Response_Report.md
├── README.md
├── screenshots/
│   ├── kibana-alert.png
│   ├── netstat-analysis.png
│   ├── forensic-analysis.png
│   └── github-commit.png
│
└── artifacts/
    ├── recovered_payload.txt
    ├── sector_108_data.txt
    └── hash_results.txt
```

---

# 🧠 Skills Demonstrated

* Incident Response
* Threat Hunting
* Security Monitoring
* Digital Forensics
* Linux Administration
* Malware Investigation
* Evidence Handling
* SIEM Operations
* Cybersecurity Documentation
* Git Version Control

---

# 📖 Lessons Learned

This lab reinforced the importance of:

* Proper evidence handling procedures
* SIEM-based threat detection
* Live host triage techniques
* Filesystem forensic analysis
* Chain of custody documentation
* Multi-stage incident investigation workflows

The investigation also demonstrated how deleted malware artifacts may still leave recoverable metadata even when payload data is partially removed.

---

# 🚀 Author

**Basile Sam**
Cybersecurity & Digital Forensics Portfolio Project

---

# ⚠️ Disclaimer

This project was performed in a controlled educational laboratory environment for cybersecurity training purposes only.
