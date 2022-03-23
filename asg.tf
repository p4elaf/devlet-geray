terraform {
  required_providers {
    aws = {
      version = "4.5.0"
    }
  }
}

data "aws_ami" "ami" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}

provider "aws" {
  region  = var.region
  profile = var.aws_profile_name
}

data "aws_availability_zones" "available" {
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = {
    "environment" = var.environment
  }
}

resource "aws_subnet" "subnet1" {
  cidr_block              = var.vpc_subnet1_cidr_block
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = {
    "environment" = var.environment
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    "environment" = var.environment
  }
}

resource "aws_route_table" "rtb" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    "environment" = var.environment
  }
}

resource "aws_route_table_association" "rta-subnet1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.rtb.id
}

resource "aws_security_group" "ssh-sg-ext" {
  name        = "ssh-sg-ext"
  description = "Access to the bastion from the outside world"
  vpc_id      = aws_vpc.vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ssh-sg-ext"
  }
}

resource "aws_security_group_rule" "rule-ssh" {
  from_port         = 22
  cidr_blocks       = [var.ssh_access_ip]
  protocol          = "tcp"
  security_group_id = aws_security_group.ssh-sg-ext.id
  to_port           = 22
  type              = "ingress"
  description       = "ssh_access_external"
}

resource "aws_launch_template" "devlet-geray-asg-templ" {
  name_prefix            = var.environment
  image_id               = data.aws_ami.ami.id
  instance_type          = var.instances_size
  update_default_version = "true"

  user_data = base64encode(
    templatefile("install.sh", {
        proton_user       = var.proton_user,
        proton_password   = var.proton_password
  }))

  key_name               = aws_key_pair.devlet_geray_key.key_name

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.ssh-sg-ext.id]
    subnet_id                   = aws_subnet.subnet1.id
  }

  instance_market_options {
    market_type = "spot"
    spot_options {
      spot_instance_type             = "one-time"
      instance_interruption_behavior = "terminate"
    }
  }
}

resource "aws_autoscaling_group" "devlet-geray-asg" {
  name = "devet-geray"
  desired_capacity = var.asg_capacity
  max_size         = var.asg_capacity
  min_size         = var.asg_capacity
  depends_on       = [aws_security_group.ssh-sg-ext]

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 0
    }
    triggers = ["mixed_instances_policy"]
  }

  launch_template {
    id      = aws_launch_template.devlet-geray-asg-templ.id
    version = "$Latest"
  }
}
