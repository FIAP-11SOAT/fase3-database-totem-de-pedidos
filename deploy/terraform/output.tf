# ==============================================================================
# RDS DATABASE OUTPUTS
# ==============================================================================

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

output "rds_database_name" {
  description = "RDS database name"
  value       = module.rds.db_instance_name
  sensitive   = false
}

output "rds_username" {
  description = "RDS master username"
  value       = module.rds.db_instance_username
  sensitive   = false
}

output "rds_password" {
  description = "RDS master password"
  value       = random_password.rds_password.result
  sensitive   = true
}

output "rds_identifier" {
  description = "RDS instance identifier"
  value       = module.rds.db_instance_identifier
  sensitive   = false
}

output "rds_engine_version" {
  description = "RDS engine version"
  value       = module.rds.db_instance_engine_version
  sensitive   = false
}

output "rds_instance_class" {
  description = "RDS instance class"
  value       = module.rds.db_instance_class
  sensitive   = false
}

output "rds_allocated_storage" {
  description = "RDS allocated storage"
  value       = module.rds.db_instance_allocated_storage
  sensitive   = false
}

output "rds_availability_zone" {
  description = "RDS instance availability zone"
  value       = module.rds.db_instance_availability_zone
  sensitive   = false
}

output "rds_backup_retention_period" {
  description = "RDS backup retention period"
  value       = module.rds.db_instance_backup_retention_period
  sensitive   = false
}

output "rds_publicly_accessible" {
  description = "RDS publicly accessible"
  value       = module.rds.db_instance_publicly_accessible
  sensitive   = false
}

# ==============================================================================
# SECURITY GROUP OUTPUTS
# ==============================================================================

output "rds_security_group_id" {
  description = "ID of the RDS security group"
  value       = aws_security_group.rds_sg.id
  sensitive   = false
}

output "rds_security_group_name" {
  description = "Name of the RDS security group"
  value       = aws_security_group.rds_sg.name
  sensitive   = false
}

# ==============================================================================
# SUBNET GROUP OUTPUTS
# ==============================================================================

output "rds_subnet_group_name" {
  description = "RDS subnet group name"
  value       = aws_db_subnet_group.rds_subnet_group.name
  sensitive   = false
}

output "rds_subnet_group_subnets" {
  description = "RDS subnet group subnets"
  value       = aws_db_subnet_group.rds_subnet_group.subnet_ids
  sensitive   = false
}

# ==============================================================================
# VPC INFORMATION OUTPUTS
# ==============================================================================

output "vpc_id" {
  description = "VPC ID where RDS is deployed"
  value       = data.aws_vpc.existing.id
  sensitive   = false
}

output "vpc_cidr_block" {
  description = "VPC CIDR block"
  value       = data.aws_vpc.existing.cidr_block
  sensitive   = false
}

output "available_subnets" {
  description = "Available subnets in the VPC"
  value       = data.aws_subnets.existing.ids
  sensitive   = false
}

# ==============================================================================
# CONNECTION STRING OUTPUT
# ==============================================================================

output "connection_string" {
  description = "PostgreSQL connection string (without password)"
  value       = "postgresql://${module.rds.db_instance_username}:<PASSWORD>@${module.rds.db_instance_endpoint}/${module.rds.db_instance_name}"
  sensitive   = false
}

output "connection_info" {
  description = "Complete connection information for applications"
  value = {
    host     = split(":", module.rds.db_instance_endpoint)[0]
    port     = module.rds.db_instance_port
    database = module.rds.db_instance_name
    username = module.rds.db_instance_username
    ssl_mode = "require"
  }
  sensitive = false
}

# ==============================================================================
# COST INFORMATION
# ==============================================================================

output "estimated_monthly_cost" {
  description = "Estimated monthly cost information"
  value = {
    instance_type = module.rds.db_instance_class
    storage_gb    = module.rds.db_instance_allocated_storage
    note          = "Estimated cost: ~$15-25/month for db.t4g.micro with 20GB storage"
  }
  sensitive = false
}