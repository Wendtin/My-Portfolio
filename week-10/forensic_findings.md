# FORENSIC FINDINGS REPORT (THE MALWARE AUTOPSY)

### WHO:
* External Threat Actor utilizing an initial access phishing campaign targeting TitanCorp network users.

### WHAT:
* The deleted executable 'Resume.exe' (located at Inode 582 in the /Downloads directory), which executed and spawned a hidden background process named
 'rootkit_beacon.exe' running under Process ID (PID) 4444.

### WHEN:
* 2026-05-18 22:54:47 (EDT) - Extracted directly from the creation/written timestamp metadata of the deleted filesystem entry.

### HOW:
* The malware establishes persistence by deploying a stealth background beacon ('rootkit_beacon.exe') that hides its active terminal window from the
 desktop view, enabling long-term, un-monitored Command & Control (C2) communications.
