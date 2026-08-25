# INCIDENT RESPONSE REPORT: PHANTOM PURSUIT
**Operator:** ## PHASE 1: SIEM CORRELATION
* **Initial Alert Source IP:** 198.51.100.44

## PHASE 2: LIVE TRIAGE & CHAIN OF CUSTODY
* **Suspicious Process ID (PID):** 9/nc
* **Evidence SHA256 Hash:** cdeea1c976310a243c17a312673f7c19dee07a5e28ad3b810fcd166074112388

## PHASE 3: DISK FORENSICS
* **Deleted File Inode Number:** 582
* **Extracted Payload Data:** Deleted artifact identified as Downloads/beacon.exe.
File was marked Not Allocated in FAT16 filesystem.
Associated sector: 108.
Payload extraction attempts using icat, blkcat, and strings returned no readable content (zero-byte deleted file).
