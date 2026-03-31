# Session 04: Operation Broken Link
### Pillar 7 — The Traveler's Guide | Network Triage Lab

---

## Overview

This lab simulates a real-world SOC scenario where a network interface has been intentionally disabled on a remote VM. The mission is to diagnose the failure across the OSI model, restore connectivity layer by layer, and document the recovery for HQ.

**Core Concepts Practiced:**
- Layer 2 (Data Link): Bringing a downed network interface back up
- Layer 3 (Network): Verifying IP address assignment and restoring a missing default route
- Out-of-Band (OOB) console access as a recovery method
- Network artifact generation and submission

---

## The Scenario

A provisioning script (`curl ... | sudo bash`) was run to set up the lab environment. This script **intentionally sabotaged the network** by running:

```bash
ip link set [interface] down
ip route del default
```

Because the student was connected via SSH, disabling the network interface immediately killed the SSH session — locking them out of the VM through the normal channel. This is the **"Broken Link"** scenario.

> **Key Lesson:** If you accidentally bring down your primary interface over SSH, you are locked out. The only way back in is through an **Out-of-Band console** — a direct terminal provided by your cloud or VM manager that does not rely on the network interface.

---

## Recovery Walkthrough

### Pre-requisite: Access the OOB Console

Since SSH was broken, the web-based console (provided by the cloud/VM manager) was used to log in directly. No network required.

---

### Phase 1 — Opening the Pipe (Layer 2)

**Step 1: Test for Life**
```bash
ping -c 4 8.8.8.8
```
Expected output: `Network is unreachable`

This confirms the wire is cut and the network interface is down.

---

**Step 2: Check the Valve**
```bash
ip link
```
Look for an interface (e.g., `eth0` or `ens3`) showing `state DOWN`.

Example output:
```
2: eth0: <BROADCAST,MULTICAST> state DOWN mtu 1500 ...
```

---

**Step 3: Bring the Interface Up**
```bash
sudo ip link set eth0 up
```
Replace `eth0` with whatever interface was found in Step 2. This restores Layer 2 (the physical/data link pipe).

---

### Phase 2 — Finding the Exit (Layer 3)

**Step 4: Verify IP Address**
```bash
ip addr
```
Look for a `10.0.0.x` (or `10.0.2.x`) address assigned to the interface.

In this lab, the IP (`10.0.2.15/24`) was already present — the script did not flush it:
```
Error: ipv4: Address already assigned.
```
✅ This is expected and good — skip manual IP assignment if you see this.

---

**Step 5: Check the Routing Table**
```bash
ip route
```
Look for a `default` route. If missing, the VM has no path to reach the internet.

In this lab, the route was also already present:
```
default via 10.0.2.2 dev eth0 proto dhcp src 10.0.2.15 metric 100
10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15 metric 100
```

> **Note:** The lab briefing referenced gateway `10.0.0.1`, but the actual VM gateway was `10.0.2.2`. Always verify with `ip route` or `cat ~/portfolio/session_04/briefing.txt` rather than assuming.

If the default route **is** missing, restore it with:
```bash
sudo ip route add default via [gateway_ip]
```

---

**Step 6: Verify Full Connectivity**
```bash
ping -c 4 8.8.8.8
```
Successful output:
```
64 bytes from 8.8.8.8: icmp_seq=1 ttl=255 time=511 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=255 time=259 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=255 time=261 ms
64 bytes from 8.8.8.8: icmp_seq=4 ttl=255 time=259 ms
--- 8.8.8.8 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss
```
✅ 0% packet loss = the bridge is rebuilt.

---

### Phase 3 — The Filing

**Step 7: Generate the Audit Artifact**
```bash
ip addr > ~/network_audit.txt
ping -c 4 8.8.8.8 >> ~/network_audit.txt
```

> **Important:** `>` creates (or overwrites) the file. `>>` appends to it. Always run `ip addr` first.

**Step 8: Submit**
```bash
session-submit --session 04 --artifact network_audit.txt
```

---

## Command Quick Reference

| Command | Purpose |
|---|---|
| `ping -c 4 8.8.8.8` | Test external connectivity |
| `ip link` | List interfaces and their state (UP/DOWN) |
| `sudo ip link set eth0 up` | Bring a downed interface up (Layer 2) |
| `ip addr` | View IP addresses assigned to interfaces |
| `sudo ip addr add [ip]/24 dev eth0` | Manually assign an IP (if flushed) |
| `ip route` | View the routing table |
| `sudo ip route add default via [gw]` | Restore the default gateway (Layer 3) |
| `cat ~/portfolio/session_04/briefing.txt` | View lab briefing (contains gateway IP) |

---

## Key Takeaways

1. **OOB Console = Your Lifeline.** In a SOC, if you misconfigure a remote server's network, the out-of-band console is how you "walk over to the machine" without physically being there.

2. **Layer by Layer.** Troubleshooting always starts at the bottom of the OSI model. Check Layer 2 (is the interface up?) before Layer 3 (does it have an IP and a route?).

3. **Verify, Don't Assume.** The lab briefing said the gateway was `10.0.0.1` — the actual gateway was `10.0.2.2`. Always read your environment first.

4. **`>` vs `>>` Matter.** Using `>` twice will overwrite your first command's output. Always append with `>>` after the first write.

---

## Artifacts Submitted

| Artifact | Description |
|---|---|
| `network_audit.txt` | Output of `ip addr` and `ping -c 4 8.8.8.8` confirming restored connectivity |

---

*T1-M1-S04 | Pillar 7: The Traveler's Guide | Operation Broken Link*