data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

data "aws_vpc" "existing" {
  filter {
    name   = "tag:Name"
    values = ["fase3-infra-totem-de-pedidos-vpc"]
  }
}

data "aws_subnets" "public_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing.id]
  }
  filter {
    name   = "tag:Tier"
    values = ["public"]
  }
}

locals {
  role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
}

variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "fase3-database-totem-de-pedidos"
  type        = string
  default     = "fase3-database-totem-de-pedidos"
}

# GitHub Actions credentials (optional - only needed if storing in Parameter Store)
variable "github_aws_access_key_id" {
  description = "AWS Access Key ID for GitHub Actions (optional - used for Parameter Store)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "github_aws_secret_access_key" {
  description = "AWS Secret Access Key for GitHub Actions (optional - used for Parameter Store)"
  type        = string
  default     = ""
  sensitive   = true
}

# GitHub OIDC configuration (recommended approach)
variable "enable_github_oidc" {
  description = "Enable GitHub OIDC provider for secure authentication"
  type        = bool
  default     = true
}

variable "github_repository" {
  description = "GitHub repository in format owner/repo (e.g., FIAP-11SOAT/fase3-database-totem-de-pedidos)"
  type        = string
  default     = "FIAP-11SOAT/fase3-database-totem-de-pedidos"
}


