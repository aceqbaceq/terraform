terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}


locals {
  vpc_num = "vpc-97f726f2"

}


provider "aws" {
  profile = "default"
  region  = "eu-west-1"
}



// ireland


resource "aws_instance" "test-ire1-1-terraform" {
  ami                         = "ami-0e8dff7e32f8f986f"
  instance_type               = "t3a.small"
  vpc_security_group_ids      = ["sg-023376e6af28fb671"]
  subnet_id                   = "subnet-0c1ae7907d4a4c484"
  associate_public_ip_address = "true"
  key_name                    = "a.krivosheev"

  root_block_device {
    volume_size           = 10
    delete_on_termination = true
  }

  credit_specification {
    cpu_credits = "standard"
  }

  tags = {
    Name = "test-ire1-1-terraform"
  }


}













