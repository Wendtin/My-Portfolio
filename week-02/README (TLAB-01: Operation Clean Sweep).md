# 🛡️ TLAB-01: Operation Clean Sweep

**Category:** Incident Response & System Recovery  
**Difficulty:** Beginner–Intermediate  
**Skills Demonstrated:** Linux Navigation · File Permissions · Stream Editing (grep, sed, awk, sort, uniq)

---

## 📋 Overview

A simulated post-compromise server environment where an attacker left behind a sabotaged log file and a broken directory structure. The objective was to navigate a locked-down file system, restore appropriate permissions, and extract forensic evidence using Linux command-line tools.

**Final Deliverable:** `final_threat_report.txt` — a deduplicated list of attacker IP addresses extracted from a 5,000-line noisy log file.

---

## 🎯 Objectives

- Locate a hidden directory in a non-standard path
- Repair file and directory permissions set to `000` by an attacker
- Transfer file ownership to enable processing
- Build a multi-stage shell pipeline to filter, cleanse, and extract forensic data

---

## 🗂️ Lab Phases

### Phase 1 — The Maze (Navigation)

Located a hidden directory `.evidence_cache` inside `/var/tmp/` using `ls -la` to reveal hidden entries. Confirmed that the directory and its contents were inaccessible due to zeroed-out permissions.

```bash
ls -la /var/tmp/
sudo ls -la /var/tmp/.evidence_cache/
```

---

### Phase 2 — The Locksmith (Permissions)

Restored minimum viable access to the directory and log file using `chmod`, then transferred ownership with `chown` so the file could be processed under my user account.

```bash
# Grant execute + read on the directory (enter + list)
sudo chmod 500 /var/tmp/.evidence_cache

# Grant read-only on the log file (preserve evidence integrity)
sudo chmod 400 /var/tmp/.evidence_cache/raw_incident.log

# Transfer ownership from root to current user
sudo chown $USER /var/tmp/.evidence_cache/raw_incident.log
```

| Permission | Code | Meaning |
|------------|------|---------|
| Directory  | `500` | Owner: read + execute (enter). Group/Others: none |
| Log File   | `400` | Owner: read only. Group/Others: none |

---

### Phase 3 — The Surgery (Stream Editing)

Built a full pipeline to process 5,000 lines of log noise down to a clean list of unique attacker IPs.

```bash
grep "CRITICAL" /var/tmp/.evidence_cache/raw_incident.log \
  | sed 's/UserAgent: MalwareBot\/1.0//g' \
  | awk '{print $1}' \
  | sort | uniq \
  > ~/final_threat_report.txt
```

**Pipeline Breakdown:**

| Tool | Purpose |
|------|---------|
| `grep "CRITICAL"` | Filter to only malicious log entries |
| `sed 's/...//'` | Strip the `UserAgent: MalwareBot/1.0` string from each line |
| `awk '{print $1}'` | Extract column 1 (IP addresses) from each line |
| `sort` | Sort IPs so duplicates are adjacent |
| `uniq` | Deduplicate — one entry per unique attacker IP |
| `> ~/final_threat_report.txt` | Write clean output to the deliverable file |

---

## 🧠 Key Concepts Practiced

**Linux Navigation**
- `ls -la` to reveal hidden files/directories (dotfiles)
- `cd` behavior with restricted permissions
- Using `sudo` to inspect root-owned resources

**File Permissions**
- Octal permission notation (`chmod 500`, `chmod 400`)
- Directory execute bit = traverse/enter permission
- `chown` to transfer ownership and enable user-level access

**Stream Editing Pipeline**
- `grep` for pattern-based line filtering
- `sed` substitution syntax: `s/FIND/REPLACE/g`
- `awk` field extraction: `$1` for first whitespace-delimited column
- `sort | uniq` pattern for deduplication (sort must precede uniq)
- Shell output redirection with `>`

---

## 📁 Repository Structure

```
tlab-01-operation-clean-sweep/
├── README.md                  # This file
└── final_threat_report.txt    # Extracted attacker IPs (lab output)
```

---

## 🚀 How to Reproduce

1. Provision a Linux environment (Ubuntu/Debian recommended)
2. Run the lab setup script:
   ```bash
   curl -sL https://gist.githubusercontent.com/grobbins-cell/b902fe78642dc3d1a419a93a5c8be660/raw/66633b4b47fdec95f04fea1ea3cf6fb914aa2184/setup_tlab_01.sh | bash
   ```
3. Follow the three phases above in order
4. Submit with:
   ```bash
   session-submit --session TLAB01 --artifact ~/final_threat_report.txt
   ```

---

## 🔖 Tags

`linux` `bash` `incident-response` `permissions` `chmod` `grep` `sed` `awk` `forensics` `cybersecurity` `homelab`