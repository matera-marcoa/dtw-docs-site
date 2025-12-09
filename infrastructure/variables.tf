variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "dtw-docs"
}

variable "domain_name" {
  description = "Full domain name for the static site"
  type        = string
  default     = "dtw-docs.usa.matera.systems"
}

variable "hosted_zone_name" {
  description = "Route53 hosted zone name"
  type        = string
  default     = "usa.matera.systems"
}

variable "site_path" {
  description = "Path to the static site files"
  type        = string
  default     = "../site"
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Project     = "DTW Docs"
    ManagedBy   = "Terraform"
    Environment = "Production"
  }
}
