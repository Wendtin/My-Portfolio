# TITANCORP: PERIMETER ASSESSMENT REPORT
**Operator:** **Target Subnet:** 172.88.0.0/24

## PHASE 1: ACTIVE ENUMERATION (NMAP)
*(List the live IPs discovered and their running services/versions)*
* **Host 1 (172.88.0.10):** 80/tcp - nginx 1.14.2 (http)
* **Host 2 (172.80.0.15):** All 1000 scanned ports are closed
* **Host 3 ([Insert IP]):** 80/tcp - Apache httpd 2.4.66 ((unix))

## PHASE 2: VULNERABILITY AUDIT (NIKTO)
*(Run Nikto against the TWO web servers discovered above. List one major finding for each.)*
* **Web Server 1 Finding:** 172.88.0.10:Nikto identified multiple missing security headers including Content-Security-Policy and X-Content-Type-Options, which could expose the application to client-side attacks such as cross-site scripting (XSS) and content sniffing vulnerabilities.
* **Web Server 2 Finding:** 172.88.0.20:Nikto detected that the HTTP TRACE method is enabled, which exposes the server to Cross-Site Tracing (XST) attacks that could lead to the disclosure of sensitive information such as authentication headers.

## PHASE 3: RISK TRIAGE
*(Review your findings. Identify the SINGLE highest-risk vulnerability across the entire DMZ. Justify why it is the top priority using the Likelihood x Impact formula.)*

* **Top Priority Remediation:** Outdated Nginx version (nginx 1.14.2) on 172.88.0.10
* **Justification:** It is the highest risk because the Nginx 1.14.2 version is significantly outdated and likely contains
 publicly known vulnerabilities that can be exploited remotely. Given that it is exposed over HTTP on a network-facing web server,
 the likelihood of exploitation is high. If successfully exploited, the impact could be severe, potentially allowing attackers
 to execute arbitrary code, gain unauthorized access, or compromise the underlying system. Compared to missing security headers
 or informational misconfigurations, this vulnerability presents both higher impact and higher exploitability in real-world
 attack scenarios.
