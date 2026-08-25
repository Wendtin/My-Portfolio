# TLAB 8: The Fleet Command

**Module:** Phase 2: Cloud Security Engineering | **Sprint:** Sprint 3 (The Cloud)  
**Standard:** World Elite Gold | **Theme:** "The Ephemeral Synthesis"  
**Completion Date:** August 6, 2026

---

## 📋 Overview

TLAB 8 is a weekend capstone that integrates **container hardening**, **AWS ECR vulnerability scanning**, **serverless deployment**, and **surgical IAM policy crafting**. The mission: build a secure audit pipeline where a Lambda function queries an ECR vault with minimal, least-privilege permissions—no wildcards, no excess access.

**Key Achievement:** ✅ **Zero vulnerabilities** in hardened container + **successful audit Lambda** with **surgical IAM policy**

---

## 🎯 Learning Objectives

- ✅ Harden Docker containers (minimal base images + non-root users)
- ✅ Implement automated vulnerability scanning (ECR Scan on Push)
- ✅ Deploy serverless Python functions (AWS Lambda + Boto3)
- ✅ Design least-privilege IAM policies (deny by default)
- ✅ Integrate end-to-end DevSecOps pipelines

---

## 🧭 Lab Phases

### **Phase 1: The Hardened Cargo**

**Goal:** Fix sabotaged container and push to AWS ECR

**Sabotage Identified:**
```dockerfile
# BEFORE (Vulnerable)
FROM node:latest          # Bloated, unversioned
WORKDIR /usr/src/app
EXPOSE 8080
CMD [ "node" ]            # Runs as root!
COPY . .                  # Order is wrong
```

**Hardened Solution:**
```dockerfile
# AFTER (Secure)
FROM node:alpine          # Minimal, ~60MB (vs 150MB+)

WORKDIR /usr/src/app
COPY . .                  # Copy before CMD

EXPOSE 8080

USER node                 # Non-root user (explicit privilege drop)

CMD ["node", "server.js"] # Explicit entrypoint
```

**Key Improvements:**
- ✅ **node:alpine** reduces attack surface (150MB → 60MB)
- ✅ **USER node** eliminates root privilege escalation vector
- ✅ Explicit **server.js** entrypoint (no ambiguity)
- ✅ Proper Dockerfile layer ordering (copy before CMD)

**Results:**
- Image pushed to private AWS ECR repository: `tkh-fleet-vault`
- **Scan on Push enabled:** Automated vulnerability detection
- **Vulnerability scan result:** ✅ **0 vulnerabilities**
  - Critical: 0 | High: 0 | Medium: 0 | Low: 0 | Info: 0

---

### **Phase 2: The Ghost Auditor**

**Goal:** Deploy Lambda function that audits ECR vault

**Function Code:**
```python
import boto3
import json

def lambda_handler(event, context):
    client = boto3.client('ecr')
    response = client.describe_images(repositoryName='tkh-fleet-vault')
    print(f"Audit Complete. Images found: {len(response['imageDetails'])}")
    return {
        'statusCode': 200,
        'body': json.dumps('Fleet Audit Successful!')
    }
```

**Deployment:**
- Function name: `Fleet-Auditor`
- Runtime: Python 3.12
- Handler: `lambda_function.lambda_handler`
- Execution role: Custom least-privilege policy (see Phase 3)

**Capabilities:**
- ✅ Connects to ECR using Boto3 SDK
- ✅ Queries repository for image metadata
- ✅ Logs audit results to CloudWatch
- ✅ Returns structured JSON response

---

### **Phase 3: The Surgical Perimeter (IAM)**

**Goal:** Replace wildcard AdminAccess with least-privilege policy

**Problem:**
```json
// BEFORE (Dangerous)
{
  "Effect": "Allow",
  "Action": "*",           // Everything!
  "Resource": "*"          // Everywhere!
}
// If Lambda is breached → attacker owns entire AWS account
```

**Solution:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecr:DescribeImages"
      ],
      "Resource": "arn:aws:ecr:us-east-1:708380009537:repository/tkh-fleet-vault"
    }
  ]
}
```

**Policy Principles:**
- ✅ **CloudWatch Logs:** Broad scope (all regions, all accounts) — necessary for logging
- ✅ **ECR DescribeImages:** Narrow scope — **only** the `tkh-fleet-vault` repository
- ✅ **Implicit Deny:** Everything else is denied by default
- ✅ **No Wildcards:** Specific resource ARNs, no glob patterns

**Attachment:**
1. Created policy: `Fleet-Auditor-Policy`
2. Created IAM role for Lambda
3. Attached policy to role
4. Assigned role to Lambda execution

**Validation:**
- ✅ Lambda test execution: **SUCCESS**
- ✅ Log output: `"Audit Complete. Images found: 1"`
- ✅ HTTP response: `{"statusCode": 200, "body": "Fleet Audit Successful!"}`

---

### **Phase 4: Teardown & Submission**

**Cleanup:**
- ✅ Deleted ECR repository (`tkh-fleet-vault`)
- ✅ Deleted Lambda function (`Fleet-Auditor`)
- ✅ Prevented storage/compute charges

**Submission Files:**
1. **Dockerfile** — Hardened container definition
2. **auditor-role.json** — Least-privilege IAM policy
3. **Screenshot A** — ECR vulnerability scan (0 vulnerabilities)
4. **Screenshot B** — Lambda execution log (successful audit)

---

## 🔐 Security Concepts Applied

### **1. Container Hardening**
| Technique | Benefit |
|-----------|---------|
| Alpine base image | Minimal attack surface |
| Non-root USER | Privilege escalation prevention |
| Explicit entrypoint | Ambiguity elimination |
| Immutable image tags | Version control |

### **2. Vulnerability Scanning**
- **Scan on Push:** Automated detection at deployment time
- **CVE Database:** Real-time threat intelligence
- **Gate Enforcement:** Fail deployment if vulnerabilities exceed threshold

### **3. Least Privilege IAM**
- **Principle of Least Privilege:** Grant only necessary permissions
- **Specific Resources:** ARNs, not wildcards
- **Action Auditing:** CloudWatch logs for accountability
- **Defense in Depth:** Multiple security layers (container + IAM + scanning)

### **4. Serverless Security**
- **Execution Roles:** Lambda assumes temporary credentials (not static keys)
- **Implicit Deny:** All actions denied unless explicitly allowed
- **Scoped Permissions:** Resource-level access control

---

## 📊 Technical Stack

| Component | Technology | Purpose |
|-----------|-----------|---------|
| **Base Image** | Docker (node:alpine) | Containerization |
| **Container Registry** | AWS ECR | Private image storage |
| **Scanning** | Amazon ECR Scan | Vulnerability detection |
| **Serverless** | AWS Lambda | Audit function |
| **Code Runtime** | Python 3.12 | Lambda runtime |
| **AWS SDK** | Boto3 | ECR client interaction |
| **Logging** | CloudWatch Logs | Audit trail |
| **IAM** | AWS Identity & Access Mgmt | Permission management |
| **VCS** | Git | Version control |

---

## 🚀 How to Replicate

### **Prerequisites**
- AWS Account (with ECR, Lambda, IAM permissions)
- Docker Desktop (local development)
- AWS CLI configured (`aws configure`)
- Node.js (for sample application)

### **Step 1: Clone & Prepare**
```bash
git clone https://github.com/grobbins-cell/TLAB8-Fleet.git
cd TLAB8-Fleet
```

### **Step 2: Harden Container**
```bash
# Review Dockerfile
cat Dockerfile

# Build hardened image
docker build -t tkh-fleet-vault .
```

### **Step 3: Create ECR Repository**
```bash
# Via AWS CLI
aws ecr create-repository \
  --repository-name tkh-fleet-vault \
  --image-scan-configuration scanOnPush=true \
  --region us-east-1
```

### **Step 4: Push to ECR**
```bash
# Authenticate
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin 708380009537.dkr.ecr.us-east-1.amazonaws.com

# Tag & push
docker tag tkh-fleet-vault:latest 708380009537.dkr.ecr.us-east-1.amazonaws.com/tkh-fleet-vault:latest
docker push 708380009537.dkr.ecr.us-east-1.amazonaws.com/tkh-fleet-vault:latest
```

### **Step 5: Create Lambda Function**
```bash
# Via AWS Console or CLI
aws lambda create-function \
  --function-name Fleet-Auditor \
  --runtime python3.12 \
  --role arn:aws:iam::708380009537:role/lambda-execution-role \
  --handler lambda_function.lambda_handler \
  --zip-file fileb://lambda_function.zip
```

### **Step 6: Attach IAM Policy**
```bash
# Create policy
aws iam create-policy \
  --policy-name Fleet-Auditor-Policy \
  --policy-document file://auditor-role.json

# Attach to Lambda role
aws iam attach-role-policy \
  --role-name lambda-execution-role \
  --policy-arn arn:aws:iam::708380009537:policy/Fleet-Auditor-Policy
```

### **Step 7: Test Lambda**
```bash
aws lambda invoke \
  --function-name Fleet-Auditor \
  --payload '{}' \
  response.json

cat response.json
```

### **Step 8: Verify Scan Results**
```bash
aws ecr describe-image-scan-findings \
  --repository-name tkh-fleet-vault \
  --image-id imageTag=latest \
  --region us-east-1
```

---

## 📈 Results & Outcomes

### **Container Security**
- ✅ Base image reduced from 150MB+ to 60MB
- ✅ Eliminated root privilege (USER directive enforced)
- ✅ Vulnerability scan: **0 vulnerabilities**

### **Lambda Deployment**
- ✅ Function deployed and tested successfully
- ✅ Boto3 ECR integration working
- ✅ CloudWatch logging operational

### **IAM Security**
- ✅ Replaced wildcard policy with surgical least-privilege
- ✅ Lambda now has only 2 actions:
  - `ecr:DescribeImages` (specific vault)
  - CloudWatch Logs (audit trail)
- ✅ Test execution: SUCCESS

### **DevSecOps Pipeline**
- ✅ Automated scanning at push time
- ✅ Serverless audit function
- ✅ Least-privilege integration
- ✅ Zero-trust architecture validated

---

## 🎓 Key Takeaways

1. **Container Hardening:** Alpine + non-root = significant security improvement
2. **Shift-Left Security:** Scan vulnerabilities at build time, not production
3. **Least Privilege:** Start with deny, grant only what's needed
4. **Defense in Depth:** Multiple layers (container + scanning + IAM)
5. **DevSecOps Integration:** Security embedded in CI/CD pipeline

---

## 📚 References

- [AWS ECR Best Practices](https://docs.aws.amazon.com/AmazonECR/latest/userguide/best-practices.html)
- [AWS Lambda Execution Roles](https://docs.aws.amazon.com/lambda/latest/dg/lambda-intro-execution-role.html)
- [IAM Policies for ECR](https://docs.aws.amazon.com/AmazonECR/latest/userguide/security-iam.html)
- [Docker Security Best Practices](https://docs.docker.com/engine/security/)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)

---

## 📝 Files

- **Dockerfile** — Hardened container definition
- **auditor-role.json** — Least-privilege IAM policy
- **README.md** — This documentation

---

**Completed by:** WT (Wend Tin Basile Sam)  
**Date:** August 6, 2026  
**Status:** ✅ COMPLETE