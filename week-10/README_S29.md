# 🩻 S29 — The Digital Autopsy: Memory Forensics & Deleted File Recovery

**Course:** Cybersecurity Operations  
**Week:** 10 | **Session:** 29  
**Category:** Digital Forensics & Incident Response (DFIR)

---

## 🧠 Overview

This lab simulates a post-compromise forensic investigation inside the
TitanCorp network. An employee executed a file named Resume.exe — a malware
dropper — which subsequently deleted itself to evade detection. Using memory
forensics and raw disk analysis, the objective is to recover the deleted
payload and reconstruct the full picture of the infection: who deployed it,
what it was, when it ran, and how it persisted.

---

## 🎯 Learning Objectives

- Simulate memory carving using `strings` and `grep` to surface hidden
  processes from a raw RAM image
- Understand how Volatility-style analysis works at the byte level
- Use The Sleuth Kit's `fls` to enumerate both active and deleted files
  directly from a raw disk image, bypassing the operating system
- Recover a deleted file using `icat` by targeting its inode number
- Extract threat intelligence (actor, payload, timestamp, persistence) from
  a recovered malware artifact
- Document findings in a structured forensic report (WHO / WHAT / WHEN / HOW)

---

## 🛠️ Tools & Techniques Used

| Tool / Command | Purpose |
|----------------|---------|
| `strings` | Extract human-readable text from binary memory images |
| `grep -i` | Filter strings for anomalous process indicators |
| `fls -r` | List all files (active + deleted) from a raw disk image |
| `icat` | Recover deleted file data by inode number |
| The Sleuth Kit (TSK) | Open-source digital forensics framework |
| `nano` | Document findings in the forensic report |
| `git` | Version-control and publish the artifact |

---

## 🔬 Lab Phases

### Phase 1 — Memory Forensics
Carved a raw RAM image (`memdump.raw`) using `strings` piped into `grep`
to simulate a Volatility `pslist` scan. Identified a hidden process with
no visible desktop window — a classic indicator of malware running
covertly in the background. Recorded the process name and PID.

### Phase 2 — Disk Forensics & File Recovery
Used `fls -r` to recursively enumerate the file system of a raw disk image
(`compromised_drive.dd`). Identified the deleted `Resume.exe` malware
dropper by its asterisk-prefixed inode in the file listing. Used `icat`
to extract the raw file data directly from the disk sectors, bypassing the
OS entirely. Analyzed the recovered payload to extract four key intelligence
fields documented in the final forensic findings report.

---

## 🔑 Key Concepts

**Why deleted files are recoverable** — Deletion in most file systems only
removes the pointer to the data (the inode entry), not the data itself.
The raw bytes remain on disk until overwritten. Forensic tools like The
Sleuth Kit read the inode table directly, making "deleted" files
fully recoverable until the sectors are reused.

**Memory Carving** — RAM holds a live snapshot of everything executing on
a system, including malware that hides from the OS process list. Carving
the raw memory image with tools like Volatility (or `strings`/`grep` for
simulation) can surface processes invisible to normal system commands.

**WHO / WHAT / WHEN / HOW Framework** — A structured intelligence model
used in incident response to rapidly communicate the essential facts of
a compromise: the threat actor, the payload, the infection timeline, and
the persistence mechanism used to survive reboots.

**Inode-Based Recovery** — Every file in a Unix/Linux filesystem has an
inode: a metadata record storing ownership, permissions, timestamps, and
pointers to the actual data blocks. `icat` uses this number to reach
directly into the raw disk and pull those blocks out, regardless of
whether the OS considers the file deleted.

---

## 📁 Artifact

- `forensic_findings.md` — Structured forensic report documenting the
  threat actor (WHO), malware payload (WHAT), infection timestamp (WHEN),
  and persistence mechanism (HOW) recovered from the deleted Resume.exe.

---

*Part of an ongoing cybersecurity operations portfolio documenting hands-on
lab work in penetration testing, DFIR, and network security.*