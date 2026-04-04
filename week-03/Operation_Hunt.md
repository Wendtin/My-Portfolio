# Operation Automated Hunt
**P1 · W3 · TLAB-03** | Python 3.10+ | Ubuntu 22.04 LTS

---

## Project Overview

This lab simulates a real-world cybersecurity incident response workflow. A brute-force SSH attack has occurred against a server. The objective is to write a Python automation script that reads raw security logs, extracts attacker IP addresses, and exports a structured JSON threat report — the kind of artifact a SOC analyst or incident responder would produce.

---

## Skills Synthesized

| Skill | Description |
|-------|-------------|
| **File I/O (S08)** | Reading/writing files and exporting structured JSON output |
| **Subprocess (S09)** | Executing shell commands (`grep`) from within Python |
| **Stream Parsing (S03)** | Parsing multi-line text output and extracting fields by position |

---

## Artifact

| Field | Value |
|-------|-------|
| Script | `incident_response.py` |
| Output | `threat_report.json` |
| Input Log | `/var/log/titan_sim/auth_sim.log` |
| Attack Type | SSH Brute Force (Failed password events) |
| Libraries | `subprocess`, `json` (standard library only) |

---

## Phase Breakdown

### Phase 1 — Log Interrogation (`subprocess`)

Instead of opening the log file manually, `subprocess.run()` executes a `grep` command directly — mirroring how a sysadmin would hunt for failed logins in the terminal. This approach wraps existing shell utilities inside Python automation.

- `capture_output=True` — captures stdout without printing to the terminal
- `text=True` — automatically decodes bytes to a Python string
- `.stdout` — stores the raw multi-line grep result for the next phase

### Phase 2 — Data Parsing (stream parsing)

Each log line follows a consistent format, which allows reliable field extraction by index. Splitting on whitespace and grabbing position `[10]` isolates the attacker IP on every line.

```
Mar  27  10:14:32  titan  sshd[1234]:  Failed  password  for  root  from  192.168.1.45
 0    1      2       3        4           5        6       7    8     9        [10]
```

An `if line:` guard filters out empty trailing lines before splitting, preventing `IndexError` exceptions.

### Phase 3 — JSON Export (File I/O)

The extracted IP list is packaged into a Python dictionary and written to disk using `json.dump()`. JSON is the universal format for structured security data — readable by SIEMs, alerting systems, ticketing platforms, and downstream scripts.

```json
{
    "alert_type": "Brute Force",
    "attacker_ips": [
        "192.168.1.45",
        "10.0.0.23"
    ]
}
```

---

## Full Script

```python
import subprocess
import json

# Phase 1: Run grep via subprocess to find all failed login attempts
result = subprocess.run(
    ["grep", "Failed password", "/var/log/titan_sim/auth_sim.log"],
    capture_output=True,
    text=True
)

raw_output = result.stdout

# Phase 2: Parse the output and extract IP addresses
lines = raw_output.split('\n')
attacker_ips = []

for line in lines:
    if line:  # skip empty lines
        ip = line.split(" ")[10]  # IP is always at index 10
        attacker_ips.append(ip)

# Phase 3: Build and export the JSON threat report
alert_data = {
    "alert_type": "Brute Force",
    "attacker_ips": attacker_ips
}

with open("threat_report.json", "w") as file:
    json.dump(alert_data, file, indent=4)

print("Threat report generated successfully.")
print(f"Total attacking IPs found: {len(attacker_ips)}")
```

---

## Reflection

This lab demonstrated how Python can serve as a force multiplier in security operations. By combining `subprocess` with standard parsing and file I/O, a single script automates what would otherwise be several manual terminal steps. The resulting JSON artifact is immediately portable — it could feed a dashboard, alerting system, or ticketing workflow without modification.

The key conceptual takeaway: log files are structured data masquerading as plain text. Once you identify the consistent delimiter pattern, extraction becomes trivial — and automation becomes reliable.