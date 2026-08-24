# Secure Automated Web Architecture

## Description
This project automates the end-to-end deployment of a secure, enterprise-grade cloud web infrastructure on Amazon Web Services (AWS) using Terraform Infrastructure as Code (IaC). Built on zero-trust design principles, the platform integrates automated static application security testing (SAST) and compute hardening controls into a continuous integration pipeline prior to live provisioning.

## Technologies Used
* **Amazon Web Services (AWS):** VPC, Public Subnet, Internet Gateway, Route Tables, Security Groups, EC2 (Amazon Linux 2023), EBS
* **Terraform:** Infrastructure as Code (IaC) configuration and execution management
* **tfsec:** Static Application Security Testing (SAST) for HCL code analysis
* **GitHub Actions:** Automated CI/CD DevSecOps quality gate testing
* **Apache HTTP Server:** Web application hosting platform

## Architecture & Security Controls
* **Network Isolation:** Provisioned inside a custom VPC (`10.0.0.0/16`) utilizing a dedicated public subnet (`10.0.1.0/24`) and explicit Internet Gateway routing tables.
* **Firewall Hardening:** Ingress Security Group rules enforce least privilege by restricting administrative SSH (Port 22) access exclusively to an authorized administrator IP address (`/32`), while allowing public HTTP (Port 80) access for web traffic.
* **Compute Hardening:** The EC2 web instance strictly mandates Instance Metadata Service Version 2 (`http_tokens = required`) to neutralize SSRF vectors and enforces encrypted EBS root storage volumes at rest.

## Deployment Results
* **Technical Victory Result:** Passed 100% of static security checks in `tfsec` analysis with zero critical, high, or medium policy violations, establishing a zero-defect security baseline prior to live AWS deployment.
* **Business Victory Result:** Streamlined cloud provisioning from manual hour-long deployments to a repeatable, sub-15-second execution pipeline, eliminating human misconfiguration risk across all web environments.

## Deployment Instructions
**Initialize Terraform Providers:**
   ```bash
   terraform init

 Execute SAST Security Audit:**

    tfsec .
 Provision Infrastructure:

    terraform apply -auto-approve
 Verify Application:**
  http://34.200.228.215/

