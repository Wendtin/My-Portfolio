# Secure Automated Web Architecture — TKH Final Capstone
## Project Overview
This project implements a secure, automated web architecture using Terraform, AWS, and GitHub Actions. It follows the TKH Capstone Milestones: building the infrastructure, enforcing a DevSecOps quality gate, and deploying a live web server. The final result is a production‑ready environment with strong network boundaries, encrypted logging, restricted access, and automated configuration.

## Milestone 1 — Infrastructure
**Phase 1:** Workspace Initialization
Created GitHub repository: TKH-Final-Capstone
Cloned repository locally and configured workspace in VS Code
Added main.tf and variables.tf files
Prepared Terraform workspace for architecture development
**Phase 2:** Architecture Build
The foundational Terraform blueprints include:

## Network
aws_vpc — 10.0.0.0/16
aws_subnet — 10.0.1.0/24
aws_internet_gateway
aws_route_table mapping 0.0.0.0/0 → IGW
Route table association

## Firewall
aws_security_group with:
HTTP (80) ingress restricted to my IP
SSH (22) ingress restricted to my IP
Controlled outbound rules for package updates
## Server
aws_instance (Amazon Linux 2023, t3.micro)
Automated bootstrap via user_data:
yum update -y
yum install -y httpd
systemctl start httpd
Custom HTML landing page
Logging & Encryption Enhancements
(Added for improved security beyond the base assignment)

KMS key for log encryption
CloudWatch Log Group with KMS encryption
IAM role + policy for VPC Flow Logs
VPC Flow Logs capturing ALL traffic
**Phase 3:** Submission Validation
Ran terraform init
Ran terraform validate
Confirmed syntax correctness and readiness for pipeline scanning

## Milestone 2 — DevSecOps Pipeline
Phase 1: SAST Workflow Creation
Created .github/workflows/security-scan.yml
Implemented tfsec scanning pipeline:
Workflow includes:

Trigger on push to main
Checkout action
aquasecurity/tfsec-pr-commenter-action@v1.2.0
--soft-fail=false to enforce hard failures
**Phase 2:** Quality Gate Enforcement

```bash
git add .
git commit -m "Added SAST pipeline"
git push

```
Observed pipeline in GitHub Actions
Fixed any tfsec findings (e.g., encryption, SG exposure)
Re‑pushed until pipeline passed with GREEN status

## Milestone 3 — Deployment
**Phase 1:** Launch & Verification
Authenticated to AWS locally
Ran terraform apply -auto-approve
Located EC2 instance in AWS Console
Copied Public IPv4 Address
Verified Apache landing page in browser
Confirmed automated user_data execution
Captured screenshot of live web server
**Phase 2:** Documentation

This README includes:
*Project Title*
*Description*
**Technologies Used**
Architecture Explanation
Technologies Used
Amazon Web Services (AWS)
Terraform
GitHub Actions
tfsec (Static Analysis Security Testing)
Architecture Overview
This environment is designed with security-first principles:

**VPC & Subnet**
A dedicated VPC (10.0.0.0/16) and public subnet (10.0.1.0/24) provide isolated network boundaries. DNS support is enabled for smooth instance resolution.

Internet Gateway & Routing
A single route table maps 0.0.0.0/0 to the Internet Gateway, allowing controlled outbound access for the EC2 instance.

**Security Group**
The firewall enforces:

HTTP (80) only from my IP
SSH (22) only from my IP
Outbound HTTP/HTTPS for package updates
This prevents public exposure and ensures tight administrative control.
EC2 Web Server
The Amazon Linux 2023 instance:

Boots with IMDSv2 enforced
Uses an encrypted root volume
Automatically installs and starts Apache
Serves a custom HTML page confirming successful deployment
Logging & Monitoring
VPC Flow Logs capture all traffic and store it in a KMS‑encrypted CloudWatch Log Group. IAM roles and policies ensure secure log ingestion.

Deployment Instructions
1. Initialize Terraform
Run: terraform init

2. Validate Configuration
Run: terraform validate

3. Review Execution Plan
Run: terraform plan

4. Deploy Infrastructure
Run: terraform apply -auto-approve

5. Retrieve Outputs
Terraform will display:

web_public_ip
web_url
Paste the IP or URL into your browser to verify the live web server.

**Post‑Deployment Verification**
Network
Web server reachable only from my IP
Apache landing page loads successfully
SSH access restricted
Logging
CloudWatch Log Group exists
Flow logs populate correctly
KMS key active and rotating
Security
Encrypted root volume
IMDSv2 enforced
SG rules locked down
**Conclusion**
This capstone demonstrates mastery of Terraform, AWS architecture, DevSecOps pipelines, and secure cloud deployment. The project integrates infrastructure automation, static security scanning, encrypted logging, and controlled network access — reflecting real-world production standards and readiness for professional DevSecOps roles.