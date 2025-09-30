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
    values = ["infra-totem-de-pedidos-vpc"]
  }
}

data "aws_subnets" "existing" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing.id]
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


