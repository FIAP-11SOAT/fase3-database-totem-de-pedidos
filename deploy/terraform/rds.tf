resource "random_password" "rds_password" {
  length  = 16
  special = true
  override_special = "!#$%&*+-=?^_|~"
}

module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 6.0"

  identifier = "${var.project_name}-rds-postgres"

  engine               = "postgres"
  engine_version       = "17.5"
  family               = "postgres17"
  major_engine_version = "17"
  instance_class       = "db.t4g.micro"
  allocated_storage    = 20

  db_name  = "infra_totem_de_pedidos_database"
  username = "infra_totem_de_pedidos_admin"
  password = random_password.rds_password.result
  manage_master_user_password = false

  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name

  tags = {
    Name = "${var.project_name}-rds-postgres"
  }
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.project_name}-rds-postgres-subnet-group"
  subnet_ids = data.aws_subnets.public_subnets.ids

  tags = {
    Name = "${var.project_name}-rds-postgres-subnet-group"
  }
}

resource "aws_security_group" "rds_sg" {
  name_prefix = "${var.project_name}-rds-postgres-sg"
  vpc_id      = data.aws_vpc.existing.id

  ingress {
    description = "Acesso externo ao PostgreSQL"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-rds-postgres-sg"
  }
}

output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = module.rds.db_instance_endpoint
  sensitive   = false
}

output "rds_port" {
  description = "RDS instance port"
  value       = module.rds.db_instance_port
  sensitive   = false
}

output "rds_username" {
  description = "RDS instance username"
  value       = module.rds.db_instance_username
  sensitive   = true
}

output "rds_database_name" {
  description = "RDS database name"
  value       = module.rds.db_instance_name
  sensitive   = false
}

output "rds_password" {
  description = "RDS instance password"
  value       = random_password.rds_password.result
  sensitive   = true
}