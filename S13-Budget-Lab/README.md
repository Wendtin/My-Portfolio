# 🧱 S13-Budget-Lab: AWS Budget Alarm as Infrastructure as Code

**TKH Innovation Fellowship 2026** | **Cybersecurity Track** | **Phase 2 - Week 5**

## 📋 Overview

This lab demonstrates **Infrastructure as Code (IaC)** best practices by deploying an AWS Cost Budget alarm using **Terraform** instead of manual AWS Console clicks. The scenario: protect a $75 operational stipend with a hard billing alert.

### Learning Objectives
- ✅ Deploy AWS resources programmatically using Terraform
- ✅ Identify and fix configuration sabotage (missing required field)
- ✅ Understand AWS Budget notification thresholds and types
- ✅ Practice the Terraform workflow: `init` → `plan` → `apply` → `destroy`
- ✅ Version control infrastructure code with Git

---

## 🎯 The Challenge: Finding the Sabotage

The starter code contained a **critical configuration error** in the AWS Budget notification block:

### ❌ **Broken Code** (Original)
```hcl
notification {    
    comparison_operator        = "GREATER_THAN"    
    # ❌ MISSING: notification_type field
    threshold                  = 50    
    threshold_type             = "PERCENTAGE"    
    subscriber_email_addresses = ["sambilezony@gmail.com"]  
}
```

### ✅ **Fixed Code**
```hcl
notification {    
    comparison_operator        = "GREATER_THAN"    
    notification_type          = "ACTUAL"           # ← FIXED
    threshold                  = 50    
    threshold_type             = "PERCENTAGE"    
    subscriber_email_addresses = ["sambilezony@gmail.com"]  
}
```

**Why this matters:** AWS Budgets requires `notification_type` to specify whether you're alerting on **ACTUAL** (real spend) or **FORECASTED** (projected) costs. Without it, Terraform throws a validation error.
---

---

## 🔧 What This Terraform Code Does

### **Resource: `aws_budgets_budget`**

| Parameter | Value | Purpose |
|-----------|-------|---------|
| `name` | `TKH-Phase2-Budget` | Friendly name in AWS console |
| `budget_type` | `COST` | Track spending (vs. usage, etc.) |
| `limit_amount` | `75` | Monthly budget cap in USD |
| `limit_unit` | `USD` | Currency |
| `time_unit` | `MONTHLY` | Reset period |
| **notification** | — | Alerting mechanism |
| `notification_type` | `ACTUAL` | Alert on real spend |
| `threshold` | `50` | Alert at 50%... |
| `threshold_type` | `PERCENTAGE` | ...of budget = $37.50 |
| `comparison_operator` | `GREATER_THAN` | If spend **exceeds** threshold |
| `subscriber_email_addresses` | `["sambilezony@gmail.com"]` | Email alert recipient |

**Result:** Alert email sent when spending exceeds $37.50 in a month.

---

## 🚀 How to Deploy

### **Prerequisites**
```bash
# Verify AWS CLI is configured
aws sts get-caller-identity

# Verify Terraform is installed
terraform --version
```

### **Deployment Steps**

```bash
# 1. Clone or navigate to this repo
cd S13-Budget-Lab

# 2. Initialize Terraform (downloads AWS provider)
terraform init

# 3. Preview the changes (dry run)
terraform plan

# 4. Deploy the budget
terraform apply
# Type 'yes' when prompted

# 5. Verify in AWS Console
# → AWS Budgets → TKH-Phase2-Budget should appear

# 6. Clean up (destroy resources)
terraform destroy
# Type 'yes' when prompted
```

---

## 📸 Verification

After `terraform apply`, you should see in AWS Console:

- ✅ **Budget Name:** TKH-Phase2-Budget
- ✅ **Budget Amount:** $75.00 USD
- ✅ **Period:** Monthly
- ✅ **Alert Threshold:** 50% ($37.50)
- ✅ **Alert Status:** OK (no threshold exceeded yet)

---

## 🔑 Key Learnings

### **1. Infrastructure as Code Benefits**
- ✅ Reproducible: Deploy same config to multiple environments
- ✅ Reviewable: Team can audit changes in Git
- ✅ Versionable: Track changes with Git history
- ✅ Scriptable: Automate in CI/CD pipelines

### **2. Configuration Validation**
- Terraform validates schema before deployment
- Missing required fields caught at `plan` stage, not `apply`
- Error messages guide you to the fix

### **3. AWS Budget Best Practices**
- Set alerts at **multiple thresholds** (e.g., 50%, 80%, 100%)
- Use **ACTUAL** for conservative alerts; **FORECASTED** for early warnings
- Test in **sandbox accounts** before production

### **4. Git Workflow**
```bash
git add .
git commit -m "edited: W5 | S-XIII | Fixed notification_type sabotage"
git push origin main
```

---

## 🛠 Tech Stack

| Tool | Version | Purpose |
|------|---------|---------|
| **Terraform** | 1.15.8 | Infrastructure as Code |
| **AWS Provider** | Latest | AWS resource definitions |
| **AWS CLI** | v2+ | Credential management |
| **Git** | 2.x | Version control |
| **VS Code** | Latest | Code editor w/ Terraform extension |

---

## 📚 Resources

- [Terraform AWS Budgets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/budgets_budget)
- [AWS Budgets Documentation](https://docs.aws.amazon.com/awsaccountmanagement/latest/userguide/budgets-managing.html)
- [TKH Innovation Fellowship](https://www.theknowledgehaus.org/)

---

## 🎓 Lab Completion

- ✅ Fixed sabotage: Added `notification_type = "ACTUAL"`
- ✅ Deployed via `terraform apply`
- ✅ Verified in AWS Console
- ✅ Destroyed via `terraform destroy`
- ✅ Documented in Git
- ✅ Submitted to Canvas (July 13, 2026)

---

## 📝 Author

**WT (Wend Tin Basile Sam)**  
Cybersecurity Professional | TKH Innovation Fellow 2026  
New York, NY

**GitHub:** [@Wendtin](https://github.com/Wendtin)  
**LinkedIn:** [linkedin.com/in/wendtin](https://linkedin.com/in/wendtin)

---

*Last Updated: July 8, 2026*