# 🪤 S32 — The Tripwire: Custom IDS Rules

**Week 11 | Session 32 | Portfolio Artifact**

---

## 📋 Overview

This lab demonstrates the deployment and validation of a custom Intrusion Detection System (IDS) using **Suricata** against a Dockerized web server target. Two custom signatures were written, deployed, and confirmed to fire against simulated attack traffic.

---

## 🎯 Objectives

- Write custom Suricata rules in `.rules` format
- Deploy a Suricata sensor using Docker in network host mode
- Simulate ICMP and HTTP-layer attacks against a target web server
- Verify alerts fire correctly via `fast.log`

---

## 🛠️ Environment

| Component       | Details                          |
|----------------|----------------------------------|
| Host OS         | Kali Linux                       |
| IDS Engine      | Suricata 8.0.4                   |
| Target Server   | nginx:alpine (Docker container)  |
| Network         | Docker bridge — `ids_net`        |
| Target IP       | `172.90.0.10`                    |
| Rule File       | `~/IDS_Lab/custom_ids.rules`     |
| Log Output      | `~/IDS_Lab/logs/fast.log`        |

---

## 📄 Custom Rules

```
# Rule 1 — ICMP Ping Detection
alert icmp any any -> 172.90.0.10 any (msg:"ICMP Ping Detected"; sid:1000001; rev:1;)

# Rule 2 — Ghost_Bear Malware Scanner Detection
alert tcp any any -> 172.90.0.10 80 (msg:"Ghost_Bear Malware Scanner Detected"; content:"Ghost_Scanner_v1"; sid:1000002; rev:1;)
```

---

## ⚙️ Phase 1 — "The ICMP Trap"

**Goal:** Detect basic ping sweeps to the web server.

### Steps

**1. Write the rule**
```bash
nano ~/IDS_Lab/custom_ids.rules
# Add Rule 1 under the first placeholder
```

**2. Deploy the Suricata sensor**
```bash
docker run -d --name ids_sensor --network host \
  -v ~/IDS_Lab/custom_ids.rules:/etc/suricata/custom.rules \
  -v ~/IDS_Lab/logs:/var/log/suricata \
  jasonish/suricata:latest -S /etc/suricata/custom.rules -i br-1f950c3eaa0d
```

**3. Trigger the rule**
```bash
ping -c 1 172.90.0.10
```

**4. Verify the alert**
```bash
cat ~/IDS_Lab/logs/fast.log
```

### ✅ Expected Output
```
05/26/2026-22:22:32.116327  [**] [1:1000001:1] ICMP Ping Detected [**] [Classification: (null)] [Priority: 3] {ICMP} 172.90.0.1:8 -> 172.90.0.10:0
```

---

## ⚙️ Phase 2 — "The Malware Signature"

**Goal:** Detect a threat actor's malware scanner using a hardcoded User-Agent string.

### Steps

**1. Add the second rule**
```bash
nano ~/IDS_Lab/custom_ids.rules
# Add Rule 2 under the second placeholder
```

**2. Reload the sensor**
```bash
docker restart ids_sensor
sleep 10
```

**3. Simulate the attack**
```bash
curl -A "Ghost_Scanner_v1" http://172.90.0.10
```

**4. Verify both alerts**
```bash
cat ~/IDS_Lab/logs/fast.log
```

### ✅ Expected Output
```
05/26/2026-22:22:32.116327  [**] [1:1000001:1] ICMP Ping Detected [**] [Classification: (null)] [Priority: 3] {ICMP} 172.90.0.1:8 -> 172.90.0.10:0
05/26/2026-22:24:15.406309  [**] [1:1000002:1] Ghost_Bear Malware Scanner Detected [**] [Classification: (null)] [Priority: 3] {TCP} 172.90.0.1:33336 -> 172.90.0.10:80
```

---

## 🔍 Key Concepts

**Suricata Rule Anatomy**
```
alert <protocol> <src_ip> <src_port> -> <dst_ip> <dst_port> (msg:"..."; [options;] sid:XXXXXXX; rev:N;)
```

| Field      | Description                                      |
|------------|--------------------------------------------------|
| `alert`    | Action — log and generate an alert               |
| `icmp/tcp` | Protocol to match                                |
| `any`      | Wildcard for IP or port                          |
| `msg`      | Human-readable alert message                     |
| `content`  | Payload string to match (Phase 2)                |
| `sid`      | Unique signature ID (custom rules start at 1000001) |
| `rev`      | Rule revision number                             |

**Why Host Networking?**
Suricata must be launched with `--network host` and pointed at the Docker bridge interface (`br-XXXX`) to observe traffic between containers. Running it inside `ids_net` only exposes its own container's interface, causing it to miss inter-container traffic.

---

## 📁 Repository Structure

```
IDS_Lab/
├── custom_ids.rules      ← Custom Suricata signatures (artifact)
└── logs/
    ├── fast.log          ← Alert output (verified triggers)
    ├── eve.json          ← Full event log (JSON format)
    ├── stats.log         ← Engine statistics
    └── suricata.log      ← Engine startup and error log
```

---

## 🚀 Submission

```bash
session-submit --session 32 --artifact ~/IDS_Lab/custom_ids.rules

git add custom_ids.rules
git commit -m "edited: W11 | S32 | The Tripwire - Custom IDS Rules"
git push
```

---

*Portfolio artifact for cybersecurity lab series — legal lab environment only.*
