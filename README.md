# 🛡️ TLAB7: The Automated Forge
## End-to-End DevSecOps Pipeline with GitHub Actions + Terraform + AWS OIDC

---

## 📋 Project Overview

**TLAB7: The Automated Forge** is a comprehensive DevSecOps laboratory that demonstrates how elite cloud engineering teams build **keyless, secure, automated infrastructure deployment pipelines**.

This project implements a complete **three-stage CI/CD pipeline** that:
1. **Authenticates** to AWS using OIDC federation (no hardcoded keys)
2. **Scans** Terraform for security vulnerabilities using tfsec
3. **Deploys** infrastructure only if security gates pass

### Key Technologies
- **GitHub Actions** — CI/CD orchestration
- **AWS IAM OIDC** — Keyless authentication
- **Terraform** — Infrastructure as Code
- **tfsec** — Static Application Security Testing (SAST)
- **AWS Security Groups** — Network security

---

## 🔥 Why This Lab Matters (Real-World Impact)

### The Security Crisis

Every day, companies face devastating infrastructure security breaches:
- **2023 AWS credentials leaked** → Ransomware attack costs $4.24M (IBM)
- **GitHub Actions secrets stolen** → Unauthorized AWS access, data exfiltration
- **Misconfigured security groups** → SSH exposed to the internet, 10 mins to first breach
- **Manual deployments** → Humans miss vulnerabilities, typos cause outages

### The TLAB7 Solution

This lab addresses **all of these risks** by implementing DevSecOps best practices:

#### 🔐 **Problem #1: Hardcoded Credentials**
- **Old Way:** Store AWS access keys in GitHub secrets → Keys leak → Game over
- **TLAB7 Way:** Use OIDC federation → No keys stored anywhere → Impossible to steal
- **Impact:** Eliminates the #1 cause of cloud breaches (credential theft)

#### 🛡️ **Problem #2: Vulnerable Infrastructure Deployed**
- **Old Way:** Deploy infrastructure, scan later → Vulnerabilities already live → Attackers exploit
- **TLAB7 Way:** Scan BEFORE deployment → Vulnerabilities caught → Only secure code deploys
- **Impact:** Shift-Left Security prevents breaches before they happen

#### 🤖 **Problem #3: Manual Deployments = Human Error**
- **Old Way:** SSH into production, terraform apply manually → Typos → Outages
- **TLAB7 Way:** Automated pipeline → Consistent deployments → No human error
- **Impact:** Reliability improves, outage window closes

#### 📋 **Problem #4: No Audit Trail**
- **Old Way:** Who deployed what? When? Why? No one knows → Compliance nightmare
- **TLAB7 Way:** Every deployment logged in GitHub → Full audit trail → Compliance ✓
- **Impact:** Meet regulatory requirements (SOC 2, ISO 27001, FedRAMP)

### Real-World Companies Using This Exact Pattern

- **AWS** — Uses OIDC for GitHub Actions authentication
- **Google Cloud** — Recommends this architecture for supply chain security
- **Microsoft Azure** — Supports keyless OIDC deployments
- **Netflix** — Uses automated security gates in deployment pipelines
- **GitHub itself** — Uses tfsec + GitHub Actions for infrastructure

### The Competitive Advantage

This lab demonstrates you understand:
✅ **Enterprise-grade security** — Not just "it works," but "it's secure"  
✅ **Modern DevOps practices** — IaC, CI/CD, automation  
✅ **Cloud-native architecture** — OIDC, IAM roles, security groups  
✅ **Troubleshooting & problem-solving** — You debugged OIDC issues (hard!)  
✅ **Production-readiness** — No credentials, audit trails, automated scanning  

**This is what separates junior engineers from senior engineers.**

---

## 🎯 Learning Objectives

By completing this lab, I learned to:

✅ Set up AWS IAM OIDC providers for keyless GitHub authentication  
✅ Create GitHub Actions workflows with proper permissions and sequencing  
✅ Implement security scanning gates in CI/CD pipelines  
✅ Fix infrastructure vulnerabilities before deployment (Shift-Left Security)  
✅ Deploy secure infrastructure using Terraform with -auto-approve  
✅ Understand the full DevSecOps workflow used in production  

---

---

## 🚀 The Journey: Failures → Solutions → Success

### Challenge #1: OIDC Authentication Kept Failing

**The Problem:**
I spent hours trying to figure out why GitHub Actions couldn't authenticate to AWS, even though:
- The OIDC provider existed ✓
- The IAM role existed ✓
- The trust policy looked correct ✓

**Root Causes Found:**
1. **OIDC Provider URL was incomplete** — It was stored as `token.actions.githubusercontent.com` instead of `https://token.actions.githubusercontent.com`
2. **Trust policy was too strict initially** — I had overly specific conditions that weren't matching GitHub's token format
3. **Role needed to be recreated** — After fixing the OIDC provider, the role needed to be synced with the new provider

**The Solution:**
```bash
# Deleted and recreated OIDC provider with full https:// URL
aws iam delete-open-id-connect-provider \
  --open-id-connect-provider-arn arn:aws:iam::708380009537:oidc-provider/token.actions.githubusercontent.com

aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com

# Deleted and recreated the role with simpler trust policy conditions
aws iam update-assume-role-policy \
  --role-name DevSecOps-Pipeline-Role \
  --policy-document file://trust-policy.json
```

**Key Lesson:** OIDC URLs must include the protocol (`https://`). The devil is in the details! 🔍

---

### Challenge #2: Pipeline Failed at Security Gate

**The Problem:**
GitHub Actions successfully authenticated to AWS, but **tfsec caught security vulnerabilities** and blocked deployment.

**Vulnerability Found:**
My Terraform code had:
```hcl
ingress {
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]  # ❌ Anyone on Earth can SSH!
}
```

**The Solution:**
This was **intentional** — the lab included a deliberate vulnerability to demonstrate Shift-Left Security. I fixed it by:

1. **Finding my home IP address:**
```bash
   curl ifconfig.me
   # Output: 108.xx.201.xx
```

2. **Updating the security group to allow SSH only from my IP:**
```hcl
   ingress {
     from_port   = 22
     to_port     = 22
     protocol    = "tcp"
     description = "SSH access from home IP only"
     cidr_blocks = ["108.xx.201.xx/32"]  # ✓ Only my IP
   }
```

**Key Lesson:** The `/32` CIDR notation means "exactly this one IP address" (most restrictive). This is security best practice! 🔐

---

### Challenge #3: tfsec Still Failing After Fix

**The Problem:**
I spent hours trying to figure out why GitHub Actions couldn't authenticate to AWS, even though:
- The OIDC provider existed ✓
- The IAM role existed ✓
- The trust policy looked correct ✓

**Root Causes Found:**
1. **OIDC Provider URL was incomplete** — It was stored as `token.actions.githubusercontent.com` instead of `https://token.actions.githubusercontent.com`
2. **Trust policy was too strict initially** — I had overly specific conditions that weren't matching GitHub's token format
3. **Role needed to be recreated** — After fixing the OIDC provider, the role needed to be synced with the new provider

**The Solution:**
```bash
# Deleted and recreated OIDC provider with full https:// URL
aws iam delete-open-id-connect-provider \
  --open-id-connect-provider-arn arn:aws:iam::708380009537:oidc-provider/token.actions.githubusercontent.com

aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com

# Deleted and recreated the role with simpler trust policy conditions
aws iam update-assume-role-policy \
  --role-name DevSecOps-Pipeline-Role \
  --policy-document file://trust-policy.json
```

**Key Lesson:** OIDC URLs must include the protocol (`https://`). The devil is in the details! 🔍

---

### Challenge #2: Pipeline Failed at Security Gate

**The Problem:**
GitHub Actions successfully authenticated to AWS, but **tfsec caught security vulnerabilities** and blocked deployment.

**Vulnerability Found:**
My Terraform code had:
```hcl
ingress {
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]  # ❌ Anyone on Earth can SSH!
}
```

**The Solution:**
This was **intentional** — the lab included a deliberate vulnerability to demonstrate Shift-Left Security. I fixed it by:

1. **Finding my home IP address:**
```bash
   curl ifconfig.me
   # Output: 108.xx.201.xx
```

2. **Updating the security group to allow SSH only from my IP:**
```hcl
   ingress {
     from_port   = 22
     to_port     = 22
     protocol    = "tcp"
     description = "SSH access from home IP only"
     cidr_blocks = ["108.xx.201.xx/32"]  # ✓ Only my IP
   }
```

**Key Lesson:** The `/32` CIDR notation means "exactly this one IP address" (most restrictive). This is security best practice! 🔐

---

### Challenge #3: tfsec Still Failing After Fix

**The Problem:**
Even after fixing the SSH rule, tfsec still blocked the pipeline with a **different error**:
**The Solution:**
tfsec requires **descriptions on all security group rules** for documentation and compliance. I added:

```hcl
ingress {
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  description = "SSH access from home IP only"  # ✓ Added!
  cidr_blocks = ["108.14.201.176/32"]
}
```

**Key Lesson:** Security isn't just about blocking bad traffic — it's about **documenting why** each rule exists. 📝

---

## ✅ Final Success: All Green!

**After fixing all vulnerabilities, the pipeline turned GREEN:**
**Result:** Security group successfully deployed to AWS with:
- SSH restricted to my home IP only
- Full audit trail in GitHub Actions logs
- Zero hardcoded AWS credentials
- Automated security scanning before deployment

---

### Key Files

**`main.tf` — Infrastructure as Code**
- Defines AWS security group with SSH ingress rule
- Restricted to home IP only (108.14.201.176/32)
- Includes description for compliance

**`.github/workflows/forge-pipeline.yml` — CI/CD Pipeline**
- Triggers on push to main branch
- Uses AWS OIDC for keyless authentication
- Runs tfsec security scanning with hard-fail mode
- Applies Terraform only if security gates pass

---

## 🔑 OIDC Configuration (The Magic Part)

This lab demonstrates **keyless authentication** — GitHub Actions authenticates to AWS **without any hardcoded AWS keys**.

### How It Works

1. **GitHub Actions generates an OIDC token** with claims about the repository:
```json
   {
     "iss": "https://token.actions.githubusercontent.com",
     "sub": "repo:Wendtin@72520900/TLAB7-Forge@1320470024:ref:refs/heads/main",
     "aud": "sts.amazonaws.com"
   }
```

2. **AWS trusts GitHub's OIDC provider:**
```json
   {
     "Effect": "Allow",
     "Principal": {
       "Federated": "arn:aws:iam::708380009537:oidc-provider/token.actions.githubusercontent.com"
     },
     "Action": "sts:AssumeRoleWithWebIdentity",
     "Condition": {
       "StringEquals": {
         "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
       },
       "StringLike": {
         "token.actions.githubusercontent.com:sub": "repo:Wendtin/TLAB7-Forge:ref:refs/heads/main"
       }
     }
   }
```

3. **GitHub Actions assumes the AWS role** and gets temporary credentials

4. **Pipeline runs with AWS permissions** — no long-lived keys needed!

### Security Benefits

✅ **No hardcoded credentials** — Eliminates credential theft  
✅ **Fine-grained permissions** — Role limited to specific repo/branch  
✅ **Temporary tokens** — Short-lived credentials (1 hour default)  
✅ **Audit trail** — Every deployment logged with GitHub actor  
✅ **Rotation-free** — Tokens rotate automatically  

---

## 🛠️ How to Reproduce This Lab

### Prerequisites

- AWS Account with CLI configured
- GitHub repository (yours or forked)
- Terraform installed locally
- tfsec installed (optional, runs in GitHub Actions)

### Step 1: Clone the Repository

```bash
git clone https://github.com/Wendtin/TLAB7-Forge.git
cd TLAB7-Forge
```

### Step 2: Set Up AWS OIDC

```bash
# Create OIDC provider (if not exists)
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com

# Create trust policy file
cat > trust-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::YOUR_ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:YOUR_USERNAME/TLAB7-Forge:ref:refs/heads/main"
        }
      }
    }
  ]
}
EOF

# Create IAM role
aws iam create-role \
  --role-name DevSecOps-Pipeline-Role \
  --assume-role-policy-document file://trust-policy.json

# Attach admin policy
aws iam attach-role-policy \
  --role-name DevSecOps-Pipeline-Role \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
```

**Replace:**
- `YOUR_ACCOUNT_ID` with your AWS account ID
- `YOUR_USERNAME` with your GitHub username

### Step 3: Update Workflow

Edit `.github/workflows/forge-pipeline.yml` and update:
```yaml
role-to-assume: arn:aws:iam::YOUR_ACCOUNT_ID:role/DevSecOps-Pipeline-Role
```

### Step 4: Update Security Group Rule

Edit `main.tf` and replace my IP with yours:
```bash
curl ifconfig.me  # Get your IP
```

Then update:
```hcl
cidr_blocks = ["YOUR_IP_ADDRESS/32"]
```

### Step 5: Push and Deploy

```bash
git add .
git commit -m "Configure for my environment"
git push origin main
```

Watch GitHub Actions → the pipeline should:
- ✅ Authenticate with OIDC
- ✅ Pass tfsec security scan
- ✅ Deploy security group to AWS

### Step 6: Clean Up

Destroy the infrastructure to avoid AWS charges:

```bash
aws sso login  # Or use configured credentials

terraform init
terraform destroy -auto-approve
```

---

## 📊 What I Built

| Component | Details |
|-----------|---------|
| **Pipeline Stages** | 3 (Authenticate → Scan → Deploy) |
| **Security Gate** | tfsec with hard-fail mode |
| **Auth Method** | OIDC federation (keyless) |
| **IaC Tool** | Terraform |
| **Infrastructure** | AWS Security Group with restricted SSH |
| **CI/CD Platform** | GitHub Actions |
| **Deployment Method** | Automated (-auto-approve) |

---

## 🎓 Key Takeaways

### Security (DevSecOps)

1. **Shift-Left Security** — Catch vulnerabilities **before** deployment, not after
2. **Defense in Depth** — SSH restricted to single IP + security group rules documented
3. **Keyless Auth** — OIDC eliminates credential management burden
4. **Automated Scanning** — tfsec catches issues humans might miss

### DevOps (Automation)

1. **Infrastructure as Code** — Terraform makes infrastructure reproducible
2. **CI/CD Pipelines** — Automate deployment with quality gates
3. **Idempotency** — Terraform apply can run repeatedly safely
4. **Audit Trails** — GitHub Actions logs every deployment

### Cloud (AWS)

1. **OIDC Providers** — Trust external services without hardcoding credentials
2. **IAM Roles** — Fine-grained permissions for each workflow
3. **Security Groups** — First line of defense for network security
4. **Least Privilege** — SSH restricted to exactly who needs it

---

## 🔗 Resources & References

- [GitHub Actions OIDC Documentation](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect)
- [AWS IAM OIDC Providers](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services)
- [tfsec Security Checks](https://aquasecurity.github.io/tfsec/latest/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [GitHub Actions Workflow Syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)

---

## 📝 Lab Completion

- ✅ OIDC authentication working
- ✅ GitHub Actions pipeline passing
- ✅ tfsec security scanning enabled
- ✅ Terraform deployment automated
- ✅ Infrastructure deployed to AWS
- ✅ Infrastructure destroyed (cleanup)

---

## 🙌 Acknowledgments

This lab is part of **The Knowledge House (TKH) Innovation Fellowship** cloud security curriculum, demonstrating real-world DevSecOps practices used by enterprise cloud engineering teams.

**Lab Theme:** "The Synthesis" — Bringing together all the individual pieces of the DevSecOps assembly line into one unified, automated factory.

---

**Last Updated:** August 4, 2026  
**Status:** ✅ Complete  
**Difficulty:** Advanced (P2·W9)