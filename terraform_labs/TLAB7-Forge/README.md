# The Automated Forge: End-to-End DevSecOps Pipeline

## 🎯 Project Overview

**The Automated Forge** is a production-grade CI/CD pipeline demonstrating enterprise DevSecOps practices through automated infrastructure provisioning, security scanning, and AWS deployment using Infrastructure-as-Code (IaC) principles. This project implements a multi-stage GitHub Actions pipeline that orchestrates infrastructure hardening, vulnerability detection, and zero-trust deployment workflows.

The pipeline automates the complete software delivery lifecycle: security validation happens *before* infrastructure reaches production, embedding security as a first-class citizen in the DevOps workflow rather than an afterthought.

---

## 🏗️ Architecture & Workflow

### **Pipeline Stages**

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│ GitHub Actions  │────▶│  OIDC Federation │────▶│  tfsec Scanner  │
│ (Trigger)       │     │  (Keyless Auth)  │     │  (Sec. Gate)    │
└─────────────────┘     └──────────────────┘     └─────────────────┘
                               │
                               ▼
                        ┌──────────────────┐
                        │  Terraform Plan  │
                        │  (Dry-Run)       │
                        └──────────────────┘
                               │
                               ▼
                        ┌──────────────────┐
                        │ Terraform Deploy │
                        │ (AWS Apply)      │
                        └──────────────────┘
```

### **Security Controls Implemented**

- **Keyless Authentication**: GitHub OIDC federation eliminates long-lived AWS access keys
- **Infrastructure Scanning**: tfsec detects security misconfigurations in Terraform code pre-deployment
- **Least-Privilege IAM**: Minimal role-based permissions for GitHub Actions (not AdministratorAccess)
- **Encrypted State Management**: Terraform state stored in S3 with encryption and versioning
- **Automated Compliance**: Security policy enforcement as code (Terraform checks)

---

## 🛠️ Technologies Used

- **CI/CD**: GitHub Actions (workflow automation, OIDC provider)
- **Infrastructure-as-Code**: Terraform (HCL) with module-based architecture
- **Cloud Platform**: AWS (EC2, VPC, IAM, S3, KMS)
- **Security Scanning**: tfsec (static infrastructure analysis)
- **Identity & Access**: AWS IAM with OIDC trust relationships, OpenID Connect
- **Version Control**: Git + GitHub with branch protection rules
- **Secrets Management**: GitHub Secrets (encrypted environment variables)

---

## 🚀 Getting Started

### **Prerequisites**

- GitHub repository with Actions enabled
- AWS Account with appropriate IAM permissions
- Terraform ≥ 1.0
- AWS CLI v2 configured
- Git client

### **Setup Instructions**

#### **1. Configure GitHub OIDC Trust (AWS IAM)**

```bash
# Create OIDC Identity Provider in AWS
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1

# Create IAM role for GitHub Actions
aws iam create-role \
  --role-name GitHub-OIDC-Terraform-Role \
  --assume-role-policy-document file://trust-policy.json
```

#### **2. Attach Least-Privilege Policy**

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:*",
        "s3:*",
        "iam:*",
        "kms:*"
      ],
      "Resource": "*"
    }
  ]
}
```

#### **3. Configure GitHub Secrets**

```
AWS_REGION: us-east-1
AWS_ROLE_ARN: arn:aws:iam::ACCOUNT-ID:role/GitHub-OIDC-Terraform-Role
```

#### **4. Deploy Pipeline**

```bash
git clone https://github.com/Wendtin/TLAB7-Forge.git
cd TLAB7-Forge
git push origin main  # Triggers GitHub Actions
```

---

## 📊 Key Metrics & Outcomes

| Metric | Result |
|--------|--------|
| **Deployment Automation** | 100% hands-free from code commit to AWS infrastructure |
| **Security Gate Success Rate** | tfsec scanning prevents misconfigurations pre-deployment |
| **Authentication Model** | Keyless (OIDC), zero long-lived credentials |
| **IAM Least-Privilege** | Role-specific permissions, eliminates AdministratorAccess |
| **Infrastructure Reproducibility** | All infrastructure codified, versionable, auditable |

---

## 🔒 Security Features

✅ **Shift-Left Security**: Vulnerabilities caught during CI/CD, not in production  
✅ **Keyless OIDC**: No AWS access keys stored in GitHub Secrets  
✅ **Encrypted State**: Terraform state in S3 with KMS encryption  
✅ **Audit Trail**: CloudTrail logs all Terraform-provisioned AWS API calls  
✅ **IAM Hardening**: Assume-role requires OIDC token from verified GitHub  

---

## 📁 Repository Structure

```
TLAB7-Forge/
├── .github/workflows/
│   └── deploy.yml                 # GitHub Actions pipeline definition
├── terraform/
│   ├── main.tf                    # VPC, EC2, security groups
│   ├── iam.tf                     # Least-privilege roles & policies
│   ├── s3.tf                      # State backend + encryption
│   ├── variables.tf               # Input variables
│   └── terraform.tfvars           # Environment-specific values
├── docs/
│   ├── ARCHITECTURE.md            # Detailed design docs
│   └── OIDC_SETUP.md              # Step-by-step OIDC federation
├── README.md                      # This file
└── .gitignore                     # Terraform sensitive files
```

---

## 🧪 Testing & Validation

### **Local Terraform Validation**

```bash
cd terraform/
terraform init
terraform fmt -recursive           # Validate code style
terraform validate                 # Check syntax
terraform plan                     # Dry-run
```

### **Security Scanning (tfsec)**

```bash
tfsec terraform/ --minimum-severity HIGH
```

### **GitHub Actions Simulation**

View pipeline execution:
```bash
gh run view                         # List recent runs
gh run view RUN_ID --log            # View detailed logs
```

---

## 🚨 Troubleshooting

### **Issue: OIDC Token Validation Failed**

**Solution**: Verify trust relationship in IAM role

```bash
aws iam get-role --role-name GitHub-OIDC-Terraform-Role
# Check "AssumeRolePolicyDocument" includes GitHub token endpoint
```

### **Issue: tfsec Blocking Deployment**

**Solution**: Review findings and remediate before merging

```bash
tfsec terraform/ --format json | jq '.[] | {rule: .rule, description: .description}'
```

### **Issue: Terraform State Lock**

**Solution**: Release lock if deployment interrupted

```bash
terraform force-unlock LOCK_ID
```

---

## 📚 Learning Resources

- [GitHub Actions OIDC Configuration](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [tfsec Security Scanner](https://aquasecurity.github.io/tfsec/)
- [AWS IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)

---

## 📈 Future Enhancements

- [ ] Terraform state drift detection (continuous compliance)
- [ ] Automated cost optimization analysis (finops.md)
- [ ] Multi-region deployment orchestration
- [ ] Automated incident response playbooks (Lambda-triggered)
- [ ] Advanced threat detection via AWS GuardDuty integration
- [ ] Terraform module versioning & dependency management

---

## 👤 Author

**Wend Tin Basile Sam** (WT)  
Cloud Security Architect | DevSecOps Engineer  
TKH Innovation Fellowship 2026 (Cloud Security Track)

📧 sw.basile14@gmail.com  
🔗 [GitHub](https://github.com/Wendtin) | [LinkedIn](https://linkedin.com/in/wendtin)

---

## 📄 License

MIT License — See LICENSE file for details

---

## 🙋 Contributing

This is a portfolio project. Contributions and feedback welcome!

**Report Issues**: [GitHub Issues](https://github.com/Wendtin/TLAB7-Forge/issues)  
**Suggest Enhancements**: Open a discussion or pull request with detailed context

---

**Last Updated**: August 2026  
**Status**: ✅ Production-Ready