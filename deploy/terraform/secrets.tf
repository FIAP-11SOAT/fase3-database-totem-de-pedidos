# AWS Systems Manager Parameter Store para secrets
resource "aws_ssm_parameter" "aws_access_key_id" {
  name        = "/${var.project_name}/github-actions/aws-access-key-id"
  description = "AWS Access Key ID for GitHub Actions"
  type        = "SecureString"
  value       = var.github_aws_access_key_id

  tags = {
    Name        = "${var.project_name}-github-access-key"
    Environment = "ci-cd"
    ManagedBy   = "terraform"
  }
}

resource "aws_ssm_parameter" "aws_secret_access_key" {
  name        = "/${var.project_name}/github-actions/aws-secret-access-key"
  description = "AWS Secret Access Key for GitHub Actions"
  type        = "SecureString"
  value       = var.github_aws_secret_access_key

  tags = {
    Name        = "${var.project_name}-github-secret-key"
    Environment = "ci-cd"
    ManagedBy   = "terraform"
  }
}

# IAM Role para GitHub Actions (usando OIDC)
resource "aws_iam_openid_connect_provider" "github" {
  count = var.enable_github_oidc ? 1 : 0
  
  url = "https://token.actions.githubusercontent.com"
  
  client_id_list = [
    "sts.amazonaws.com"
  ]
  
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1"
  ]

  tags = {
    Name = "${var.project_name}-github-oidc"
  }
}

resource "aws_iam_role" "github_actions" {
  count = var.enable_github_oidc ? 1 : 0
  
  name = "${var.project_name}-github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github[0].arn
        }
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_repository}:*"
          }
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-github-actions-role"
  }
}

resource "aws_iam_role_policy" "github_actions_policy" {
  count = var.enable_github_oidc ? 1 : 0
  
  name = "${var.project_name}-github-actions-policy"
  role = aws_iam_role.github_actions[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          # RDS permissions
          "rds:*",
          
          # VPC permissions
          "ec2:Describe*",
          "ec2:CreateSecurityGroup",
          "ec2:DeleteSecurityGroup",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupEgress",
          "ec2:CreateTags",
          
          # SSM permissions
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath",
          
          # S3 permissions (for Terraform state)
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          
          # DynamoDB permissions (for Terraform state locking)
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ]
        Resource = "*"
      }
    ]
  })
}