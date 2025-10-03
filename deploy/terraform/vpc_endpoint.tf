# VPC Endpoint para comunicação privada entre EKS e RDS
resource "aws_vpc_endpoint" "rds" {
  vpc_id              = data.aws_vpc.existing.id
  service_name        = "com.amazonaws.${var.aws_region}.rds"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = data.aws_subnets.private_subnets.ids
  security_group_ids  = [aws_security_group.vpc_endpoint_sg.id]
  
  private_dns_enabled = true
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = [
          "rds:*"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-rds-vpc-endpoint"
  }
}

# Security Group para o VPC Endpoint
resource "aws_security_group" "vpc_endpoint_sg" {
  name_prefix = "${var.project_name}-vpc-endpoint-sg"
  description = "Security group for RDS VPC Endpoint"
  vpc_id      = data.aws_vpc.existing.id

  ingress {
    description = "HTTPS from EKS and VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.existing.cidr_block]
  }

  ingress {
    description = "PostgreSQL from EKS and VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.existing.cidr_block]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-vpc-endpoint-sg"
  }
}

# Outputs do VPC Endpoint
output "vpc_endpoint_id" {
  description = "ID do VPC Endpoint para RDS"
  value       = aws_vpc_endpoint.rds.id
}

output "vpc_endpoint_dns_names" {
  description = "DNS names do VPC Endpoint"
  value       = aws_vpc_endpoint.rds.dns_entry[*].dns_name
}