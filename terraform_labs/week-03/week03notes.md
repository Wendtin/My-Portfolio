# Week 03 — Python Scripting for Security

**Fellow:** Wend Tin Basile Sam
**Date:** May 27, 2026
**Repository:** https://github.com/Wendtin/My-Portfolio
**TKH Innovation Fellowship 2026 | Phase 1 | Cybersecurity**

## Overview

Week 03 introduced Python as a security automation tool. Sessions
covered writing scripts to perform log analysis, brute-force detection,
port checking, and automated incident response. Each script was designed
to solve a realistic security operations problem and produce structured
output for further investigation.

## Tools Used

| Tool | Purpose |
|------|---------|
| Python 3 | Security scripting and automation |
| json | Structured output formatting |
| re (regex) | Log pattern matching |
| socket | Port connectivity checking |
| nano / vim | Script editing |
| git | Version control and portfolio submission |

## Key Concepts

- File I/O and log parsing in Python
- Brute-force detection via failed authentication pattern analysis
- Port scanning logic using Python sockets
- JSON output formatting for structured threat reports
- Automated incident response scripting

## Artifacts

- `brute_detector.py` — detects brute-force attempts in auth logs
- `port_check.py` — checks connectivity to specified ports
- `system_auditor.py` — automated system audit script
- `incident_response.py` — incident response automation script
- `file-demo.py` — file handling demonstration
- `brute_report.txt` — output of brute-force detection run
- `auth_audit.log` — authentication log used for analysis
- `threat_report.json` — structured threat report output
- `Operation_Hunt.md` — session operation writeup

## Challenges

Translating manual security analysis steps into repeatable Python logic
required careful planning of script structure. Handling edge cases in
log parsing — such as malformed lines or unexpected timestamp formats —
introduced debugging challenges that reinforced the value of defensive
coding practices.

## References

Python Software Foundation. (2024). *Python 3 documentation*.
https://docs.python.org/3/

Seitz, J. (2021). *Black hat Python: Python programming for hackers and
pentesters* (2nd ed.). No Starch Press.