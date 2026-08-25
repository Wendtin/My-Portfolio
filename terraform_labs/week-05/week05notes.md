# Week 05 — Identity, Access & Active Directory

**Fellow:** Wend TIN Basile Sam
**Date:** May 27, 2026
**Repository:** https://github.com/Wendtin/My-Portfolio
**TKH Innovation Fellowship 2026 | Phase 1 | Cybersecurity**

## Overview

Week 05 addressed identity and access management through the lens of
Windows Active Directory. Sessions covered domain controller
configuration, group policy object creation, user provisioning via
PowerShell, and GPO-based security enforcement. Due to infrastructure
constraints, some work was completed in Windows Server Core, requiring
command-line-only administration techniques.

## Tools Used

| Tool | Purpose |
|------|---------|
| PowerShell | User provisioning and AD administration |
| Active Directory Users and Computers | Domain object management |
| Group Policy Management Console | GPO creation and linking |
| Windows Server Core | Headless server administration |
| git | Version control and portfolio submission |

## Key Concepts

- Active Directory domain structure: forests, trees, OUs
- Group Policy Objects: creation, linking, and enforcement
- PowerShell-based bulk user onboarding
- GPO auditing and compliance verification
- Windows Server Core command-line administration

## Artifacts

- `onboard_engineers.ps1` — PowerShell script for bulk user creation
- `gpo_audit.txt` — GPO audit and compliance output
- `README(Active Directory1).md` — session writeup
- `S15_BridgingThe_Kingdoms.md` — session narrative artifact
- `titanEnterprise.md` — enterprise AD scenario writeup
- `tlab5_report.txt` — TLAB submission report

## Challenges

The infrastructure pivot to Windows Server Core eliminated the GUI and
required all Active Directory administration to be performed via
PowerShell and command-line tools. This constraint, while challenging,
produced a deeper understanding of AD internals than a GUI-only approach
would have allowed. Resolving domain join failures and GPO replication
delays required systematic troubleshooting under time pressure.

## References

Microsoft. (2024). *Active Directory documentation*.
https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/

Svendsen, T. (2023). *Learn PowerShell in a month of lunches* (4th ed.).
Manning Publications.