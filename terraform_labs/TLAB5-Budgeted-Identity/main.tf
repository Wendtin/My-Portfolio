terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {  
  region = "us-east-1"
}

# ============================================================================
# GENERATE RANDOM ID FOR UNIQUE S3 BUCKET NAMING
# ============================================================================
resource "random_id" "id" {
  byte_length = 4
}

# ============================================================================
# STEP 1: AWS BUDGET — Financial Firewall (Deny of Wallet Protection)
# ============================================================================
resource "aws_budgets_budget" "titan_monthly" {  
  name              = "Titan-FinTech-Monthly-$10"  
  budget_type       = "COST"  
  limit_amount      = "10.00"  
  limit_unit        = "USD"  
  time_unit         = "MONTHLY"  

  notification {    
    comparison_operator        = "GREATER_THAN"    
    notification_type          = "FORECASTED"    
    threshold                  = 80    
    threshold_type             = "PERCENTAGE"    
    subscriber_email_addresses = ["sambilezont@gmail.com"]  
  }
}

# ============================================================================
# STEP 2: S3 BUCKET — Secure Vault
# ============================================================================
resource "aws_s3_bucket" "titan_vault" {
  bucket = "titan-fintech-vault-wt-${random_id.id.hex}"
  # Using your initials (WendTin = WT) makes it identifiable
  # S3 bucket names are globally unique—the random_id ensures that
}

# Block all public access—this is the default but we enforce it
resource "aws_s3_bucket_public_access_block" "titan_vault" {
  bucket = aws_s3_bucket.titan_vault.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable versioning (best practice for financial data)
resource "aws_s3_bucket_versioning" "titan_vault" {
  bucket = aws_s3_bucket.titan_vault.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable encryption at rest (AES-256)
resource "aws_s3_bucket_server_side_encryption_configuration" "titan_vault" {
  bucket = aws_s3_bucket.titan_vault.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ============================================================================
# STEP 3: IAM ROLE — Surgical Least Privilege (Trust Policy)
# ============================================================================
resource "aws_iam_role" "titan_ec2_vault_role" {
  name = "Titan-EC2-Vault-Role-v2"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"  # ONLY EC2 instances can use this role
        }
      }
    ]
  })
}

# ============================================================================
# STEP 4: IAM POLICY — Permissions (What can the role do?)
# ============================================================================
resource "aws_iam_policy" "titan_s3_put_object" {
  name   = "Titan-S3-PutObject-Only"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowPutObjectToTitanVault"
        Effect = "Allow"
        Action = [
          "s3:PutObject"  # ONLY this action—nothing else
        ]
        Resource = [
          "${aws_s3_bucket.titan_vault.arn}/*"  # ONLY this bucket—nowhere else
        ]
      }
    ]
  })
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "titan_attach_s3_policy" {
  role       = aws_iam_role.titan_ec2_vault_role.name
  policy_arn = aws_iam_policy.titan_s3_put_object.arn
}

# ============================================================================
# STEP 5: IAM INSTANCE PROFILE — Glue between EC2 and IAM Role
# ============================================================================
resource "aws_iam_instance_profile" "titan_ec2_profile" {
  name = "Titan-EC2-Instance-Profile"
  role = aws_iam_role.titan_ec2_vault_role.name
}

# ============================================================================
# STEP 6: DATA SOURCE — Get Latest Ubuntu 22.04 LTS AMI
# ============================================================================
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]  # Canonical's AWS account

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ============================================================================
# STEP 7: EC2 INSTANCE — Compute Wearing the Restricted Role
# ============================================================================
resource "aws_instance" "titan_vault_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"  # Free Tier eligible
  iam_instance_profile   = aws_iam_instance_profile.titan_ec2_profile.name

  tags = {
    Name = "Titan-Vault-Server"
  }
}

# ============================================================================
# STEP 8: OUTPUTS — Display Key Information
# ============================================================================
output "instance_id" {
  value       = aws_instance.titan_vault_server.id
  description = "EC2 Instance ID"
}

output "instance_public_ip" {
  value       = aws_instance.titan_vault_server.public_ip
  description = "EC2 Instance Public IP"
}

output "s3_bucket_name" {
  value       = aws_s3_bucket.titan_vault.id
  description = "S3 Bucket Name"
}

output "iam_role_name" {
  value       = aws_iam_role.titan_ec2_vault_role.name
  description = "IAM Role Name"
}
