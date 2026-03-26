# W3 | S09 — Automated System Auditor

## Overview
A Python-based system auditing script that scans running processes and generates a structured JSON alert if an unauthorized process is detected on the host machine.

---

## Objectives
- Use Python's `subprocess` module to execute system commands programmatically
- Parse live process data from the operating system
- Implement threat detection logic using string matching
- Export structured alert data to a JSON file

---

## Files
| File | Description |
|---|---|
| `system_auditor.py` | Main audit script |
| `security_alert.json` | Generated alert output (created at runtime) |

---

## How It Works
1. The script runs `ps aux` via `subprocess.run()` to capture all active system processes
2. It searches the output for a known malicious process: `unauthorized_cryptominer`
3. If the threat is detected, it builds an alert dictionary and exports it to `security_alert.json`
4. A completion message is printed to the terminal upon finishing

---

## Usage

**Run the auditor:**
```bash
python3 ~/system_auditor.py
```

**Verify the alert output:**
```bash
cat security_alert.json
```

---

## Example Output

```json
{
    "event": "Unauthorized Process",
    "severity": "High",
    "process": "unauthorized_cryptominer"
}
```

---

## Concepts Covered
- `subprocess.run()` with `capture_output=True` and `text=True`
- Standard output parsing (`.stdout`)
- Conditional threat detection logic
- File I/O with `open()` in write mode
- JSON serialization with `json.dump()`

---

## Author
wendkali  
Session 09 — Week 3