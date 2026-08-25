# OMNI-PORTAL ASSESSMENT REPORT
**Operator:** **Deadline:** April 5 @ 11:59 PM 

## PHASE 1: AUTH BYPASS (SQLi)
* **Payload Used:** admin'--
* **Result:** Successfully bypassed login and obtained 'auth_token' cookie.

## PHASE 2: CLIENT-SIDE HIJACK (XSS)
* **Stored XSS Payload:** <script>alert(document.cookie)</script>
* **Secret Cookie Captured:** auth_token=SUPPORT_TIER_1_SECRET_TOKEN

## PHASE 3: API ENUMERATION (BOLA)
* **Insecure Order ID:** GET /api/v2/orders/501
* **Confidential Data Leaked:**
        Amount: "$15,000.00"
        Details :"Confidential Server Lease",
        Order_id :501
        HTTP/1.1 200 OK
        Server: Werkzeug/3.1.5 Python/3.13.12
	Date: Tue, 12 May 2026 22:21:03 GMT
	Content-Type: application/json
	Content-Length: 77
	Connection: close

## PHASE 4: THE REMEDIATION
* **Fix for SQLi:** 
Use **parameterized queries (prepared statements)** — never concatenate user input
directly into SQL strings. Example (Python):
  cursor.execute("SELECT * FROM users WHERE username=? AND password=?", (user, pw))
Input is treated as data, never as executable SQL.

* **Fix for XSS:**
**Encode/escape all user input before rendering it in HTML.** Use functions like
`htmlspecialchars()` (PHP) or `escapeHtml()` (JS frameworks). Implement a
Content Security Policy (CSP) header to block inline script execution. Never
use `innerHTML` with untrusted data — use `textContent` instead.


* **Fix for API BOLA:**
The orders endpoint is missing **ownership verification**. The fix:
1. When a request comes in for /api/v2/orders/{id}, look up the order in the DB.
2. Compare the order's `user_id` field against the authenticated user's session ID.
3. If they don't match, return HTTP 403 Forbidden — never return the data.
This is server-side authorization, not just authentication.
