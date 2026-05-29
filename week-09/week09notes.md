# Week 09 — Web Application Security

**Fellow:** Wend Tin Basile Sam
**Date:** May 27, 2026
**Repository:** https://github.com/Wendtin/My-Portfolio
**TKH Innovation Fellowship 2026 | Phase 1 | Cybersecurity**

## Overview

Week 09 focused on web application attack techniques and security
assessment methodology. Sessions covered SQL injection, cross-site
scripting (XSS), cross-site request forgery (CSRF), broken object-level
authorization (BOLA), and API security auditing. Attacks were performed
against intentionally vulnerable lab applications in a controlled
environment.

## Tools Used

| Tool | Purpose |
|------|---------|
| Burp Suite | HTTP interception and web app analysis |
| curl | Manual HTTP request crafting |
| sqlmap | Automated SQL injection testing |
| Python/Flask | Target web application environment |
| git | Version control and portfolio submission |

## Key Concepts

- SQL injection: error-based, union-based, and blind techniques
- XSS: reflected and stored payload injection
- CSRF: token bypass and forged request construction
- BOLA: broken object-level authorization in REST APIs
- OWASP Top 10 mapping for identified vulnerabilities
- API security auditing and authentication bypass

## Artifacts

- `SQL_Injection_Exploitation_Lab.md` — SQLi methodology and findings
- `XSS_CSRF_Exploitation.md` — XSS and CSRF exploitation writeup
- `API_securityAudit.md` — API security audit report
- `OmniPortal_assessment.md` — full web application assessment
- `README_WebApp_SecAssessment.md` — TLAB submission writeup
- `sqli_report.txt` — SQL injection findings output
- `xss_payloads.txt` — XSS payload list used during testing
- `api_audit.log` — raw API audit log

## Challenges

Distinguishing between blind SQL injection responses and normal
application behavior required careful baseline comparison. Crafting
valid CSRF proof-of-concept payloads that bypassed token validation
demanded precise understanding of the target application's session
management logic.

## References

OWASP Foundation. (2024). *OWASP top ten*.
https://owasp.org/www-project-top-ten/

PortSwigger. (2024). *Web security academy*.
https://portswigger.net/web-security