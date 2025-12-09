#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "========================================="
echo "⚠️  DESTROY AWS Infrastructure"
echo "========================================="

cd "${SCRIPT_DIR}"

if [ ! -f "terraform.tfstate" ]; then
    echo "❌ No terraform state found. Nothing to destroy."
    exit 1
fi

echo ""
echo "This will destroy all AWS resources created by Terraform:"
echo "  - S3 Bucket and all files"
echo "  - CloudFront Distribution"
echo "  - ACM Certificate"
echo "  - Route53 Records"
echo ""
read -p "Are you ABSOLUTELY sure you want to destroy everything? (type 'destroy' to confirm): " confirm

if [ "$confirm" != "destroy" ]; then
    echo "❌ Destruction cancelled."
    exit 1
fi

echo ""
echo "🗑️  Emptying S3 bucket before destruction..."
BUCKET_NAME=$(terraform output -raw bucket_name 2>/dev/null || echo "")
if [ -n "$BUCKET_NAME" ]; then
    aws s3 rm "s3://${BUCKET_NAME}" --recursive || true
fi

echo ""
echo "💥 Destroying infrastructure..."
terraform destroy -auto-approve

echo ""
echo "✅ Infrastructure destroyed."
echo ""
