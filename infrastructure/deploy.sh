#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SITE_DIR="${SCRIPT_DIR}/../site"

echo "========================================="
echo "Deploy DTW Docs to AWS S3"
echo "========================================="

cd "${SCRIPT_DIR}"

if [ ! -f "terraform.tfvars" ]; then
    echo "⚠️  terraform.tfvars not found. Creating from example..."
    cp terraform.tfvars.example terraform.tfvars
    echo "✅ terraform.tfvars created. Please review and update if needed."
fi

echo ""
echo "📦 Initializing Terraform..."
terraform init

echo ""
echo "📋 Planning infrastructure changes..."
terraform plan -out=tfplan

echo ""
read -p "Do you want to apply these changes? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "❌ Deployment cancelled."
    rm -f tfplan
    exit 1
fi

echo ""
echo "🚀 Applying infrastructure changes..."
terraform apply tfplan
rm -f tfplan

echo ""
echo "📤 Syncing site files to S3..."
BUCKET_NAME=$(terraform output -raw bucket_name)
aws s3 sync "${SITE_DIR}" "s3://${BUCKET_NAME}" \
    --delete \
    --exclude ".git/*" \
    --exclude ".DS_Store" \
    --cache-control "public, max-age=3600"

echo ""
echo "🔄 Invalidating CloudFront cache..."
DISTRIBUTION_ID=$(terraform output -raw cloudfront_distribution_id)
aws cloudfront create-invalidation \
    --distribution-id "${DISTRIBUTION_ID}" \
    --paths "/*" \
    --no-cli-pager

echo ""
echo "========================================="
echo "✅ Deployment completed successfully!"
echo "========================================="
echo ""
terraform output site_url
echo ""
