terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "carlos-tfstate-github-actions"
    key = "ec2-demo/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt = true 
  }
}

provider "aws" {
  region = var.region
}

# Backend S3 y Dynamo DB



# Busca la AMI más reciente de Amazon Linux 2023 (free tier)
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_security_group" "ec2_sg" {
  name        = "github-actions-ec2-sgv2"
  description = "SG creado desde GitHub Actions"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # solo para aprender; luego restringimos
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "github-actions-sg"
  }
}

resource "aws_instance" "demo" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro" # free tier
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  tags = {
    Name      = "github-actions-demo"
    ManagedBy = "GitHubActions"
  }
}