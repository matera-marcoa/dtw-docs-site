output "bucket_name" {
  description = "S3 bucket name"
  value       = aws_s3_bucket.site.id
}

output "bucket_website_endpoint" {
  description = "S3 bucket website endpoint"
  value       = aws_s3_bucket_website_configuration.site.website_endpoint
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.site.id
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.site.domain_name
}

output "site_url" {
  description = "Website URL"
  value       = "https://${var.domain_name}"
}

output "certificate_arn" {
  description = "ACM certificate ARN"
  value       = aws_acm_certificate.site.arn
}
