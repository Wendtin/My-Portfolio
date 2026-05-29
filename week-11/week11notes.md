# Week 11 — Active Defense: Firewalls, IDS & EDR

**Fellow:** Wend Tin Basile Sam
**Date:** May 27, 2026
**Repository:** https://github.com/Wendtin/My-Portfolio
**TKH Innovation Fellowship 2026 | Phase 1 | Cybersecurity**

## Overview

Week 11 addressed active defense technologies including firewall
configuration, intrusion detection systems, and endpoint detection and
response. Sessions covered iptables and UFW rule construction, custom
Suricata IDS rule development, Sysmon EDR policy authoring, and
multi-layer defense architecture. A critical Docker network namespace
isolation issue was encountered and resolved, enabling Suricata to
observe inter-container traffic by relaunching with the correct bridge
interface using the --network host flag.

## Tools Used

| Tool | Purpose |
|------|---------|
| iptables / UFW | Firewall rule configuration and enforcement |
| Suricata | Network intrusion detection and custom rule authoring |
| Sysmon | Windows endpoint telemetry and EDR policy |
| Docker | Container networking for IDS lab environment |
| Kibana / ELK | Alert visualization and log correlation |
| git | Version control and portfolio submission |

## Key Concepts

- Firewall rule construction: allow, deny, stateful inspection
- Suricata rule syntax: content matching, threshold, metadata
- Sysmon XML policy authoring for endpoint telemetry
- Multi-layer defense architecture (network + host + endpoint)
- Docker network namespace isolation and bridge interface selection
- IDS alert tuning and false positive reduction

## Artifacts

- `custom_ids.rules` — custom Suricata IDS detection rules
- `edr_policy.xml` — Sysmon EDR configuration policy
- `firewall_config.sh` — iptables/UFW firewall configuration script
- `S31_README.md` — Session 31 writeup (ELK/SIEM log analysis)
- `s32README.md` — Session 32 writeup (multi-layer defense)
- `TLAB11/Operation_Fortress_Report.md` — TLAB final report
- `TLAB11/firewall_task.sh` — TLAB firewall task script
- `TLAB11/suricata_task.rules` — TLAB Suricata rules submission
- `TLAB11/sysmon_task.xml` — TLAB Sysmon policy submission

## Challenges

The primary technical challenge was a Docker network namespace
isolation issue that prevented Suricata from observing traffic between
containers. The root cause was that Suricata was listening on the wrong
interface. The resolution required relaunching the container with
--network host and specifying the correct Docker bridge interface,
allowing Suricata to capture inter-container traffic as intended. This
debugging process reinforced the relationship between container
networking architecture and network-layer monitoring tool placement.

## References

OISF. (2024). *Suricata documentation*. https://docs.suricata.io

Microsoft. (2024). *Sysmon documentation*.
https://learn.microsoft.com/en-us/sysinternals/downloads/sysmon