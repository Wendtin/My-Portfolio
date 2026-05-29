# Week 10 — Digital Forensics & Incident Response

**Fellow:** Wend Tin Basile Sam
**Repository:** https://github.com/Wendtin/My-Portfolio
**TKH Innovation Fellowship 2026 | Phase 1 | Cybersecurity**

## Overview

Week 10 introduced digital forensics and incident response (DFIR)
methodology. Sessions covered memory acquisition, artifact collection,
attack timeline reconstruction, and formal incident reporting. Work
included analysis of a simulated crime scene environment using forensic
tools to extract and preserve evidence while maintaining chain of
custody principles.

## Tools Used

| Tool | Purpose |
|------|---------|
| Volatility | Memory dump analysis |
| dd / acquisition tools | Evidence collection and imaging |
| ELK / Kibana | Log analysis and timeline visualization |
| file / strings | Basic artifact inspection |
| git | Version control and portfolio submission |

## Key Concepts

- Digital forensics methodology and chain of custody
- Memory acquisition and analysis with Volatility
- Attack timeline reconstruction from log and artifact data
- DFIR reporting standards and evidence documentation
- SIEM log analysis for incident investigation

## Artifacts

- `DigitalForensics_IR.md` — DFIR methodology and findings
- `forensic_findings.md` — detailed forensic analysis results
- `Incident_Response_Report.md` — formal incident response report
- `attack_timeline.csv` — reconstructed attack timeline
- `collection_log.txt` — evidence collection log
- `DFIR_Evidence/memory_dump.raw` — acquired memory image
- `DFIR_Evidence/system_artifacts.zip` — collected system artifacts
- `README_S29.md` / `S28_REAMDE.md` / `S30_README.md` — session writeups

## Challenges

Reconstructing a coherent attack timeline from fragmented log sources
required correlating timestamps across multiple evidence types. Analyzing
raw memory dumps to extract meaningful indicators of compromise demanded
familiarity with Volatility plugin output that improved progressively
across sessions.

## References

Ligh, M. H., Case, A., Levy, J., & Walters, A. (2014). *The art of
memory forensics*. Wiley.

NIST. (2012). *Computer security incident handling guide* (SP 800-61
Rev. 2). https://csrc.nist.gov/publications/detail/sp/800-61/rev-2/final