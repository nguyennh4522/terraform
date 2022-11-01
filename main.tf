provider "aws" {
  region = "ap-southeast-1"
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

  sudo docker run --env VALIDATOR_WALLET_PRIVATE_KEY=${var.VALIDATOR_WALLET_PRIVATE_KEY} --name validator -p 80:8080 -d public.ecr.aws/s2v2v1t7/icrosschain/validator:latest
  EOL

  root_block_device {
    volume_size = 20
  }
  tags = {
    Name = "validator"
  }
}

resource "aws_eip" "validator_eip" {
  instance = aws_instance.validator.id
  vpc      = true
}
