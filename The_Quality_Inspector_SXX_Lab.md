# 🔬 The Quality Inspector — S-XX Lab: SAST Security Gate with GitHub Actions

**Lab Name:** Session 20 - The Quality Inspector  
**Course:** TKH Innovation Fellowship (P2·W7·D2)  
**Due Date:** Tuesday, August 4, 2026 by 11:59 PM  
**Completed:** July 28, 2026  
**Final Result:** ✅ **PASSED** — 0 vulnerabilities detected  

---

## 📋 Table of Contents

1. [Lab Overview](#lab-overview)
2. [Why This Lab Matters](#why-this-lab-matters)
3. [Learning Objectives](#learning-objectives)
4. [Key Concepts Explained](#key-concepts-explained)
5. [The Complete Lab Workflow](#the-complete-lab-workflow)
6. [Phase 1: The Intentional Failure](#phase-1-the-intentional-failure)
7. [Phase 2: Remediation & Passage](#phase-2-remediation--passage)
8. [Phase 3: Submission](#phase-3-submission)
9. [Challenges & Solutions](#challenges--solutions)
10. [Final Architecture](#final-architecture)
11. [Key Takeaways](#key-takeaways)

---

## 🎯 Lab Overview

### What Is This Lab?

This lab teaches **Shift-Left Security** — the practice of integrating security checks *early* in the software development pipeline rather than *after* deployment. Specifically, you'll:

1. **Deploy intentionally vulnerable Terraform code** (an S3 bucket with public read access)
2. **Watch an automated security scanner catch it** (tfsec running in GitHub Actions)
3. **Fix the vulnerabilities** based on the scanner's findings
4. **Achieve a passing security gate** (0 vulnerabilities)

### The Real-World Scenario

Imagine you're a security engineer on a team where junior developers keep making this mistake:

```hcl
resource "aws_s3_bucket" "my_bucket" {
  acl = "public-read"  # ❌ DANGER: Anyone on the internet can download your files!
}
```

This is a **catastrophic security breach waiting to happen**. Your job? Automate the detection and **block the deployment automatically**.

---

## 🚨 Why This Lab Matters

### The Cost of Security Failures

**Public S3 buckets** have exposed millions of records:
- **2019:** Millions of Facebook user records leaked (unsecured S3 bucket)
- **2020:** COVID-19 vaccine data leaked (misconfigured S3 bucket)
- **2021:** Pentagon contractor exposed sensitive military data (public S3)

### The Solution: Shift-Left Security

Instead of catching these **after deployment** (expensive, public relations nightmare), catch them **before deployment**:

| When | Cost | Impact | Detection |
|------|------|--------|-----------|
| ❌ Post-Deployment | $$$$ | Breach, data loss, reputation damage | Too late |
| ✅ Pre-Deployment | $ | Prevented entirely | Automated scanner |

### Why GitHub Actions?

GitHub Actions is a **free automation platform** that runs every time you push code. Perfect for:
- Running security scans automatically
- Blocking deployments if vulnerabilities found
- Giving developers instant feedback
- Enforcing company security policies

---

## 🎓 Learning Objectives

After completing this lab, you will understand:

1. ✅ **SAST (Static Application Security Testing)**: Scanning code without running it
2. ✅ **tfsec**: A Terraform-specific security scanner
3. ✅ **CI/CD Integration**: Automating security checks in pipelines
4. ✅ **GitHub Actions Workflows**: Writing automation rules in YAML
5. ✅ **Shift-Left Security**: Why catching bugs early saves money and data
6. ✅ **S3 Security Best Practices**: Encryption, versioning, public access blocks
7. ✅ **Customer-Managed Encryption**: Using AWS KMS for fine-grained control
8. ✅ **Infrastructure as Code (IaC)**: Fixing security issues in Terraform

---

## 🔑 Key Concepts Explained

### 1. **SAST (Static Application Security Testing)**

**What it means:** Scanning code for security problems *without running it*.

```
Traditional Testing (DAST):
  Code → Deploy → Run App → Find Bugs → Fix → Re-deploy
  (Expensive, slow, public-facing)

SAST (This Lab):
  Code → Scan Locally → Find Issues → Fix → Deploy
  (Cheap, fast, preventative)
```

### 2. **tfsec: The Security Scanner**

**What it does:** Reads your Terraform code and checks it against 200+ security rules.

```bash
tfsec .
# Output: "Bucket has public read ACL - CRITICAL VULNERABILITY"
```

**Why it's powerful:**
- Catches mistakes developers make (hardcoded credentials, open databases, etc.)
- Specific to Terraform (understands AWS resources)
- Free and open-source
- Runs locally OR in CI/CD pipelines

### 3. **GitHub Actions Workflow**

**What it does:** Automatically runs tests on every git push.

```yaml
on:
  push:
    branches:
      - main  # Run whenever code is pushed to main branch
jobs:
  tfsec_scan:  # Job name
    runs-on: ubuntu-latest  # Use a GitHub server running Ubuntu
    steps:
      - uses: actions/checkout@v3  # Get the code
      - uses: aquasecurity/tfsec-pr-commenter-action@v1.2.0  # Run tfsec
```

### 4. **Shift-Left Security**

**The concept:**

```
Traditional (Left-to-Right Timeline):
  Write Code → Deploy to Prod → Run in Production → [HACK] → Incident
  (Security check happens too late!)

Shift-Left:
  Write Code → [SECURITY CHECK] → Deploy → Run in Production
  (Security check happens early!)
```

### 5. **S3 Security Best Practices**

| Issue | Risk | Fix |
|-------|------|-----|
| Public read ACL | Anyone downloads your files | Remove `acl = "public-read"` |
| No encryption | Hackers read data at rest | Use KMS encryption |
| No versioning | Can't recover deleted files | Enable versioning |
| No access logs | Can't audit who accessed bucket | Enable logging |
| No public access block | Policies can override ACL | Add public access block |

### 6. **KMS (Key Management Service)**

**What it is:** AWS service for managing encryption keys.

```
AWS-Managed Keys:
  ✅ Automatic, no management needed
  ❌ Limited control, can't audit key usage

Customer-Managed Keys (KMS):
  ✅ Full control, audit all access
  ❌ More responsibility
  ✅ Required for compliance (HIPAA, PCI-DSS)
```

---

## 🗺️ The Complete Lab Workflow

Here's the entire journey visualized:

```
START
  ↓
[Phase 1] Deploy Vulnerable Code
  ├─ Clone lab repo
  ├─ Create GitHub Actions workflow
  ├─ Push bad S3 code (acl = "public-read")
  └─ RESULT: 🔴 Pipeline FAILS (10 vulnerabilities)
  ↓
[Phase 2] Read & Understand Errors
  ├─ Run tfsec locally
  ├─ Read security findings
  ├─ Understand what needs fixing
  └─ RESULT: List of 10 issues (7 HIGH, 2 MEDIUM, 1 LOW)
  ↓
[Phase 2] Remediate the Code
  ├─ Remove public-read ACL
  ├─ Add KMS encryption
  ├─ Enable versioning
  ├─ Add public access block
  ├─ Add logging infrastructure
  ├─ Run tfsec locally (iterate until 0 issues)
  └─ RESULT: ✅ No vulnerabilities locally
  ↓
[Phase 2] Push & Verify
  ├─ Push remediated code to GitHub
  ├─ GitHub Actions runs automatically
  ├─ tfsec scans the new code
  └─ RESULT: 🟢 Pipeline PASSES (0 vulnerabilities)
  ↓
[Phase 3] Submit Proof
  ├─ Screenshot failed pipeline (RED)
  ├─ Screenshot successful pipeline (GREEN)
  ├─ Submit final main.tf file
  └─ RESULT: ✅ Lab Complete!
```

---

## 🚀 Phase 1: The Intentional Failure

### Goal
Deploy *deliberately bad* Terraform code and watch the security scanner catch it.

### Step 1: Clone the Lab Repository

```bash
git clone https://github.com/grobbins-cell/S20-Quality-Lab.git
cd S20-Quality-Lab
```

**What this does:** Downloads the starter code with intentional vulnerabilities.

### Step 2: Examine the Vulnerable Code

```bash
cat main.tf
```

**What you see:**

```hcl
resource "aws_s3_bucket" "vulnerable_vault" {
  bucket = "tkh-exposed-vault-${random_id.id.hex}"
  acl    = "public-read"  # ❌ CRITICAL: Anyone can read this bucket!
}
```

**Why this is dangerous:**
- `acl = "public-read"` = "Let anyone on the internet read my files"
- No encryption = Files are readable if accessed
- No versioning = Can't recover deleted files
- No logging = Can't audit who accessed what

### Step 3: Create GitHub Actions Directory

```bash
mkdir -p .github/workflows
```

**Why:** GitHub looks in `.github/workflows/` for automation rules.

### Step 4: Create the SAST Workflow

```bash
touch .github/workflows/tfsec-pipeline.yml
```

Paste this configuration:

```yaml
name: Security Quality Gate
on:
  push:
    branches:
      - main
jobs:
  tfsec_scan:
    name: tfsec SAST Scanner
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v3
      - name: Run tfsec
        uses: aquasecurity/tfsec-pr-commenter-action@v1.2.0
        with:
          tfsec_args: --soft-fail=false
          github_token: ${{ secrets.GITHUB_TOKEN }}
```

**What each part does:**
- `name: Security Quality Gate` = Workflow name (shows in GitHub Actions)
- `on: push` = Run when code is pushed
- `branches: - main` = Only scan the main branch
- `runs-on: ubuntu-latest` = Use a GitHub server with Ubuntu
- `actions/checkout@v3` = Download the code
- `aquasecurity/tfsec-pr-commenter-action` = Run tfsec scanner
- `--soft-fail=false` = **Don't soft-fail** — hard fail if vulnerabilities found

### Step 5: Push Bad Code & Watch It Fail

```bash
git add .
git commit -m "Testing SAST Gate"
git push origin main
```

### Step 6: Observe the Red Pipeline

1. Go to your GitHub repo
2. Click **Actions** tab
3. Watch the workflow run turn **RED** ❌
4. Click **"Run tfsec"** step to see the errors

**Screenshot this! This is Screenshot A (the failure).**

### What tfsec Found

```
Result #1 HIGH: No public access block so not blocking public acls
Result #2 HIGH: No public access block so not blocking public policies
Result #3 HIGH: Bucket does not have encryption enabled
Result #4 HIGH: No public access block so not ignoring public acls
Result #5 HIGH: No public access block so not restricting public buckets
Result #6 HIGH: Bucket does not encrypt data with a customer managed key
Result #7 HIGH: Bucket has a public ACL: 'public-read'
Result #8 MEDIUM: Bucket does not have logging enabled
Result #9 MEDIUM: Bucket does not have versioning enabled
Result #10 LOW: Bucket does not have a corresponding public access block

Total: 10 vulnerabilities (7 HIGH, 2 MEDIUM, 1 LOW)
```

**The security gate blocked the deployment!** ✅ This is exactly what we want.

---

## 🔧 Phase 2: Remediation & Passage

### Goal
Fix each vulnerability based on tfsec's findings.

### The Remediation Strategy

Each tfsec error tells us exactly what to add:

| Error | What It Means | Fix |
|-------|---------------|-----|
| `aws-s3-block-public-acls` | Can't block public ACLs | Add `aws_s3_bucket_public_access_block` |
| `aws-s3-block-public-policy` | Can't block public policies | Add to same resource |
| `aws-s3-enable-bucket-encryption` | No encryption | Add `aws_s3_bucket_server_side_encryption_configuration` |
| `aws-s3-encryption-customer-key` | Not using KMS | Use `aws:kms` instead of `AES256` |
| `aws-s3-enable-versioning` | Can't recover deletions | Add `aws_s3_bucket_versioning` |
| `aws-s3-enable-bucket-logging` | Can't audit access | Add `aws_s3_bucket_logging` |

### The Final Secure Code

Replace your `main.tf` with this:

```hcl
# Generate a random suffix for unique bucket name
resource "random_id" "id" {
  byte_length = 4
}

# The secure S3 bucket (NO public-read!)
resource "aws_s3_bucket" "vulnerable_vault" {
  bucket = "tkh-exposed-vault-${random_id.id.hex}"
}

# FIX #1: Block all public access (the most important fix)
resource "aws_s3_bucket_public_access_block" "vault_privacy" {
  bucket = aws_s3_bucket.vulnerable_vault.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# FIX #2: Enable encryption with KMS
resource "aws_s3_bucket_server_side_encryption_configuration" "vault_encryption" {
  bucket = aws_s3_bucket.vulnerable_vault.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
      kms_master_key_id = aws_kms_key.s3_key.arn
    }
  }
}

# FIX #3: Enable versioning
resource "aws_s3_bucket_versioning" "vault_versioning" {
  bucket = aws_s3_bucket.vulnerable_vault.id

  versioning_configuration {
    status = "Enabled"
  }
}

# FIX #4: Create SECURE logging bucket
resource "aws_s3_bucket" "vault_logs" {
  bucket = "tkh-vault-logs-${random_id.id.hex}"
}

# Block public access to logging bucket
resource "aws_s3_bucket_public_access_block" "vault_logs_privacy" {
  bucket = aws_s3_bucket.vault_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Encrypt the logging bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "vault_logs_encryption" {
  bucket = aws_s3_bucket.vault_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
      kms_master_key_id = aws_kms_key.s3_key.arn
    }
  }
}

# Version the logging bucket
resource "aws_s3_bucket_versioning" "vault_logs_versioning" {
  bucket = aws_s3_bucket.vault_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable logging on main bucket
resource "aws_s3_bucket_logging" "vault_logging" {
  bucket = aws_s3_bucket.vulnerable_vault.id

  target_bucket = aws_s3_bucket.vault_logs.id
  target_prefix = "vault-logs/"
}

# Enable logging on the logging bucket itself (for audit trail)
resource "aws_s3_bucket_logging" "vault_logs_logging" {
  bucket = aws_s3_bucket.vault_logs.id

  target_bucket = aws_s3_bucket.vault_logs.id
  target_prefix = "self-logs/"
}

# Create KMS key for encryption
resource "aws_kms_key" "s3_key" {
  description             = "KMS key for S3 bucket encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

resource "aws_kms_alias" "s3_key_alias" {
  name          = "alias/s3-bucket-key"
  target_key_id = aws_kms_key.s3_key.key_id
}
```

### Understanding Each Fix

#### **FIX #1: Public Access Block**

```hcl
resource "aws_s3_bucket_public_access_block" "vault_privacy" {
  bucket = aws_s3_bucket.vulnerable_vault.id

  block_public_acls       = true  # Can't upload public ACLs
  block_public_policy     = true  # Can't upload public policies
  ignore_public_acls      = true  # Ignore existing public ACLs
  restrict_public_buckets = true  # Restrict bucket access
}
```

**Why:** Even if someone adds a public ACL later, these rules prevent it from taking effect. This is the **most important fix**.

#### **FIX #2: KMS Encryption**

```hcl
resource "aws_s3_bucket_server_side_encryption_configuration" "vault_encryption" {
  bucket = aws_s3_bucket.vulnerable_vault.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"  # Use customer-managed keys
      kms_master_key_id = aws_kms_key.s3_key.arn  # Reference the KMS key
    }
  }
}
```

**Why:** 
- `AES256` = AWS-managed encryption (limited control)
- `aws:kms` = Customer-managed encryption (full control, auditable)
- tfsec requires KMS for HIGH security

#### **FIX #3: Versioning**

```hcl
resource "aws_s3_bucket_versioning" "vault_versioning" {
  bucket = aws_s3_bucket.vulnerable_vault.id

  versioning_configuration {
    status = "Enabled"
  }
}
```

**Why:** If someone accidentally deletes or modifies files, you can recover old versions.

#### **FIX #4: Logging**

```hcl
resource "aws_s3_bucket_logging" "vault_logging" {
  bucket = aws_s3_bucket.vulnerable_vault.id

  target_bucket = aws_s3_bucket.vault_logs.id  # Where to send logs
  target_prefix = "vault-logs/"                # Folder inside logs bucket
}
```

**Why:** Creates an audit trail of who accessed what, when.

### Test Locally Before Pushing

```bash
# Test with tfsec
tfsec .
```

**Expected output:**

```
No problems detected!
21 passed
```

**Zero vulnerabilities!** ✅

### Push the Remediated Code

```bash
git add .
git commit -m "Added self-logging to logging bucket"
git push origin main
```

### Watch It Pass

1. Go to GitHub Actions
2. Watch the new workflow run
3. It should turn **🟢 GREEN** ✅

**Screenshot this! This is Screenshot B (the success).**

---

## 📤 Phase 3: Submission

### What to Submit

You need **3 things**:

#### 1. **Screenshot A: The Failed Pipeline**

Shows tfsec catching 10 vulnerabilities:
- **Status:** 🔴 RED ❌
- **Shows:** Error output from "Run tfsec" step listing all vulnerabilities
- **Purpose:** Proves the security gate caught the bad code

#### 2. **Screenshot B: The Successful Pipeline**

Shows the remediated code passing security:
- **Status:** 🟢 GREEN ✅
- **Shows:** "Added self-logging to logging bucket" workflow with green checkmark
- **Purpose:** Proves you fixed all issues

#### 3. **main.tf File**

Your final secure Terraform code:
- **Content:** The complete remediated main.tf with all fixes
- **Purpose:** Proof you know how to write secure infrastructure

### How to Submit

1. Go to **Canvas**
2. Find **S-XX: The Quality Inspector**
3. Click **Submit Assignment**
4. Upload:
   - Screenshot A (RED pipeline with errors)
   - Screenshot B (GREEN pipeline success)
   - main.tf file

---

## 🚧 Challenges & Solutions

### Challenge 1: Git Permission Denied

**Problem:**
```
remote: Permission to grobbins-cell/S20-Quality-Lab.git denied to Wendtin.
```

**Solution:** Fork the repo to your own GitHub account, then update the remote:
```bash
git remote set-url origin https://github.com/Wendtin/S20-Quality-Lab.git
```

**Why:** You can't push to repos you don't own without permission.

---

### Challenge 2: tfsec Not Installed

**Problem:**
```
tfsec: command not found
```

**Solution:** Install tfsec manually:
```bash
cd ~
wget https://github.com/aquasecurity/tfsec/releases/download/v1.28.14/tfsec-linux-amd64 -O tfsec
chmod +x tfsec
sudo mv tfsec /usr/local/bin/tfsec
```

**Why:** Kali's apt package might be outdated; downloading latest version ensures current security checks.

---

### Challenge 3: Logging Bucket Also Needs Security Fixes

**Problem:**
```
Bucket does not have encryption enabled
Bucket does not have versioning enabled
Bucket does not have logging enabled
```

**Solution:** Apply the same security fixes to the logging bucket:
- Add encryption configuration
- Add versioning
- Add logging to the logs bucket (self-logging)

**Why:** Every bucket needs the same level of security. The logging bucket stores sensitive audit trails and needs protection too.

---

### Challenge 4: Multiple Push Attempts Before Passing

**Timeline:**
1. **Push 1:** 10 vulnerabilities (Failed)
2. **Push 2:** 5 vulnerabilities (Failed)
3. **Push 3:** 1 vulnerability (Failed)
4. **Push 4:** 0 vulnerabilities (Passed ✅)

**Why:** Security isn't one-and-done. You iterate, test locally, push, and repeat until everything passes.

---

## 🏗️ Final Architecture

### What You Built

```
┌─────────────────────────────────────────────────────┐
│         GitHub Actions Security Pipeline            │
└─────────────────────────────────────────────────────┘
                         ↓
              tfsec SAST Security Scanner
              ├─ Scans all Terraform code
              ├─ Checks 200+ security rules
              └─ Blocks deployment if vulnerabilities found
                         ↓
         ┌────────────────────────────────┐
         │   Secure S3 Infrastructure     │
         ├────────────────────────────────┤
         │
         ├─ Main Vault Bucket
         │  ├─ NO public read ACL
         │  ├─ KMS encryption (customer-managed)
         │  ├─ Versioning enabled
         │  └─ Access logging enabled
         │
         ├─ Logging Bucket
         │  ├─ Stores audit logs
         │  ├─ KMS encryption
         │  ├─ Versioning enabled
         │  └─ Self-logging enabled
         │
         └─ KMS Master Key
            ├─ Centralized key management
            ├─ Automatic key rotation
            └─ Audit trail of all access
```

### Security Layers

```
Layer 1: ACL
  └─ Removed public-read (was open to world)

Layer 2: Public Access Block
  └─ Four shields: blocks ACLs, policies, ignores ACLs, restricts buckets

Layer 3: Encryption
  └─ KMS encryption with customer-managed keys

Layer 4: Versioning
  └─ Can recover from accidental deletion

Layer 5: Logging
  └─ Audit trail of all access

Layer 6: Automated Security Gate
  └─ tfsec + GitHub Actions prevent bad code from ever deploying
```

---

## 🎓 Key Takeaways

### 1. **Shift-Left Security Works**

You caught 10 vulnerabilities **before** they ever reached production. In a real company:
- **Without this:** Breach happens → company fined millions → PR disaster
- **With this:** Scanner catches it → fixed in 30 minutes → nobody knows

### 2. **Automation > Manual Reviews**

You can't expect humans to remember all 10 security checks every time. Automation catches them instantly.

### 3. **S3 Security is Critical**

Public S3 buckets have exposed:
- Credit card data (millions of records)
- Medical records (COVID vaccines)
- Military secrets (Pentagon contractor)

This lab showed how to prevent these.

### 4. **Read Scanner Output Carefully**

tfsec doesn't just say "bad code" — it tells you:
- ✅ **What's wrong** (Bucket is public)
- ✅ **Why it's wrong** (Anyone can read files)
- ✅ **How to fix it** (Add public access block)

### 5. **Iterate, Test, Deploy**

Never push code you haven't tested locally:
```
Local Testing → Push → GitHub Actions → Production
     ✅            →       ✅          →    ✅
```

### 6. **Security is Layered**

One fix isn't enough:
- Remove ACL ❌ → Add public access block ❌ → Add encryption ❌
- All three together ✅ → Defense in depth

---

## 📚 What This Prepares You For

This lab is the foundation for:

- **DevSecOps Role:** Building secure CI/CD pipelines
- **Cloud Security:** AWS security best practices
- **Infrastructure as Code:** Terraform with security standards
- **Compliance:** Automated compliance checks (PCI-DSS, HIPAA, SOC2)
- **Real Job:** Every company now requires automated security gates

---

## 🔗 References

- [tfsec Documentation](https://aquasecurity.github.io/tfsec/)
- [GitHub Actions Workflow Syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [AWS S3 Security Best Practices](https://docs.aws.amazon.com/AmazonS3/latest/userguide/security-best-practices.html)
- [AWS KMS Documentation](https://docs.aws.amazon.com/kms/)
- [OWASP: Secure Defaults](https://cheatsheetseries.owasp.org/)

---

## ✅ Completion Checklist

- [x] Forked lab repository to GitHub account
- [x] Created GitHub Actions workflow file (.github/workflows/tfsec-pipeline.yml)
- [x] Deployed vulnerable Terraform code
- [x] Watched security scanner catch 10 vulnerabilities
- [x] Remediated code with 5 security fixes:
  - [x] Removed public-read ACL
  - [x] Added KMS encryption
  - [x] Enabled versioning
  - [x] Created logging infrastructure
  - [x] Applied fixes to both main and logging buckets
- [x] Achieved 0 vulnerabilities
- [x] GitHub Actions pipeline passed (GREEN ✅)
- [x] Collected screenshots (failed + successful)
- [x] Submitted to Canvas

---

## 📝 Notes for Future Reference

### Commands Used

```bash
# Install tfsec
wget https://github.com/aquasecurity/tfsec/releases/download/v1.28.14/tfsec-linux-amd64 -O tfsec
chmod +x tfsec
sudo mv tfsec /usr/local/bin/tfsec

# Test locally
tfsec .

# Push to GitHub
git add .
git commit -m "Your message"
git push origin main
```

### Key Files

- `.github/workflows/tfsec-pipeline.yml` — The security automation
- `main.tf` — The Terraform infrastructure (remediated)

---

## 🎉 Final Thoughts

This lab demonstrates the **future of cloud security**: automated, preventative, integrated into every pipeline. You're not just learning Terraform — you're learning how to build **production-grade secure infrastructure**.

The companies hiring right now **demand this skill**. You just learned it. 🚀

---

**Lab Completed:** July 28, 2026  
**Status:** ✅ PASSED (0 vulnerabilities)  
**Score:** 5/5 Points