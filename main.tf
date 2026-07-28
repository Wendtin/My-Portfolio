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
      sse_algorithm = "AES256"
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

# FIX #4: Enable logging (bonus - tracks who accesses the bucket)
resource "aws_s3_bucket_logging" "vault_logging" {
  bucket = aws_s3_bucket.vulnerable_vault.id

  target_bucket = aws_s3_bucket.log_bucket.id
  target_prefix = "access-logs/"
}

# Create a separate bucket for logs
resource "aws_s3_bucket" "log_bucket" {
  bucket = "tkh-logs-${random_id.id.hex}"
}

# Block public access to the log bucket too
resource "aws_s3_bucket_public_access_block" "log_bucket_privacy" {
  bucket = aws_s3_bucket.log_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}