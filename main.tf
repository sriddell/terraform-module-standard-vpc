terraform {
  backend "s3" {
  }
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name        = var.service
    CostCenter  = var.costcenter
    Environment = var.environment
    Service     = var.service
    POC         = var.poc
    Group       = var.group
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = var.service
    CostCenter  = var.costcenter
    Environment = var.environment
    Service     = var.service
    POC         = var.poc
    Group       = var.group
  }
}

resource "aws_vpc_endpoint" "private-s3" {
  vpc_id       = aws_vpc.vpc.id
  service_name = "com.amazonaws.${var.aws_region}.s3"
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "vpc_cidr_block" {
  value = var.vpc_cidr_block
}

