terraform {
  backend "s3" {
    bucket         = "fase3-terraform-state"
    key            = "fase3-database-totem-de-pedidos/terraform.tfstate"
    region         = "us-east-1"
  }
}
