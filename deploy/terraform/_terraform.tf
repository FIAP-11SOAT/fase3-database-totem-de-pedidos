terraform {
  required_version = ">= 1.11.0"

  backend "s3" {
    bucket         = "fase3-terraform-state"
    key            = "fase3-database-totem-de-pedidos/terraform.tfstate"
    region         = "us-east-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.15.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.7.2"
    }
  }
}