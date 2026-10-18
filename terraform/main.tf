resource "aws_vpc" "ecommerce" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# public subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.ecommerce.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone

  tags = {
    Name = "${var.project_name}-public-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "ecommerce" {
  vpc_id = aws_vpc.ecommerce.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

#Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.ecommerce.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ecommerce.id
  }
  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

# Associate the public subnet with the public route table
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}