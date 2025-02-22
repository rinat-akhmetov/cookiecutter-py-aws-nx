#!/usr/bin/env bash
#
# create_terraform_backend.sh
#
# Usage:
#   ./create_terraform_backend.sh <AWS_REGION> <S3_BUCKET_NAME> <DYNAMODB_TABLE_NAME>
#
# Example:
#   ./create_terraform_backend.sh us-east-1 my-terraform-state-bucket my-terraform-lock-table
#
# Description:
#   This script will:
#   1. Create an S3 bucket for storing Terraform state (if it does not exist).
#   2. Enable versioning and server-side encryption on the S3 bucket.
#   3. Create a DynamoDB table for Terraform state locking (if it does not exist).

set -euo pipefail

# --- Input Variables ---
AWS_REGION="${1:-}"
S3_BUCKET_NAME="${2:-}"
DYNAMODB_TABLE_NAME="${3:-}"

# --- Check required inputs ---
if [ -z "$AWS_REGION" ] || [ -z "$S3_BUCKET_NAME" ] || [ -z "$DYNAMODB_TABLE_NAME" ]; then
  echo "Usage: $0 <AWS_REGION> <S3_BUCKET_NAME> <DYNAMODB_TABLE_NAME>"
  exit 1
fi

# --- Create S3 bucket (if not exists) ---
echo "Checking if S3 bucket '$S3_BUCKET_NAME' exists..."
if aws s3api head-bucket --bucket "$S3_BUCKET_NAME" 2>/dev/null; then
  echo "Bucket '$S3_BUCKET_NAME' already exists."
else
  echo "Creating S3 bucket '$S3_BUCKET_NAME' in region '$AWS_REGION'..."
  # If the region is anything other than us-east-1, we need to specify a LocationConstraint
  if [ "$AWS_REGION" = "us-east-1" ]; then
    aws s3api create-bucket --bucket "$S3_BUCKET_NAME"
  else
    aws s3api create-bucket \
      --bucket "$S3_BUCKET_NAME" \
      --region "$AWS_REGION" \
      --create-bucket-configuration LocationConstraint="$AWS_REGION"
  fi
fi

# --- Enable bucket versioning ---
echo "Enabling versioning on bucket '$S3_BUCKET_NAME'..."
aws s3api put-bucket-versioning \
  --bucket "$S3_BUCKET_NAME" \
  --versioning-configuration Status=Enabled \
  --region "$AWS_REGION"

# --- Enable default server-side encryption (AES-256) ---
echo "Enabling AES-256 encryption on bucket '$S3_BUCKET_NAME'..."
aws s3api put-bucket-encryption \
  --bucket "$S3_BUCKET_NAME" \
  --server-side-encryption-configuration '{
    "Rules": [
      {
        "ApplyServerSideEncryptionByDefault": {
          "SSEAlgorithm": "AES256"
        }
      }
    ]
  }' \
  --region "$AWS_REGION"

# --- Create DynamoDB table (if not exists) ---
echo "Checking if DynamoDB table '$DYNAMODB_TABLE_NAME' exists..."
if aws dynamodb describe-table --table-name "$DYNAMODB_TABLE_NAME" --region "$AWS_REGION" >/dev/null 2>&1; then
  echo "DynamoDB table '$DYNAMODB_TABLE_NAME' already exists."
else
  echo "Creating DynamoDB table '$DYNAMODB_TABLE_NAME' in region '$AWS_REGION'..."
  aws dynamodb create-table \
    --table-name "$DYNAMODB_TABLE_NAME" \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region "$AWS_REGION"

  echo "Waiting for DynamoDB table '$DYNAMODB_TABLE_NAME' to become ACTIVE..."
  aws dynamodb wait table-exists \
    --table-name "$DYNAMODB_TABLE_NAME" \
    --region "$AWS_REGION"
fi

echo "All done! S3 bucket '$S3_BUCKET_NAME' and DynamoDB table '$DYNAMODB_TABLE_NAME' are ready."