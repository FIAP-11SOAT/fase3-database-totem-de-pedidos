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

locals {
  aws_region = "us-east-1"
  project_name = "fase3-database-totem-de-pedidos"
}
