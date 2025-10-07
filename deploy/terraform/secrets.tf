resource "aws_secretsmanager_secret" "secrets" {
  name                    = "${local.project_name}-secrets"
  description             = "Secrets for ${local.project_name} project"
  recovery_window_in_days = 0

  tags = {
    Name = "${local.project_name}-secrets"
  }
}

resource "aws_secretsmanager_secret_version" "secrets" {
  secret_id = aws_secretsmanager_secret.secrets.id
  secret_string = jsonencode({
    RDS_ENDPOINT = split(":", module.rds.db_instance_endpoint)[0],
    RDS_PORT     = module.rds.db_instance_port,
    RDS_USERNAME = module.rds.db_instance_username,
    RDS_PASSWORD = random_password.rds_password.result,
    RDS_DATABASE = module.rds.db_instance_name,
  })
}