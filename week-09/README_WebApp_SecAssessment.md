# 🔐 TLAB9 — Operation Omni-Portal
### Full-Stack Web Application Security Assessment

---

## 📋 Overview

**Lab Name:** Operation Omni-Portal  
**Assignment:** TLAB9  
**Target Application:** Titan Omni-Portal (Legacy Internal App)  
**Assessment Type:** Black-Box Penetration Test  
**Attack Surface:** Authentication, Input Handling, API Authorization  
**Tools Used:** Burp Suite (Repeater/Intruder), Browser DevTools, Linux Terminal  

This lab simulates a realistic chained attack against a vulnerable internal web portal. Three distinct OWASP Top 10 vulnerabilities are exploited in sequence — each phase unlocks the next. The objective is to bypass authentication, steal a session token via persistent XSS, and exfiltrate confidential financial data through an insecure API endpoint.

---

## 🎯 Learning Objectives

By completing this lab, you will be able to:

- Construct and execute a **SQL Injection tautology** to bypass login authentication
- Write and deploy a **Stored XSS payload** to steal session cookies from a live web page
- Identify and exploit a **BOLA (Broken Object Level Authorization)** vulnerability in a REST API
- Use **Burp Suite Repeater** to intercept and manipulate HTTP requests
- Document findings in a professional penetration test artifact
- Articulate **remediation strategies** for each class of vulnerability

---

## ⚙️ Environment Setup

### Prerequisites
- Ubuntu Attacker VM
- Burp Suite (Community or Pro)
- Terminal access with `sudo` privileges
- Git configured with your GitHub credentials

### Provisioning the Target

Run the following command inside your Ubuntu VM terminal to spin up the Omni-Portal:

```bash
curl -sL https://gist.githubusercontent.com/grobbins-cell/b7d9181dd65ed632bd0baa7474265e7b/raw/ffd4b2d0872193d64841238776c6d89e42dbd8b2/tlab9_provisioning.sh | sudo bash
```

> ⚠️ **Do not proceed until you see:** `[+] PROVISIONING COMPLETE`

The portal will be available at: **http://127.0.0.1:8090**

---

## 🔗 Attack Chain Overview

```
Phase 1 (SQLi)         Phase 2 (XSS)            Phase 3 (BOLA)
─────────────────      ────────────────────      ───────────────────────
Bypass Login      ──►  Steal auth_token     ──►  Enumerate API Order IDs
    │                       │                           │
    ▼                       ▼                           ▼
Authenticated          Cookie captured            Confidential order
session gained         via JS payload             data exfiltrated
```

---

## 🧱 Phase 1 — Breaking the Gate (SQL Injection)

**Target:** `http://127.0.0.1:8090/login`  
**Vulnerability:** Unsanitized SQL query construction  
**OWASP Category:** A03:2021 – Injection  

### Attack Steps

1. Navigate to the login page
2. In the **Username** field, enter the following tautology payload:
   ```
   ' OR '1'='1
   ```
3. Leave the **Password** field blank and click **Login**

### Why It Works

The backend constructs a query similar to:
```sql
SELECT * FROM users WHERE username='INPUT' AND password='INPUT'
```
After injection, this becomes:
```sql
SELECT * FROM users WHERE username='' OR '1'='1' AND password=''
```
The `OR '1'='1'` condition always evaluates to `TRUE`, causing the WHERE clause to match every row — authentication is completely bypassed.

### Evidence to Record
- ✅ The tautology payload used
- ✅ Confirmation that the **"View My Orders"** link appeared post-login
- ✅ The `auth_token` cookie value now set in the browser

---

## 🕷️ Phase 2 — Poisoning the Well (Stored XSS)

**Target:** `http://127.0.0.1:8090/support`  
**Vulnerability:** Unescaped user input rendered as HTML  
**OWASP Category:** A03:2021 – Injection (XSS)  

### Attack Steps

1. Navigate to the Support Board
2. In the comment/message input field, inject the following payload:
   ```html
   <script>alert(document.cookie)</script>
   ```
3. Submit the comment
4. Reload the page — an alert box fires displaying all cookies, including `auth_token`
5. Copy the exact `auth_token` value from the alert

### Why It Works

The application stores user input directly in the database and renders it back to the page without HTML encoding. Because the browser interprets the stored `<script>` tag as executable code, the payload fires for **every user who loads the page** — making this a **persistent (Stored) XSS**, not just a reflected one.

### Evidence to Record
- ✅ The exact XSS payload injected
- ✅ The full `auth_token` cookie value captured from the alert box

---

## 📡 Phase 3 — Deep Data Mining (API BOLA / IDOR)

**Target:** `http://127.0.0.1:8090/api/v2/orders/{id}`  
**Vulnerability:** No ownership check on order ID parameter  
**OWASP Category:** A01:2021 – Broken Access Control (BOLA/IDOR)  

### Attack Steps

1. Open **Burp Suite** and enable the proxy
2. Open the **Burp Browser** and navigate to the **View My Orders** link
3. Burp intercepts the request to:
   ```
   GET /api/v2/orders/502
   ```
4. Send the request to **Repeater** (`Ctrl+R`)
5. In Repeater, modify the order ID in the URL path and click **Send**:
   - Try `501`, `500`, `503`, `504`, etc.
6. Identify the response containing `"Confidential Server Lease"`

### Discovered Confidential Order

| Field      | Value                    |
|------------|--------------------------|
| Order ID   | `501`                    |
| Details    | `Confidential Server Lease` |
| Amount     | `$15,000.00`             |
| HTTP Status| `200 OK`                 |

### Raw API Response (Burp Repeater)
```json
{
  "amount": "$15,000.00",
  "details": "Confidential Server Lease",
  "order_id": 501
}
```

### Why It Works

The API validates that the user is **authenticated** but never verifies that the requested order **belongs to** the authenticated user. By simply incrementing the integer ID in the URL, any logged-in user can access any other user's order records — no elevated privilege required.

---

## 🛠️ Phase 4 — Remediation

### SQL Injection Fix
Use **parameterized queries (prepared statements)** — never concatenate user input directly into SQL strings.

```python
# ❌ Vulnerable
query = f"SELECT * FROM users WHERE username='{username}' AND password='{password}'"

# ✅ Secure
cursor.execute("SELECT * FROM users WHERE username=? AND password=?", (username, password))
```
User input is treated as **data**, never as executable SQL syntax.

---

### XSS Fix
**Encode/escape all user-supplied input before rendering it in HTML.** Never inject raw user data into the DOM.

```javascript
// ❌ Vulnerable
element.innerHTML = userInput;

// ✅ Secure
element.textContent = userInput;
// Or server-side: htmlspecialchars($input, ENT_QUOTES, 'UTF-8');  // PHP
```

Additionally, implement a **Content Security Policy (CSP)** header to block inline script execution:
```
Content-Security-Policy: default-src 'self'; script-src 'self'
```

---

### API BOLA Fix
Add a **server-side ownership check** before returning any order object.

```python
# ❌ Vulnerable — trusts the ID in the URL with no ownership check
@app.route('/api/v2/orders/<int:order_id>')
def get_order(order_id):
    order = db.query("SELECT * FROM orders WHERE id=?", order_id)
    return jsonify(order)

# ✅ Secure — verifies the order belongs to the requesting user
@app.route('/api/v2/orders/<int:order_id>')
def get_order(order_id):
    order = db.query("SELECT * FROM orders WHERE id=?", order_id)
    if order['user_id'] != current_user.id:
        return jsonify({"error": "Forbidden"}), 403
    return jsonify(order)
```

The fix is **one authorization check**: compare the order's `user_id` field against the session's authenticated user ID. On mismatch, return `HTTP 403 Forbidden` — never return the data.

---

## 📁 Artifact & Submission

### Finalize Your Report
```bash
cat ~/OmniPortal_Assessment.md
```

### Submit via Session Tool
```bash
session-submit --session tlab9 --artifact ~/OmniPortal_Assessment.md
```

### Push to GitHub
```bash
git add OmniPortal_Assessment.md
git commit -m "edited: W9 | TLAB9 | Operation Omni-Portal full-stack assessment"
git push origin main
```

> ✅ Wait for the green `[SUCCESS]` message before screenshotting and logging off.

---

## 🔑 Key Concepts

| Concept | Definition |
|---------|-----------|
| **SQL Injection (SQLi)** | Injecting malicious SQL syntax into input fields to manipulate database queries |
| **Stored XSS** | Persistent cross-site scripting where a malicious payload is saved to the database and executed in every future visitor's browser |
| **BOLA / IDOR** | Broken Object Level Authorization — an API that returns data based on a user-controlled ID without verifying ownership |
| **auth_token** | A session cookie that authenticates a user; if stolen via XSS, an attacker can impersonate that user |
| **Tautology Payload** | A SQL expression that always evaluates to TRUE (e.g., `OR '1'='1'`), used to bypass conditional logic |
| **Burp Repeater** | A Burp Suite tool for manually modifying and resending individual HTTP requests |

---

## ⚠️ Disclaimer

This lab is conducted in a **controlled, isolated environment** built specifically for security education. All targets are local (`127.0.0.1`) and intentionally vulnerable. These techniques must **never** be applied against systems you do not own or have explicit written authorization to test.