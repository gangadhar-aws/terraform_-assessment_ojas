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

# Create internet gateway
resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.main.id
  tags = module.label_vpc.tags
}


 # Create public subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "${cidrsubnet(var.vpc_cidr, 4, 0)}"
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true   
  tags = module.label_vpc.tags
}

# Create private subnet
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "${cidrsubnet(var.vpc_cidr, 4, 1)}"
  availability_zone = var.availability_zone
  tags = module.label_vpc.tags
}

# Create route table for public subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = module.label_vpc.tags

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example.id
  }
}

# Associate public subnet with public route table
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}


# Create route table for private subnet
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags = module.label_vpc.tags
}

# Associate private subnet with private route table
resource "aws_route_table_association" "private_subnet_association" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}
