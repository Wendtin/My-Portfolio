# Week 02 — Networking & Protocol Analysis

**Fellow:** Wend Tin Basile Sam
**Date:** May 27, 2026
**Repository:** https://github.com/Wendtin/My-Portfolio
**TKH Innovation Fellowship 2026 | Phase 1 | Cybersecurity**

## Overview

Week 02 focused on network fundamentals, protocol analysis, and traffic
capture techniques. Sessions covered subnetting, DNS resolution, TCP/IP
communication, and the use of command-line tools to inspect and audit
live network traffic. A practical network audit was performed and
documented as a deliverable artifact.

## Tools Used

| Tool | Purpose |
|------|---------|
| tcpdump | Packet capture and traffic analysis |
| dig | DNS resolution and query inspection |
| curl | HTTP request testing and header inspection |
| ss | Socket and port enumeration |
| nano | Text file editing |
| git | Version control and portfolio submission |

## Key Concepts

- TCP/IP model and OSI layer mapping
- Subnetting and CIDR notation
- DNS resolution and /etc/hosts manipulation
- Port enumeration and service fingerprinting
- Packet capture and traffic analysis with tcpdump

## Artifacts

- `network_audit.txt` — full network audit output
- `final_threat_report.txt` — threat findings report
- `subnet_blueprint.txt` — subnetting exercise output
- `README (Session 04: Operation Broken Link).md` — session writeup
- `README - Session 05: Operation Grid Lock.md` — session writeup
- `README (TLAB-01: Operation Clean Sweep).md` — TLAB writeup

## Challenges

Mapping theoretical subnetting calculations to live network output
required careful attention. Distinguishing legitimate traffic from
anomalous patterns in tcpdump captures was initially difficult and
improved with repeated analysis of capture files across sessions.

## References

Kurose, J. F., & Ross, K. W. (2021). *Computer networking: A top-down
approach* (8th ed.). Pearson.

The Tcpdump Group. (2024). *Tcpdump and libpcap documentation*.
https://www.tcpdump.org