# Session 15: Bridging the Kingdoms — Unified Identity Management

**Course:** CYB Local 45 | **Session:** 15 | **Platform:** VirtualBox (Intel/AMD)

---

## Overview

This lab demonstrates a core enterprise systems administration skill: **cross-platform identity management**. The goal is to join an Ubuntu Linux VM to a Windows Active Directory domain (`titan.local`) so that a single Windows domain account (e.g., `Administrator@titan.local`) can authenticate and exercise full root-level authority on a Linux machine — no separate local Linux account required.

This mirrors how real organizations eliminate the overhead of managing separate local accounts on every Linux server by centralizing identity in Active Directory.

---

## Environment

| Component | Details |
|---|---|
| Windows Server | TITAN-DC01 — Domain Controller for `titan.local` |
| Linux Machine | Ubuntu VM |
| Virtualization | Oracle VirtualBox (NAT Network) |
| Domain Password | `ApexCyber2026!` |
| Key Tools | `realmd`, `sssd`, `visudo`, `realm` |

---

## Architecture Diagram

```
┌─────────────────────┐         ┌─────────────────────┐
│   TITAN-DC01        │         │   Ubuntu VM          │
│   Windows Server    │◄───────►│   Linux Machine      │
│   (Active Directory)│  NAT    │   (Domain Member)    │
│   DNS + Kerberos    │ Network │   realmd + sssd      │
└─────────────────────┘         └─────────────────────┘
         ▲
         │ DNS Resolution (titan.local)
         │ Kerberos Authentication
         ▼
  Domain Admins Group
  granted sudo (root) on Linux
```

---

## Phase 0: Hardware Safety Check (8GB RAM Laptops)

Running two VMs simultaneously on a low-RAM system requires careful memory allocation to prevent the host OS from freezing.

| VM | RAM Allocation | Start Mode |
|---|---|---|
| TITAN-DC01 | 2048 MB | Headless |
| Ubuntu VM | 1024 MB | Normal |

> **Rationale:** Leaving ~1.5GB of "headroom" for the host OS prevents memory swapping, which would cause the Domain Controller to time out during the Kerberos domain join handshake.

**Steps:**
1. Shut down both VMs.
2. In VirtualBox, go to each VM → **Settings → System → Motherboard → Base Memory** and apply the values above.
3. Start TITAN-DC01 via **Start → Headless Start**. Start Ubuntu normally.

---

## Phase 1: Prepare the Windows Domain Controller

The Domain Controller must have its firewall configured to accept incoming authentication requests from Linux.

1. Log into **TITAN-DC01**.
2. Open **PowerShell (Admin)** — right-click the Start button → *Windows PowerShell (Admin)*.
3. Run the provisioning script:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force;
curl.exe -L -o s15_win_prep.ps1 "https://gist.githubusercontent.com/grobbins-cell/6993b4390d77692a334f52738a8b441d/raw/86fa7ea883a148a256f0fb27a797c9683246624f/s15_win_prep.ps1";
.\s15_win_prep.ps1
```

> **What this does:** Opens the required firewall ports (Kerberos, LDAP, DNS) and ensures Active Directory is ready to authorize a Linux domain join.

---

## Phase 2: Prepare the Linux Machine (DNS & Bridge Setup)

Linux cannot locate the Windows domain until it knows where to look. This is solved by pointing Ubuntu's DNS resolver directly at the Domain Controller.

### 2a — Configure DNS

```bash
sudo nano /etc/resolv.conf
```

Add this line at the **very top** of the file (replace with your actual DC IP):

```
nameserver 10.0.2.10
```

Save and exit: `Ctrl+O` → `Enter` → `Ctrl+X`

### 2b — Verify Connectivity

```bash
ping titan.local
```

A successful reply confirms Linux can resolve and reach the domain.

### 2c — Run the Linux Provisioning Script

```bash
curl -sL https://gist.githubusercontent.com/grobbins-cell/c884ea4f1ff89716aca60dfe755c3a84/raw/d78b9ece2b24788eb21fd68536f6acfc6ad9a5f3/s15_linux_prep.sh | sudo bash
```

When prompted for an IP, enter your **Windows DC's Internal IP**.

> **What this does:** Installs `realmd` and `sssd` — the middleware that allows Linux to communicate with Active Directory using the Kerberos and LDAP protocols.

---

## Phase 3: Join Linux to the Active Directory Domain

### 3a — Discover the Domain

```bash
realm discover titan.local
```

Expected output includes `"Active Directory"` — confirming the domain is visible and joinable.

### 3b — Join the Domain

```bash
sudo realm join -U Administrator titan.local
```

Enter the domain password when prompted. Characters will not be visible as you type.

### 3c — Verify the Join

```bash
id Administrator@titan.local
```

A successful join returns a Linux `UID`/`GID` mapped to the Windows domain account, confirming Active Directory credentials are now recognized by the Linux system.

---

## Phase 4: Grant Domain Admins Root (sudo) Access

By default, domain users can log in but cannot escalate privileges on Linux. This step bridges that gap.

```bash
sudo visudo -f /etc/sudoers.d/domain_admins
```

Add the following line exactly as written:

```
%domain\ admins ALL=(ALL:ALL) ALL
```

Save and exit: `Ctrl+O` → `Enter` → `Ctrl+X`

> **What this does:** Grants every member of the Windows `Domain Admins` group full `sudo` (root) privileges on this Linux machine. The backslash (`\`) is required to escape the space in "Domain Admins" within the sudoers syntax.

---

## Phase 5: Final Proof — The Artifact

This step demonstrates that unified identity is fully operational.

```bash
# Step 1 — Switch to the Windows domain account
su - Administrator@titan.local

# Step 2 — Test root authority
sudo whoami
```

**Expected output:**
```
root
```

A response of `root` confirms that a Windows Active Directory account is now exercising full administrative authority over a Linux system — the lab objective is complete.

---

## Artifact & Submission

```bash
# Save the artifact
# (Screenshot your terminal showing Administrator@titan.local and the "root" output)
# Save it as:
~/unified_identity.png

# Submit
session-submit --session 15 --artifact ~/unified_identity.png
```

Take a VirtualBox snapshot named **"Session 15 Complete"** to preserve the configured state.

---

## Key Concepts Demonstrated

| Concept | Description |
|---|---|
| **Active Directory (AD)** | Microsoft's directory service for centralized identity and access management |
| **Kerberos** | The authentication protocol used by Windows domains; Linux uses it via `realmd` |
| **SSSD** | System Security Services Daemon — bridges Linux authentication to AD |
| **realmd** | Discovers and joins Active Directory domains from Linux |
| **sudoers** | Linux privilege escalation configuration; mapped to AD group membership here |
| **Unified Identity** | One account, one password, cross-platform administrative access |

---

## Challenges & Troubleshooting Log

> This section documents real issues encountered during execution and how they were diagnosed and resolved. This is the most valuable part of any lab writeup — it reflects actual engineering problem-solving, not just script execution.

---

### Challenge 1: Wrong Shell Interpreter (zsh vs bash)

**Environment:** Kali Linux uses `zsh` as its default shell, not `bash`.

**Symptom:**
```
zsh: unknown file attribute: h
```

**Root Cause:** `zsh` treats square brackets `[ ]` as glob patterns (file matching operators). The URL in the curl command contained brackets, which `zsh` tried to interpret as a file attribute expression instead of plain text.

**Fix:** Wrap the URL in double quotes to force `zsh` to treat it as a literal string:
```bash
curl -sL "https://gist.githubusercontent.com/..." | sudo bash
```

**Lesson:** Always quote URLs in shell commands, especially in `zsh` environments.

---

### Challenge 2: Provisioning Script Corrupted `/etc/resolv.conf`

**Symptom:**
```bash
$ cat /etc/resolv.conf
nameserver echo "----
```

**Root Cause:** The lab provisioning script was written for **Ubuntu**, which uses `systemd-resolved` to manage DNS. Kali Linux does not use `systemd-resolved` — it manages DNS directly via `/etc/resolv.conf`. When the script tried to restart a non-existent service, it failed mid-execution and wrote a raw `echo` string into the config file instead of an IP address.

```
sed: can't read /etc/systemd/resolved.conf: No such file or directory
Failed to restart systemd-resolved.service: Unit systemd-resolved.service not found.
```

**Fix:** Manually overwrite the corrupted file with the correct nameserver entry:
```bash
echo "nameserver 10.0.2.x" | sudo tee /etc/resolv.conf
```

**Verify:**
```bash
ping -c 3 titan.local
```

**Lesson:** Provisioning scripts are OS-specific. Always verify which init system and DNS manager your distro uses before running scripts written for a different environment.

---

### Challenge 3: `realm join` Failing Despite Packages Being Installed

**Symptom:**
```
realm: Couldn't join realm: Necessary packages are not installed:
sssd-tools sssd libnss-sss libpam-sss adcli
```

**Root Cause (Multi-layered):**

`realm` performs its own internal package check before attempting a domain join. On Kali, two things caused this to fail repeatedly:

1. The provisioning script's failed DNS setup meant `apt` could not reach external repositories during its install step, so some packages may not have been fully configured even if they were present.
2. Kali's package naming or registration can differ subtly from Ubuntu's, causing `realm`'s internal checker to not recognize packages it expects to find in specific locations.

**Attempted Fix — Force reinstall:**
```bash
sudo apt update && sudo apt install -y sssd-tools sssd libnss-sss libpam-sss adcli
```

**Output confirmed packages were already at newest version** — pointing to a `realm` package-detection bug on non-Ubuntu systems rather than a true missing dependency.

**Escalated Fix — Bypass `realm`, use `adcli` directly:**
```bash
sudo adcli join --domain=titan.local --login-user=Administrator
```

**Lesson:** `realmd` is designed and tested primarily against Ubuntu/RHEL. On Kali (Debian-based but non-standard), it can report false negatives on package checks. Using `adcli` directly bypasses the middle layer and communicates with Active Directory without the pre-flight dependency check.

---

### Challenge 4: DNS Resolution for External Repos Broken

**Symptom:** `apt update` threw repeated warnings:
```
Temporary failure resolving 'http.kali.org'
Temporary failure resolving 'download.docker.com'
```

**Root Cause:** Pointing `/etc/resolv.conf` exclusively at the Windows Domain Controller caused all DNS queries to route through it. The DC only knows how to resolve `titan.local` and internal resources — it does not forward public internet DNS queries, so external package repositories became unreachable.

**Fix Strategy:** This is an expected trade-off during the domain join process. Since all required packages were confirmed already installed, external DNS was not needed to complete the lab. In a production environment, the DC would be configured as a DNS forwarder, passing unknown queries upstream to a public resolver (e.g., `8.8.8.8`).

---

---

### Challenge 5: `realm` Cannot Verify Packages — PackageKit Not Available

**Symptom (verbose output):**
```
! PackageKit not available: The name org.freedesktop.PackageKit was not provided by any .service files
! Necessary packages are not installed: sssd-tools sssd libnss-sss libpam-sss adcli
realm: Couldn't join realm: Necessary packages are not installed
```

**Root Cause:** `realmd` uses **PackageKit** as its backend to verify installed packages before attempting a domain join. PackageKit is a cross-distro package management abstraction layer — it is present on Ubuntu and GNOME-based systems but is **not installed or running on Kali Linux by default**. Because `realm` could not query PackageKit, it assumed all required packages were missing and refused to proceed — even though every listed package was already installed and at its newest version.

**Fix — Bypass `realm` entirely, use `adcli` directly:**
```bash
sudo adcli join --domain=titan.local --login-user=Administrator
```

Then manually create the SSSD configuration that `realm` would have generated automatically:

```bash
sudo nano /etc/sssd/sssd.conf
```

```ini
[sssd]
domains = titan.local
config_file_version = 2
services = nss, pam

[domain/titan.local]
ad_domain = titan.local
krb5_realm = TITAN.LOCAL
realmd_tags = manages-system joined-with-adcli
cache_credentials = True
id_provider = ad
krb5_store_password_if_offline = True
default_shell = /bin/bash
ldap_id_mapping = True
use_fully_qualified_names = False
fallback_homedir = /home/%u@%d
access_provider = ad
```

Set strict permissions (required by SSSD — it will refuse to run if this file is world-readable):
```bash
sudo chmod 600 /etc/sssd/sssd.conf
sudo systemctl restart sssd
```

**Lesson:** `realmd` is a convenience wrapper. When it fails due to environment differences, the underlying tool (`adcli`) can be called directly. Understanding the tool stack — `realm` → `adcli` → Kerberos → Active Directory — allows you to surgically bypass layers that are non-functional.

---

### Challenge 6: Kerberos Preauthentication Failure

**Symptom:**
```
adcli: couldn't connect to titan.local domain: Couldn't authenticate as:
Administrator@TITAN.LOCAL: Preauthentication failed
```

**Root Cause:** Kerberos preauthentication is the first gate in Active Directory authentication. It fails under three conditions:

| Cause | Explanation |
|---|---|
| Incorrect password | Kerberos verifies credentials before issuing a ticket |
| Clock skew > 5 minutes | Kerberos uses timestamps as replay-attack protection; if the clocks differ by more than 5 minutes, the handshake is rejected |
| Account lockout | Too many failed attempts locks the AD account |

**Diagnosis Steps:**

1. **Verify password** — Re-type carefully; Linux passwords are case-sensitive and the `!` at the end is significant
2. **Check clock sync** — Compare timestamps on both machines:
   ```bash
   # On Kali
   date
   ```
   ```powershell
   # On Windows DC
   Get-Date
   ```
3. **Check for account lockout** (PowerShell on DC):
   ```powershell
   Get-ADUser -Identity "Administrator" -Properties LockedOut | Select-Object Name, LockedOut
   ```

**Fix — Unlock the account if locked:**
```powershell
Unlock-ADAccount -Identity "Administrator"
```

**Fix — Force time resync on Windows DC:**
```powershell
w32tm /resync
```

**Lesson:** Kerberos is time-dependent by design. In a real enterprise, all machines sync to a central NTP (Network Time Protocol) server — often the Domain Controller itself. In a lab environment, VM clocks can drift independently and cause authentication failures that look like password errors.

---

### Challenge 7: Troubleshooting a CLI-Only Windows Server (Server Core)

**Context:** TITAN-DC01 was running **Windows Server Core** — a minimal installation with no GUI. Standard graphical tools like "Active Directory Users and Computers" are not available.

**All administration must be done through PowerShell:**

| Task | PowerShell Command |
|---|---|
| Check account lockout status | `Get-ADUser -Identity "Administrator" -Properties LockedOut \| Select-Object Name, LockedOut` |
| Unlock an AD account | `Unlock-ADAccount -Identity "Administrator"` |
| Check current system time | `Get-Date` |
| Force NTP time resync | `w32tm /resync` |
| Open PowerShell from CMD prompt | `powershell` |

**Lesson:** Server Core is increasingly common in enterprise and cloud environments because it has a smaller attack surface and lower resource footprint than full GUI installations. Being able to administer Active Directory entirely through PowerShell is a critical real-world skill.

---

### Key Takeaway: Ubuntu vs. Kali Compatibility

| Factor | Ubuntu (Intended) | Kali Linux (Used) |
|---|---|---|
| Default shell | `bash` | `zsh` |
| DNS management | `systemd-resolved` | `/etc/resolv.conf` directly |
| `realm` compatibility | Native/tested | Partial — package detection issues |
| Init system | `systemd` | `systemd` (same) |
| Lab script compatibility | Full | Partial — manual fixes required |

Running this lab on Kali required manual diagnosis and remediation at three separate points that would have been automatic on Ubuntu. This gap between "lab environment" and "real-world environment" is a realistic representation of systems administration work.

---

## Skills Applied

- Virtual machine resource management and performance tuning
- Cross-platform network configuration (DNS, NAT)
- Active Directory domain join from a Linux client
- Linux privilege escalation configuration (`visudo`)
- Kerberos-based authentication across OS boundaries
- Enterprise identity management principles

---

*Portfolio artifact for CYB Local 45 — Session 15.*