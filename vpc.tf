resource "aws_vpc" "validator" {
  cidr_block           = "10.123.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "validator"
  }
}

resource "aws_subnet" "validator_public_subnet" {
  vpc_id                  = aws_vpc.validator.id
  cidr_block              = "10.123.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.AWS_REGION}a"

  tags = {
    Name = "validator"
  }
}

resource "aws_internet_gateway" "validator_gateway" {
  vpc_id = aws_vpc.validator.id

  tags = {
    Name = "validator_gateway"
  }
}

resource "aws_route_table" "validator_rt" {
  vpc_id = aws_vpc.validator.id

  tags = {
    Name = "validator_rt"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.validator_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.validator_gateway.id
}

resource "aws_route_table_association" "validator_public_assoc" {
  subnet_id      = aws_subnet.validator_public_subnet.id
  route_table_id = aws_route_table.validator_rt.id
}

resource "aws_security_group" "validator_sg" {
  name        = "validator_sg"
  description = "validator security group"
  vpc_id      = aws_vpc.validator.id

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
