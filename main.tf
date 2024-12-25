provider "aws" {
  region = var.region
}

# Variables
variable "region" {
  default     = "ap-south-1"
  description = "AWS region where resources will be created"
}

variable "lambda_repo_name" {
  default     = "lambda-docker-repo"
  description = "Name of the ECR repository for Lambda"
}

variable "lambda_function_name" {
  default     = "game-api"
  description = "Name of the Lambda function"
}

variable "vpc_cidr" {
  default     = "10.0.0.0/16"
  description = "CIDR block for the VPC"
}

variable "public_subnet_cidr" {
  default     = "10.0.1.0/24"
  description = "CIDR block for the public subnet"
}

variable "private_subnet_cidr" {
  default     = "10.0.2.0/24"
  description = "CIDR block for the private subnet"
}

# VPC and Subnets
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "Lambda-VPC"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true
  tags = {
    Name = "Public-Subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidr
  tags = {
    Name = "Private-Subnet"
  }
}

# ECR Repository
resource "aws_ecr_repository" "lambda_repo" {
  name = var.lambda_repo_name
  tags = {
    Name = "Lambda-ECR"
  }
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name               = "lambda_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
  tags = {
    Name = "Lambda Execution Role"
  }
}

# Inline IAM Policy for Lambda Role
resource "aws_iam_role_policy" "lambda_policy" {
  role = aws_iam_role.lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetAuthorizationToken"
        ],
        Resource = aws_ecr_repository.lambda_repo.arn
      }
    ]
  })
}

# Security Group for Lambda
resource "aws_security_group" "lambda_sg" {
  name_prefix = "lambda-sg-"
  vpc_id      = aws_vpc.main.id
  tags = {
    Name = "Lambda-SG"
  }
}

# Lambda Function
resource "aws_lambda_function" "game_function" {
  function_name     = var.lambda_function_name
  image_uri         = "${aws_ecr_repository.lambda_repo.repository_url}:latest"
  package_type      = "Image"
  role              = aws_iam_role.lambda_role.arn

  vpc_config {
    subnet_ids         = [aws_subnet.private.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  tags = {
    Name = "Game Lambda Function"
  }
}

# API Gateway
resource "aws_api_gateway_rest_api" "api_gateway" {
  name = "game-api"
  tags = {
    Name = "Game API Gateway"
  }
}

resource "aws_api_gateway_resource" "list_games" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "list-games"
}

resource "aws_api_gateway_method" "get_list_games" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.list_games.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_list_games_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.list_games.id
  http_method             = aws_api_gateway_method.get_list_games.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.game_function.invoke_arn}/invocations"
}

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  depends_on = [
    aws_api_gateway_method.get_list_games,
    aws_api_gateway_integration.get_list_games_integration
  ]
}

resource "aws_api_gateway_stage" "prod_stage" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  stage_name    = "prod"
}

# API Key
resource "aws_api_gateway_api_key" "api_key" {
  name        = "lambda-api-key"
  description = "API Key for Game API"
  enabled     = true
}

resource "aws_api_gateway_usage_plan" "usage_plan" {
  name = "Game API Usage Plan"
}

resource "aws_api_gateway_usage_plan_key" "usage_plan_key" {
  key_id        = aws_api_gateway_api_key.api_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.usage_plan.id
}

# Outputs
output "api_endpoint" {
  value = "https://${aws_api_gateway_rest_api.api_gateway.id}.execute-api.${var.region}.amazonaws.com/prod/"
}

output "api_key" {
  value     = aws_api_gateway_api_key.api_key.value
  sensitive = true
}