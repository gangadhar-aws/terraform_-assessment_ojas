module "label_vpc" {
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  context    = module.base_label.context
  name       = "vpc"
  attributes = ["main"]
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = module.label_vpc.tags
}

# =========================
# Create your subnets here
# =========================

 # Create public subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "${cidrsubnet(var.vpc_cidr, 4, 0)}"
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true  # Enable auto-assign public IP addresses
  tags = {
    Name ="Public Subnet"
  }
}

# Create private subnet
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "${cidrsubnet(var.vpc_cidr, 4, 1)}"
  availability_zone = var.availability_zone
  tags = {
    Name = "Private Subnet"
  }
}
