# 🏢 Titan Enterprise — Week 5 Final Lab
### Windows Server 2022 | Active Directory | GPO | Linux-AD Integration

![Platform](https://eggplant-surf-72e.notion.site/Titan-Enterprise-Week-5-Final-Lab-3497f23d9d8a80a19bc0d1358b4c03c9)


---

## 📋 Overview

This lab simulates a real-world enterprise IT environment built on **Windows Server 2022**. The objective was to configure and validate a fully operational Active Directory domain (`TITAN.LOCAL`), enforce group policy security hardening, manage organizational units and user accounts, and integrate a Linux (Ubuntu) machine into the Windows domain — all verified through a custom PowerShell audit script.

---

## 🖥️ Environment

| Component | Details |
|---|---|
| Server OS | Windows Server 2022 |
| Hostname | TITAN-DC01 |
| Domain | TITAN.LOCAL |
| Linux Client | Ubuntu (Realm Join) |
| Admin Account | Administrator@TITAN.LOCAL |

---

## 🎯 Lab Objectives

| # | Task | Status |
|---|---|---|
| 1 | Deploy and configure Active Directory Domain Services | ✅ Completed |
| 2 | Create the `Engineering` Organizational Unit (OU) | ✅ Completed |
| 3 | Provision 10+ user accounts in the Engineering OU | ✅ Completed |
| 4 | Create and link a `Security_Hardening` Group Policy Object | ✅ Completed |
| 5 | Join an Ubuntu machine to the TITAN.LOCAL domain | ✅ Completed |
| 6 | Write and execute a PowerShell audit script to verify all tasks | ✅ Completed |

---

## 🔧 Implementation Steps

### 1. Active Directory Domain Setup
Promoted the server to a Domain Controller and configured the `TITAN.LOCAL` domain using Active Directory Domain Services (AD DS). Verified domain health using:
```powershell
Get-ADDomain -Identity "TITAN.LOCAL"
```

---

### 2. Engineering OU Creation
Created the `Engineering` Organizational Unit to logically group department users:
```powershell
New-ADOrganizationalUnit -Name "Engineering" -Path "DC=TITAN,DC=LOCAL"
```

---

### 3. User Provisioning (10+ Accounts)
Provisioned 10 engineer user accounts inside the Engineering OU:
```powershell
$OU = "OU=Engineering,DC=TITAN,DC=LOCAL"
$Password = ConvertTo-SecureString "Titan@12345" -AsPlainText -Force

New-ADUser -Name "eng.user01" -SamAccountName "eng.user01" -Path $OU -AccountPassword $Password -Enabled $true
# ... repeated for eng.user02 through eng.user10
```

---

### 4. GPO — Security Hardening
Created a Group Policy Object named `Security_Hardening` to enforce enterprise-level security policies across the domain:
```powershell
New-GPO -Name "Security_Hardening" -Comment "Titan Enterprise Security Policy"
```

---

### 5. Linux-AD Integration (Ubuntu Realm Join)
Joined an Ubuntu machine to the `TITAN.LOCAL` Active Directory domain using `realm join`, enabling centralized authentication and management of the Linux endpoint. Verified via:
```powershell
Get-ADComputer -Filter * -Properties OperatingSystem |
  Where-Object { $_.OperatingSystem -match "Ubuntu|Linux" }
```

---

### 6. PowerShell Audit Script
Wrote a custom audit script (`w5_final_audit.ps1`) that automatically validates all lab requirements and generates a report. The script checks:

- ✅ Domain health (`TITAN.LOCAL`)
- ✅ Engineering OU existence and user count (10+)
- ✅ GPO `Security_Hardening` presence
- ✅ Ubuntu machine registration in AD

#### Audit Result
```
TITAN ENTERPRISE: FINAL AUDIT SCRIPT

[OK] Domain TITAN.LOCAL is healthy.
[OK] Engineering OU and 10+ users verified.
[OK] GPO 'Security_Hardening' exists.
[OK] Ubuntu machine registered in AD.
ALL CHECKS PASSED. CLEARED FOR SUBMISSION.

Report saved to: C:\Users\Administrator.TITAN\Desktop\tlab5_report.txt
```

---

## 📁 Files

| File | Description |
|---|---|
| `w5_final_audit.ps1` | PowerShell audit script — validates all lab tasks |
| `tlab5_report.txt` | Auto-generated audit report output |

---

## 🧠 Skills Demonstrated

- Windows Server 2022 administration
- Active Directory Domain Services (AD DS) configuration
- Organizational Unit and user account management
- Group Policy Object (GPO) creation and management
- Cross-platform domain integration (Linux + Windows AD)
- PowerShell scripting — automation, error handling, reporting
- Network troubleshooting (DNS, firewall, SSH, HTTP file transfer)
- CLI-based file transfer using Python HTTP server

---

## 🚧 Challenges & Solutions

| Challenge | Solution |
|---|---|
| Server had no internet access (firewall blocked all outbound TCP) | Used Python `http.server` on host machine to serve the script over the local network |
| SSH (port 22) blocked — could not use SCP | Switched to `Invoke-WebRequest` over port 8080 via Python HTTP server |
| PowerShell script had 10 syntax errors from OCR/manual transcription | Identified and corrected all bugs including missing braces, wrong variable names, unclosed strings, and invalid escape characters |

---

## 📄 License
This project was completed as part of a structured IT lab curriculum. Free to reference for educational purposes.
