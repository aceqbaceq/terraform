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
  vpc_num = "vpc-18ed1e71"

}


provider "aws" {
  profile = "default"
  region  = "eu-central-1"
}


resource "aws_subnet" "elk-eu-1a" {
  vpc_id            = local.vpc_num
  cidr_block        = "172.31.61.0/28"
  availability_zone = "eu-central-1a"

  tags = {
    Name = "sub_elk-eu-1a"
  }
}


resource "aws_subnet" "elk-eu-1b" {
  vpc_id            = local.vpc_num
  cidr_block        = "172.31.62.0/28"
  availability_zone = "eu-central-1b"

  tags = {
    Name = "sub_elk-eu-1b"
  }
}







resource "aws_ebs_volume" "elk" {
  availability_zone = "eu-central-1a"
  size              = 10
  type              = "gp2"
  tags = {
    "Name" = "elk-root_vol"
    "elk"  = "rootvol"
  }


}


resource "aws_volume_attachment" "generic_data_vol_att" {
  device_name = "/dev/xvdf"
  volume_id   = aws_ebs_volume.elk.id
  instance_id = aws_instance.app_server.id
}


resource "aws_security_group" "elk" {
  name        = "elk"
  description = "Allow elk inbound traffic"
  vpc_id      = local.vpc_num

  ingress {
    description = "SSH from bastion"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["172.31.113.15/32"]
  }


  ingress {
    description = "kibana from vpc"
    from_port   = 5601
    to_port     = 5601
    protocol    = "tcp"
    cidr_blocks = ["172.31.0.0/16", "10.10.10.0/24"]
  }




  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}



resource "aws_instance" "app_server" {
  ami                    = "ami-00d5e377dd7fad751"
  instance_type          = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.elk.id}"]
  subnet_id              = aws_subnet.elk-eu-1a.id
  key_name               = "a.krivosheev"

  root_block_device {
    volume_size           = 25
    delete_on_termination = true
  }


  tags = {
    Name = "test-elk-terraform"
  }
}


resource "aws_instance" "elk1-fra1-terraform" {
  ami                         = "ami-00d5e377dd7fad751"
  instance_type               = "t3a.large"
  vpc_security_group_ids      = ["${aws_security_group.elk.id}"]
  subnet_id                   = aws_subnet.elk-eu-1a.id
  associate_public_ip_address = "true"
  key_name                    = "a.krivosheev"

  root_block_device {
    volume_size           = 50
    delete_on_termination = true
  }


  tags = {
    Name = "elk1-fra1-terraform"
  }
}



resource "aws_instance" "elk2-fra2-terraform" {
  ami                         = "ami-00d5e377dd7fad751"
  instance_type               = "t3a.large"
  vpc_security_group_ids      = ["${aws_security_group.elk.id}"]
  subnet_id                   = aws_subnet.elk-eu-1b.id
  associate_public_ip_address = "true"
  key_name                    = "a.krivosheev"

  root_block_device {
    volume_size           = 50
    delete_on_termination = true
  }


  tags = {
    Name = "elk2-fra2-terraform"
  }
}





// kubernetes

resource "aws_subnet" "kub-eu-1a" {
  vpc_id            = local.vpc_num
  cidr_block        = "172.31.63.0/24"
  availability_zone = "eu-central-1a"

  tags = {
    Name = "sub_kub-eu-1a"
  }
}


resource "aws_subnet" "kub-eu-1b" {
  vpc_id            = local.vpc_num
  cidr_block        = "172.31.64.0/24"
  availability_zone = "eu-central-1b"

  tags = {
    Name = "sub_kub-eu-1b"
  }
}


resource "aws_subnet" "kub-eu-1c" {
  vpc_id            = local.vpc_num
  cidr_block        = "172.31.65.0/24"
  availability_zone = "eu-central-1c"

  tags = {
    Name = "sub_kub-eu-1c"
  }
}


resource "aws_security_group" "kub" {
  name        = "kub"
  description = "Allow kub inbound traffic"
  vpc_id      = local.vpc_num

  ingress {
    description = "SSH from bastion"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["172.31.113.15/32"]
  }


  ingress {
    description = "kibana from vpc"
    from_port   = 5601
    to_port     = 5601
    protocol    = "tcp"
    cidr_blocks = ["172.31.0.0/16", "10.10.10.0/24"]
  }




  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "kubernetes"
  }
}



variable "instance_count" {
  default = "3"
}




resource "aws_instance" "kub-fra1-terraform" {
  count                       = var.instance_count
  ami                         = "ami-00d5e377dd7fad751"
  instance_type               = "t3a.large"
  vpc_security_group_ids      = ["${aws_security_group.kub.id}"]
  subnet_id                   = aws_subnet.kub-eu-1a.id
  associate_public_ip_address = "true"
  key_name                    = "a.krivosheev"

  root_block_device {
    volume_size           = 50
    delete_on_termination = true
  }

  credit_specification {
    cpu_credits = "standard"
  }

  tags = {
    Name = "kub-fra1-${count.index + 1}-terraform"
  }


}












