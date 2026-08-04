# S-XXV: The Radar 📡
**Amazon GuardDuty Deployment & Threat Detection Lab**

---

## Quick Overview

This lab demonstrates **enterprise threat detection** by deploying Amazon GuardDuty as Infrastructure as Code (Terraform), simulating a security breach, and performing SOC triage analysis.

**Lab Metadata:**
- **Course:** TKH Innovation Fellowship 2026
- **Phase:** Phase 2 · Week 9 · Day 1
- **Status:** ✅ Completed (August 4, 2026)
- **Points:** 5/5

---

## What You'll Learn

This lab teaches:
- ✅ Deploy AWS GuardDuty using **Terraform** (Infrastructure as Code)
- ✅ Fix intentionally sabotaged IaC code to enable security monitoring
- ✅ Generate and analyze simulated security findings
- ✅ Perform threat triage like a real SOC analyst
- ✅ Understand how security alerts flow to operations teams

---

## Lab Structure

### Phase 1: Deploy the Radar 🚀

**Goal:** Fix sabotaged Terraform and activate GuardDuty

**The Problem:**
```hcl
# Original code — radar is BLIND ❌
resource "aws_guardduty_detector" "primary_radar" {
  enable = false  
  finding_publishing_frequency = "FIFTEEN_MINUTES"
}
```

**The Solution:**
```hcl
# Fixed code — radar is ACTIVE ✅
provider "aws" {
  region = "us-east-1"
}

resource "aws_guardduty_detector" "primary_radar" {
  enable                       = true
  finding_publishing_frequency = "FIFTEEN_MINUTES"
}
```

**Deploy with Terraform:**
```bash
terraform init
terraform plan
terraform apply -auto-approve
```

**Result:** GuardDuty detector `10cfe7646bca17bb569cf981d42c21aa` deployed and monitoring AWS account `708380009537`

---

### Phase 2: Simulate the Breach 🔴

**Goal:** Generate threat findings and analyze a critical incident

**Steps:**
1. Open AWS GuardDuty console
2. Go to **Settings** → **Sample findings** → Click **Generate sample findings**
3. Navigate to **Findings** menu
4. Locate finding: `UnauthorizedAccess:IAMUser/InstanceCredentialExfiltration.OutsideAWS`
5. Expand JSON details panel

**Triage Analysis:**

| Question | Answer |
|----------|--------|
| **Compromised Access Key** | `GeneratedFindingAccessKeyId` |
| **Hacker IP Address** | `198.51.100.0` |
| **Hacker Location** | `GeneratedFindingCityName, GeneratedFindingCountryName` |

**What This Finding Means:**
- 🚨 **Severity:** HIGH
- 📍 **Threat:** EC2 credentials were exfiltrated and used outside AWS infrastructure
- ⚡ **Impact:** Attacker has programmatic access to AWS resources
- 🎯 **Action:** Immediate credential rotation and incident investigation required

---

### Phase 3: Cleanup & Submission 📤

**Destroy Infrastructure:**
```bash
terraform destroy -auto-approve
```

**Submit to Canvas:**
- ✅ Screenshot of GuardDuty finding (JSON details)
- ✅ Fixed `guardduty.tf` file
- ✅ Answers to three triage questions

---

## File Structure

S25-Radar-Lab/
├── README.md # This file
├── guardduty.tf # Fixed Terraform code
├── .terraform/ # Terraform cache (in .gitignore)
├── terraform.tfstate # State file (in .gitignore)
└── .gitignore # Excludes sensitive files


---

## Technologies Used

| Tool | Purpose |
|------|---------|
| **Terraform** | Infrastructure as Code (IaC) for AWS |
| **AWS GuardDuty** | Threat detection & monitoring service |
| **AWS CLI** | Command-line AWS management |
| **Kali Linux** | Lab environment |

---

## How to Run This Lab

### Prerequisites
```bash
# Install Terraform
brew install terraform

# Install AWS CLI
pip install awscli

# Configure AWS credentials
aws configure
```

### Execution
```bash
# Navigate to lab directory
cd ~/My-Portfolio/terraform_labs/S25-Radar-Lab

# Deploy GuardDuty
terraform init
terraform plan
terraform apply -auto-approve

# Generate sample findings in AWS console
# (Navigate to GuardDuty → Settings → Generate sample findings)

# Analyze threats in GuardDuty console
# (Find: UnauthorizedAccess:IAMUser/InstanceCredentialExfiltration.OutsideAWS)

# Clean up
terraform destroy -auto-approve
```

---

## Key Concepts Covered

### Infrastructure as Code (IaC)
- Define cloud infrastructure in code
- Version control your infrastructure
- Reproducible deployments

### Threat Detection
- How GuardDuty identifies suspicious activity
- Understanding finding severity levels (High/Medium/Low)
- Real-world threat patterns

### SOC Operations
- Receiving and analyzing security alerts
- Triage workflow: severity → investigation → response
- Extracting actionable intelligence from findings

### Security Incident Response
- Identifying compromised credentials
- Determining attack origin (IP geolocation)
- Taking immediate remediation actions

---

## Key Learning Outcomes

After completing this lab, you can:
- ✅ Deploy AWS security services using Terraform
- ✅ Interpret GuardDuty threat findings
- ✅ Perform basic security incident triage
- ✅ Understand how SOCs detect and respond to threats
- ✅ Manage infrastructure lifecycle (create → test → destroy)

---

## Security Insights

### Why This Finding is Critical
The `InstanceCredentialExfiltration.OutsideAWS` finding represents a **real-world attack pattern:**

1. **Credential Exposure:** EC2 instance credentials were leaked to attacker
2. **External Access:** Credentials used from IP outside AWS infrastructure
3. **Unauthorized API Calls:** Attacker making AWS API calls as EC2 instance
4. **Account Compromise:** Full programmatic access to AWS resources

### How to Respond
- 🔴 **Immediate:** Disable compromised access key
- 🟠 **Urgent:** Investigate what resources were accessed
- 🟡 **Important:** Audit CloudTrail logs for attacker activity
- 🟢 **Ongoing:** Implement credential rotation policy

---

## Related Labs

This lab is part of a security progression:
- **S-XX (The Quality Inspector):** Shift-Left security scanning with tfsec
- **S-XXI (The Traveler's Guide):** Keyless authentication with OIDC
- **S-XXV (The Radar):** Runtime threat detection with GuardDuty

---

## References

- [AWS GuardDuty Docs](https://docs.aws.amazon.com/guardduty/)
- [Terraform AWS GuardDuty](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector)
- [AWS Finding Types](https://docs.aws.amazon.com/guardduty/latest/ug/guardduty-findings.html)

---

## Submission Status

- **Completed:** ✅ August 4, 2026
- **Points:** 5/5
- **GitHub:** [Wendtin/My-Portfolio](https://github.com/Wendtin/My-Portfolio)

---

**Author:** WT (Wend Tin Basile Sam)  
**Certification Program:** TKH Innovation Fellowship 2026