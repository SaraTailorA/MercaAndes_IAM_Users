terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# ------------------------------------------------------------------------------
# LISTA DE COMPAÑEROS DE EQUIPO (USUARIOS IAM)
# ------------------------------------------------------------------------------
variable "team_members" {
  type    = list(string)
  default = [
    "developer-api",
    "developer-data",
    "devops-engineer",
    "qa-engineer"
  ]
}

# 1. Crear usuario IAM para cada compañero
resource "aws_iam_user" "team" {
  for_each = toset(var.team_members)
  name     = each.value
}

# 2. Permitir que los usuarios tengan acceso a la Consola de AWS
resource "aws_iam_user_login_profile" "team_login" {
  for_each                = toset(var.team_members)
  user                    = aws_iam_user.team[each.value].name
  password_reset_required = true

  lifecycle {
    ignore_changes = [password_reset_required]
  }
}

# ------------------------------------------------------------------------------
# ROLES IAM DE MÍNIMO PRIVILEGIO (US-03)
# ------------------------------------------------------------------------------

# Rol para APIs (EC2)
resource "aws_iam_role" "api_ec2_role" {
  name = "mercaandes-api-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

# Rol para Batch Node (Spark / Airflow)
resource "aws_iam_role" "batch_node_role" {
  name = "mercaandes-batch-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

# Rol para Streaming Node (Kafka / RabbitMQ)
resource "aws_iam_role" "streaming_node_role" {
  name = "mercaandes-streaming-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

# Rol para CI/CD Pipeline
resource "aws_iam_role" "cicd_pipeline_role" {
  name = "mercaandes-cicd-pipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

# ------------------------------------------------------------------------------
# SALIDAS (Muestra las contraseñas generadas al finalizar)
# ------------------------------------------------------------------------------
output "passwords" {
  value     = { for k, v in aws_iam_user_login_profile.team_login : k => v.password }
  sensitive = true
}
