# Session 17: The Forge Final — Practical Exam Report

**Operator:** Wend Tin Basile
**Session:** 17 | Week 6
**Standard:** World Elite Gold
**Theme:** The Proving Ground

---

## Overview

This report documents the completion of the **Session 17 Forge Final Exam**, a two-phase diagnostic consisting of a theoretical quiz and a hands-on practical exercise performed on an Ubuntu Linux local VM. The practical phase required locating, extracting, securing, and documenting root-owned system log files.

---

## Environment

| Detail | Value |
|---|---|
| Operating System | Ubuntu Linux (Local VM) |
| Active Machine | Student Workstation |
| Inactive Machine | TITAN-DC01 (kept OFF) |
| Submission Directory | `~/Exam_Submission` |
| Report File | `~/practical_exam_report.txt` |

---

## Phase 3: Practical Tasks & Commands Used

### Task 1 — The Hunt (Finding the Log Files)

Used the `find` command to search the entire filesystem for `.log` files owned by `root`, then filtered results for the two target files:

```bash
sudo find / -user root -name "*.log" 2>/dev/null | grep -E "forge_alpha.log|forge_beta.log"
```

**Breakdown:**
- `sudo find /` — searches the entire filesystem with elevated privileges
- `-user root` — filters for files owned by root
- `-name "*.log"` — matches files with a `.log` extension
- `2>/dev/null` — suppresses permission-denied errors
- `| grep -E "..."` — narrows output to the two target files

**Files Located:**
- `/tmp/audit_internal/forge_alpha.log`
- `/var/opt/system_logs/forge_beta.log`

---

### Task 2 — The Extraction (Moving the Files)

Moved both log files into the `~/Exam_Submission` directory using `sudo`:

```bash
sudo mv /tmp/audit_internal/forge_alpha.log ~/Exam_Submission/
sudo mv /var/opt/system_logs/forge_beta.log ~/Exam_Submission/
```

**Breakdown:**
- `sudo` — required because the files are root-owned
- `mv` — moves the file from source to destination
- `~/Exam_Submission/` — the designated submission directory

---

### Task 3 — The Lockdown (Setting Read-Only Permissions)

Changed both files to read-only (`444`) to harden them against modification:

```bash
sudo chmod 444 ~/Exam_Submission/forge_alpha.log
sudo chmod 444 ~/Exam_Submission/forge_beta.log
```

**Breakdown:**
- `chmod 444` — sets read-only permissions for owner, group, and others
- No user (including root, without override) can write to or execute these files

**Permission Mapping:**

| Digit | Who | Permission |
|---|---|---|
| 4 | Owner | Read only |
| 4 | Group | Read only |
| 4 | Others | Read only |

---

### Task 4 — Theoretical Question (OSI Model)

**Question:** Which layer handles logical addressing (IP)?

**Answer:** The **Network Layer (Layer 3)** of the OSI model handles logical addressing, which is where IP (Internet Protocol) addressing lives.

| Layer | Name | Key Function |
|---|---|---|
| 7 | Application | User-facing protocols (HTTP, FTP) |
| 6 | Presentation | Encryption, formatting |
| 5 | Session | Session management |
| 4 | Transport | End-to-end delivery (TCP/UDP) |
| **3** | **Network** | **Logical addressing (IP), routing** |
| 2 | Data Link | MAC addressing, frames |
| 1 | Physical | Bits, cables, signals |

---

## Submission

```bash
# Verify the report
cat ~/practical_exam_report.txt

# Submit to Command
session-submit --session 17 --artifact ~/practical_exam_report.txt

# Git Flow
git add ~/practical_exam_report.txt
git commit -m "edited: W6 | S17 | Forge Final Exam Report"
git push
```

---

## Summary

| Task | Command Used | Status |
|---|---|---|
| Hunt | `sudo find / -user root -name "*.log" 2>/dev/null \| grep -E "..."` | ✅ Complete |
| Extraction | `sudo mv <source> ~/Exam_Submission/` | ✅ Complete |
| Lockdown | `sudo chmod 444 ~/Exam_Submission/<file>` | ✅ Complete |
| OSI Theory | Network Layer — Layer 3 | ✅ Complete |

---

*Session 17 | The Forge Final | Operator: Wend Tin Basile*