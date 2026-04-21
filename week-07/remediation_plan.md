# CloudNano Remediation Plan — Top 5 Priority Vulnerabilities

## Vulnerability 1: Unauthenticated AWS S3 Bucket (Customer PII)
**Justification:** This bucket is publicly accessible to anyone with the URL
and directly exposes customer PII, making both likelihood and impact
critically high and creating immediate regulatory exposure under GDPR/CCPA.


## Vulnerability 2: Remote Code Execution in Apache Struts
**Justification:** This internet-facing server has a known RCE vulnerability
with public exploits in circulation, meaning an attacker can achieve full
server takeover today with no credentials required.

## Vulnerability 3: SQL Injection on Customer Database Login Page
**Justification:** The login portal is publicly reachable and injectable,
giving any attacker a direct path to dump the entire customer database —
combining high likelihood with maximum business impact.

## Vulnerability 4: SMBv1 Enabled on HR File Server
**Justification:** SMBv1 has a well-known, weaponized exploit (EternalBlue)
used in ransomware campaigns; the HR file server contains employee PII,
making this an internal pivot point with severe data loss and
operational shutdown potential.

## Vulnerability 5: Cross-Site Scripting on Support Forum
**Justification:** The support forum is public-facing and actively used by
customers, so a stored XSS attack can hijack live user sessions or redirect
customers to phishing pages at scale, combining high likelihood with direct
customer harm.
