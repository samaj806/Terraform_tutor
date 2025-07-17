provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "ajsammy-bucket"

# prevent accidental deletion of this bucket
  # lifecycle {
  #   prevent_destroy = true
  # }
}

# Enable versioning so you can see the full revision history of your state files
resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption by default
 resource "aws_s3_bucket_server_side_encryption_configuration" "enabled" {
  bucket = aws_s3_bucket.terraform_state.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


# Explicitly block all public access to the s3 bucket
resource "aws_s3_bucket_public_access_block" "deny" {
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DynamoDB for locking
resource "aws_dynamodb_table" "terraform-locks" {
  name         = "terraform_db-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

# terraform {
#   backend "s3" {
#     bucket         = "ajsammy-bucket"
#     key            = "global/s3/terraform.tfstate"
#     region         = "us-east-1"
#     dynamodb_table = "terraform_db-locks"
#     encrypt        = true
#   }
# }

