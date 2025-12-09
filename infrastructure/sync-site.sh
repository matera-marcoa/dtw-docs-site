#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SITE_DIR="${SCRIPT_DIR}/../site"

echo "========================================="
echo "Sync Site Files to S3"
echo "========================================="

cd "${SCRIPT_DIR}"

if [ ! -f "terraform.tfstate" ]; then
    echo "❌ Terraform state not found. Please run deploy.sh first."
    exit 1
fi

BUCKET_NAME=$(terraform output -raw bucket_name 2>/dev/null)
DISTRIBUTION_ID=$(terraform output -raw cloudfront_distribution_id 2>/dev/null)

if [ -z "$BUCKET_NAME" ]; then
    echo "❌ Could not get bucket name from Terraform state."
    exit 1
fi

echo ""
echo "📤 Syncing files to S3 bucket: ${BUCKET_NAME}"
aws s3 sync "${SITE_DIR}" "s3://${BUCKET_NAME}" \
    --delete \
    --exclude ".git/*" \
    --exclude ".DS_Store" \
    --cache-control "public, max-age=3600"

if [ -n "$DISTRIBUTION_ID" ]; then
    echo ""
    echo "🔄 Invalidating CloudFront cache..."
    aws cloudfront create-invalidation \
        --distribution-id "${DISTRIBUTION_ID}" \
        --paths "/*" \
        --no-cli-pager
fi

echo ""
echo "✅ Site sync completed!"
echo ""
