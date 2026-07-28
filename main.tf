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

# FIX #2: Enable encryption
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