# 🧠 S30 — The Central Nervous System
### SIEM Log Correlation & Attack Timeline Reconstruction

**Program:** Offensive Security & Penetration Testing  
**Week:** 10 | **Session:** 30  
**Environment:** Kali Linux VM + Dockerized ELK Stack (Elasticsearch, Logstash, Kibana)  
**Date Completed:** May 28, 2026

---

## 🎯 Objective

Simulate a real-world SOC analyst workflow by ingesting enterprise logs into a SIEM (Kibana), hunting for indicators of compromise, and reconstructing a full attacker timeline — from initial access through data exfiltration — using log correlation across multiple log source types.

---

## 🛠️ Tools & Technologies

| Tool | Purpose |
|------|---------|
| Elasticsearch | Log indexing and storage engine |
| Kibana (ELK Stack) | SIEM interface for log search and visualization |
| Docker (`sebp/elk`) | Self-contained ELK deployment |
| KQL (Kibana Query Language) | Log hunting queries |
| Bash / curl | Provisioning, data injection, and verification |
| nano | CSV artifact editing |
| Git | Portfolio artifact submission |

---

## 🏗️ Environment Setup

### 1. Provisioned the ELK Stack via Docker

A provisioning script was executed to deploy a local resource-optimized ELK stack and inject mock enterprise logs:

```bash
curl -sL https://gist.githubusercontent.com/grobbins-cell/.../s30_provision.sh | tr -d '\r' | sudo bash
```

The `sebp/elk` Docker image runs Elasticsearch, Logstash, and Kibana in a single container, exposing:
- Port `9200` → Elasticsearch API
- Port `5601` → Kibana UI

### 2. Verified Data Ingestion

Confirmed the `enterprise_logs` index was populated:

```bash
curl -s http://localhost:9200/_cat/indices?v
```

```
health status index           docs.count  store.size
yellow open   enterprise_logs          4      32.1kb
```

### 3. Configured Kibana Data View

- Navigated to: `Stack Management → Data Views → Create data view`
- Index pattern: `enterprise_logs*`
- Timestamp field: `@timestamp`
- Adjusted time range to `Jan 1, 2020 → now` to capture mock log timestamps

---

## 🔍 SIEM Queries & Findings

### Phase 1 — Initial Access Hunt

**Query:**
```
event_type: "Failed Login"
```

**Result:** Identified the attacker's external IP from a failed authentication attempt against the admin account.

---

### Phase 2 — Web Server Correlation

**Query:**
```
source_ip: "198.51.100.44"
```

**Result:** Found the web server event showing malicious payload delivery via HTTP POST.

---

### Phase 3 — Lateral Movement

**Query:**
```
"Domain Admin"
```

**Result:** Correlated a Windows Security log showing successful privilege escalation to Domain Admin from an internal host.

---

### Phase 4 — Exfiltration

**Query:**
```
source_ip: "10.0.5.15"
```

**Result:** Firewall log revealed a 4.5 GB outbound data transfer to the attacker's external IP over port 443.

---

## 📊 Attack Timeline — Final Artifact

| Timestamp | Source IP | Event Type | Action | Description |
|-----------|-----------|------------|--------|-------------|
| 2026-04-30 06:15:00 | 198.51.100.44 | Web Server | Initial Access | POST /api/upload - 200 OK - Malicious payload executed |
| 2026-04-30 06:25:00 | 10.0.5.15 | Windows Security | Lateral Movement | Event ID 4624: Successful Logon - User escalated to Domain Admin |
| 2026-04-30 06:45:00 | 10.0.5.15 | Firewall | Exfiltration | Outbound traffic anomalous volume: 4.5 GB transferred over port 443 |

**Total breach window:** 30 minutes (06:15 → 06:45)

---

## 🚧 Troubleshooting Encountered

| Problem | Root Cause | Resolution |
|---------|-----------|------------|
| Kibana "No data" screen | `sebp/elk` takes 3–5 min to fully boot; provisioning script injected data before ES was ready | Waited for full boot, re-ran provisioning script |
| Empty Elasticsearch indices | Data injection ran against an unready cluster | Verified cluster health via `curl localhost:9200/_cluster/health`, re-injected |
| "No results" in Discover | Default time range was "Last 15 minutes"; mock logs had older timestamps | Used "Search entire time range" / set range to 2020–now |
| Index Patterns not found | Lab written for Kibana 7.x; running Kibana 8.x where it's renamed "Data Views" | Navigated to `/app/management/kibana/dataViews` |

---

## 📁 Submission

```bash
# Verify artifact
cat ~/attack_timeline.csv

# Submit to course system
session-submit --session 30 --artifact ~/attack_timeline.csv

# Push to GitHub
git add attack_timeline.csv
git commit -m "edited: W10 | S30 | The Central Nervous System - Attack Timeline"
git push
```

---

## 💡 Key Takeaways

- **SIEM correlation is about chaining events across log sources** — no single log tells the whole story. The attacker's path only became visible by pivoting from IP to IP across web, Windows, and firewall logs.
- **Time range configuration in Kibana is critical** — mock or historical log data requires manual range adjustment; default "last 15 minutes" will always return empty results.
- **Docker-based lab environments require boot patience** — the ELK stack needs 3–5 minutes to fully initialize before data injection is reliable.
- **KQL is powerful for targeted hunting** — simple field:value queries like `event_type: "Failed Login"` or `source_ip: "10.0.5.15"` are enough to reconstruct a full breach chain when used methodically.
- **Real SOC analysts do exactly this** — this lab mirrors the core workflow of a Tier 1 analyst responding to an alert: find the IOC, pivot on it, follow the chain, document the timeline.
