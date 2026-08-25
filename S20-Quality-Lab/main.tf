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

# FIX #5: Enable logging on main bucket
resource "aws_s3_bucket_logging" "vault_logging" {
  bucket = aws_s3_bucket.vulnerable_vault.id

  target_bucket = aws_s3_bucket.vault_logs.id
  target_prefix = "vault-logs/"
}

# Create KMS key for encryption
resource "aws_kms_key" "s3_key" {
  description             = "KMS key for S3 bucket encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}
resource "aws_s3_bucket_logging" "vault_logs_logging" {
  bucket = aws_s3_bucket.vault_logs.id

  target_bucket = aws_s3_bucket.vault_logs.id
  target_prefix = "self-logs/"
}

resource "aws_kms_alias" "s3_key_alias" {
  name          = "alias/s3-bucket-key"
  target_key_id = aws_kms_key.s3_key.key_id
}