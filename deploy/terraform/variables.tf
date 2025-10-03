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

data "aws_subnets" "private_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing.id]
  }
  filter {
    name   = "tag:Tier"
    values = ["private"]
  }
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
