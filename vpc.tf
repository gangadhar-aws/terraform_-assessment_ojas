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

module "subnets_cidr" {
  source              = "hashicorp/subnets/cidr"
  version             = "1.2.0"
  availability_zone   = var.availability_zone
  vpc_cidr_block      = aws_vpc.main.cidr_block
  number_of_subnets   = 2
  netmask_length      = 24
  }

  # Public Subnet
  resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = module.subnets_cidr.cidr_blocks[0]
  availability_zone = var.availability_zone
  map_public_ip_on_launch = true

  tags = module.label_subnet_public.tags
}

# This subnet is not accessible by the public internet

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = module.subnets_cidr.cidr_blocks[1]
  availability_zone = var.availability_zone
  map_public_ip_on_launch = false
  tags = module.label_subnet_private.tags
}