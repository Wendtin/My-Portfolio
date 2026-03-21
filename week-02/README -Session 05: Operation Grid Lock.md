# Session 05: Operation Grid Lock
### Pillar 7 — The Traveler's Guide | Subnet Interrogation Lab

---

## Overviewl

This lab simulates a real-world network isolation scenario where a misconfigured subnet mask has mathematically cut you off from the gateway. The terminal is online, the interface is up, but you cannot communicate with anything outside your subnet. The mission is to interrogate the binary math behind the fence, identify why you are isolated, expand the subnet mask to include the gateway, and document the fix.

**Core Concepts Practiced:**
- Subnetting and CIDR notation (`/26` vs `/24` vs `/27`)
- Binary conversion and OSI Layer 3 analysis
- Reading and interpreting `ipcalc` output
- Removing and re-adding IP addresses with `ip addr`
- Understanding why subnet mismatches cause silent isolation
- Calculating Network ID and Broadcast ID across multiple subnet sizes

---

## The Scenario

A provisioning script assigned `10.50.50.150/26` to `eth0`. The gateway is `10.50.50.1`. Even though the interface is up and the IP is assigned, you cannot ping the gateway — not because of a broken wire, but because of a **mathematical fence**.

```bash
curl -sL https://gist.githubusercontent.com/grobbins-cell/957530a3e86379a6af202b2e3949d37a/raw/458b2535e2cc1a71cf6f1fcbe125fd287b451fcb/subnet_blueprint.txt | sudo bash
```

Output:
```
[+] S05 Provisioning Complete. Host is isolated on the /26 fence.
```

> **Key Lesson:** A host can have a valid IP, a live interface, and a correct gateway configured — and still be completely isolated. If the subnet mask places the gateway outside your usable host range, the OS won't even attempt to route packets to it. This is a silent failure with no obvious error.

---

## The Binary Proof

### Step 1 — Confirm the assigned IP
```bash
ip addr
```

Observed output (relevant section):
```
2: eth0: ...
    inet 10.0.2.15/24 ...
    inet 10.50.50.150/26 scope global eth0
```

Both IPs were present on `eth0`. The sabotage IP `10.50.50.150/26` was confirmed.

---

### Step 2 — Binary Interrogation in Python
```bash
python3
```
```python
print(bin(150))   # Your last octet
print(bin(1))     # Gateway's last octet
```

Output:
```
0b10010110   # 150 in binary
0b1          # 1 in binary (padded: 00000001)
```

**Side by side:**

| Host | Last Octet | Binary |
|---|---|---|
| You (`10.50.50.150`) | 150 | `10 010110` |
| Gateway (`10.50.50.1`) | 1 | `00 000001` |

A `/26` mask locks the **first 2 bits** of the last octet. Your IP's first 2 bits are `10`. The gateway's first 2 bits are `00`. They don't match — you are in **different subnets**. The OS sees the gateway as unreachable before a single packet is ever sent.

---

### Step 3 — Confirm with ipcalc
```bash
ipcalc 10.50.50.150/26
```

Output:
```
Network:   10.50.50.128/26
HostMin:   10.50.50.129
HostMax:   10.50.50.190
Broadcast: 10.50.50.191
Hosts/Net: 62
```

**The verdict:** Your usable range is `.129` to `.190`. The gateway at `.1` is completely outside this range — invisible to your host.

---

## The Fix

### Step 4 — Remove the fenced IP
```bash
sudo ip addr del 10.50.50.150/26 dev eth0
```

### Step 5 — Add it back with the correct mask
```bash
sudo ip addr add 10.50.50.150/24 dev eth0
```

A `/24` mask covers `10.50.50.0` to `10.50.50.255` — the full range, which includes the gateway at `.1`.

### Step 6 — Verify the change
```bash
ip addr show eth0
```

Confirmed output:
```
inet 10.50.50.150/24 scope global eth0
```

`/26` is gone. `/24` is in place. ✅

---

## Why the Ping Still Showed "Unreachable"

```
From 10.50.50.150 icmp_seq=1 Destination Host Unreachable
4 packets transmitted, 0 received, +4 errors, 100% packet loss
```

After applying the `/24` fix, `ping 10.50.50.1` returned `Destination Host Unreachable`. This is **expected in a lab environment** — `10.50.50.1` is a simulated gateway with no real host responding behind it. The important distinction:

| Error | Meaning |
|---|---|
| `Network is unreachable` | Subnet mask wrong — OS won't even try |
| `Destination Host Unreachable` | Subnet is correct — OS tried, no one answered |

Getting `Destination Host Unreachable` **proves the fix worked**. The fence is down. The OS is now attempting to reach the gateway. In a production network with a real router at `.1`, the ping would succeed.

---

## Artifact: subnet_blueprint.txt

The final artifact documents the corrected `/24` network and includes a `/27` subnet analysis for CIDR alignment study.

### Corrected Network — /24 Analysis

```
Address:   10.50.50.150         00001010.00110010.00110010. 10010110
Netmask:   255.255.255.0 = 24   11111111.11111111.11111111. 00000000
Wildcard:  0.0.0.255            00000000.00000000.00000000. 11111111
=>
Network:   10.50.50.0/24
HostMin:   10.50.50.1
HostMax:   10.50.50.254
Broadcast: 10.50.50.255
Hosts/Net: 254
```

The gateway `10.50.50.1` is now within the usable range (`.1` to `.254`). ✅

---

### /27 Subnet Analysis

```
Address:   10.50.50.150         00001010.00110010.00110010.100 10110
Netmask:   255.255.255.224 = 27 11111111.11111111.11111111.111 00000
Wildcard:  0.0.0.31             00000000.00000000.00000000.000 11111
=>
Network:   10.50.50.128/27
HostMin:   10.50.50.129
HostMax:   10.50.50.158
Broadcast: 10.50.50.159
Hosts/Net: 30
```

**Key values for a /27:**

| Field | Value |
|---|---|
| Network ID | `10.50.50.128` |
| Broadcast ID | `10.50.50.159` |
| Usable Hosts | 30 |
| Mask | `255.255.255.224` |

> **Note:** A `/27` gives you only 30 usable hosts per block and splits the last octet into 8 blocks of 32. The host `10.50.50.150` falls in the `10.50.50.128/27` block. This is still too small to include the gateway at `.1` — which lives in the `10.50.50.0/27` block. Only a `/24` is large enough to bridge the gap.

---

## Artifact Generation Commands

```bash
ipcalc 10.50.50.150/24 > ~/subnet_blueprint.txt
echo "---/27 SUBNET ANALYSIS---" >> ~/subnet_blueprint.txt
ipcalc 10.50.50.150/27 >> ~/subnet_blueprint.txt
```

## GitHub Deployment

```bash
git add subnet_blueprint.txt
git commit -m "S05: Subnet calculation and CIDR alignment for Operation Grid Lock"
git push origin main
```

## Operational Submission

```bash
session-submit --session 05 --artifact ~/subnet_blueprint.txt
```

---

## Command Quick Reference

| Command | Purpose |
|---|---|
| `ip addr` | View all assigned IPs and their masks |
| `ip addr show eth0` | View a specific interface |
| `python3` → `print(bin(150))` | Convert decimal to binary for subnet analysis |
| `ipcalc 10.50.50.150/26` | Visualize original broken subnet |
| `sudo ip addr del 10.50.50.150/26 dev eth0` | Remove the misconfigured IP |
| `sudo ip addr add 10.50.50.150/24 dev eth0` | Add the corrected IP with proper mask |
| `ping -c 4 10.50.50.1` | Test gateway reachability |
| `ipcalc 10.50.50.150/24` | Confirm corrected subnet range |
| `ipcalc 10.50.50.150/27` | Analyze /27 Network and Broadcast IDs |

---

## Key Takeaways

1. **Subnet masks are mathematical fences.** A `/26` divides a `/24` into 4 smaller blocks. If your gateway lives in a different block, you are silently isolated — no error, no warning, just no communication.

2. **Binary math is not optional.** The only way to truly understand why two hosts can't communicate is to look at the bits. `150 = 10010110`, `1 = 00000001` — the first two bits don't match under a `/26`, case closed.

3. **`ipcalc` is your best friend.** It translates CIDR math into human-readable HostMin/HostMax ranges instantly. Always run it when diagnosing subnet issues.

4. **Smaller masks = smaller blocks.** `/27` = 30 hosts, `/26` = 62 hosts, `/24` = 254 hosts. The smaller the number after the slash, the larger the network. Always choose a mask that keeps your gateway and your host in the same block.

5. **"Unreachable" has two meanings.** `Network is unreachable` = wrong subnet mask. `Destination Host Unreachable` = correct subnet, no host responding. Knowing the difference tells you exactly which layer the problem is on.

---

## Artifacts Submitted

| Artifact | Description |
|---|---|
| `subnet_blueprint.txt` | ipcalc output for corrected `/24` network + `/27` subnet analysis with Network and Broadcast IDs |

---

*T1-M1-S05 | Pillar 7: The Traveler's Guide | Operation Grid Lock*