provider "aws" {
  region = "ap-southeast-1"
}

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
  availability_zone       = "ap-southeast-1a"

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

resource "aws_instance" "validator" {
  instance_type          = "t2.small"
  ami                    = "ami-0fbb51b4aa5671449"
  vpc_security_group_ids = [aws_security_group.validator_sg.id]
  subnet_id              = aws_subnet.validator_public_subnet.id
  user_data              = <<-EOL
  #! /bin/bash -xe

  sudo apt update
  sudo apt-get install apt-transport-https ca-certificates curl software-properties-common -y
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  sudo apt update
  sudo apt-get install docker-ce -y
  sleep 3
  sudo docker pull public.ecr.aws/s2v2v1t7/icrosschain/validator:latest
  sleep 10

  sleep 1
  sudo docker run --env VALIDATOR_WALLET_PRIVATE_KEY=${VALIDATOR_WALLET_PRIVATE_KEY} --name validator -p 80:8080 -d public.ecr.aws/s2v2v1t7/icrosschain/validator:latest
  EOL

  root_block_device {
    volume_size = 20
  }
  tags = {
    Name = "validator"
  }
}
