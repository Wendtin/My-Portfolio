# Week 08 — Exploitation Frameworks

**Fellow:** Wend Tin Basile Sam
**Date:** May 27, 2026
**Repository:** https://github.com/Wendtin/My-Portfolio
**TKH Innovation Fellowship 2026 | Phase 1 | Cybersecurity**

## Overview

Week 08 covered exploitation frameworks with a focus on Metasploit,
privilege escalation, and network pivoting. Sessions progressed from
initial access through post-exploitation, including persistence
mechanisms, lateral movement via SOCKS proxy and autoroute, and
multi-hop pivoting through segmented networks. All work was conducted
in an isolated lab environment against authorized targets.

## Tools Used

| Tool | Purpose |
|------|---------|
| Metasploit Framework | Exploitation, post-exploitation, and pivoting |
| msfconsole | Primary Metasploit interface |
| proxychains | Traffic routing through pivot tunnels |
| autoroute | Internal subnet routing via Meterpreter |
| git | Version control and portfolio submission |

## Key Concepts

- Metasploit module types: exploits, payloads, post, auxiliary
- Privilege escalation from user to root/SYSTEM
- Persistence via cron-based reverse shells
- Network pivoting: SOCKS proxy, autoroute, multi-hop routing
- Post-exploitation enumeration and lateral movement

## Artifacts

- `ClimbingTheLadder.md` — privilege escalation methodology writeup
- `Deep_Pivot_Report.md` — multi-layer pivot operation report
- `escalation_path.txt` — documented privilege escalation path
- `Pivot_Operation/PenetrationTest.md` — full penetration test report
- `Pivot_Operation/pivot_success.png` — pivot operation screenshot
- `README_TLAB8.md` — TLAB submission writeup

## Challenges

Metasploit's PostgreSQL dependency caused a segfault on initial launch,
resolved by running msfconsole with the -n flag to disable database
connectivity. Proxychains port misconfiguration also blocked pivot
traffic until the socks4 port in proxychains.conf was aligned with the
Metasploit SOCKS server. These debugging sessions produced durable
troubleshooting instincts for framework-level issues.

## References

Kennedy, D., O'Gorman, J., Kearns, D., & Aharoni, M. (2011). *Metasploit:
The penetration tester's guide*. No Starch Press.

Rapid7. (2024). *Metasploit documentation*.
https://docs.rapid7.com/metasploit/