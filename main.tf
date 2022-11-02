provider "aws" {
  region = var.AWS_REGION
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}


resource "aws_instance" "validator" {
  instance_type          = "t2.small"
  ami                    = data.aws_ami.ubuntu.id
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

  validatorAddr=${var.VALIDATOR_ADDR}
  if [[ -z $validatorAddr ]]
  then
    validatorAddr=${random_string.dns.result}
  fi

  sudo docker run -d \
    --env VALIDATOR_WALLET_PRIVATE_KEY=${var.VALIDATOR_WALLET_PRIVATE_KEY} \
    --env VALIDATOR_ADDR=$validatorAddr \
    --name validator \
    -p 80:8080 \
    public.ecr.aws/s2v2v1t7/icrosschain/validator:latest
  EOL

  root_block_device {
    volume_size = 20
  }
  tags = {
    Name = "${var.VALIDATOR_ADDR}"
  }
}

resource "aws_eip" "validator_eip" {
  instance = aws_instance.validator.id
  vpc      = true
}

output "validator_eip_public_dns" {
  value       = aws_eip.validator_eip.public_dns
  description = "The public DNS of validator instance."
}
