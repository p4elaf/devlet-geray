variable "region" {
  default = "us-east-1"
}

variable "aws_profile_name" {
  default = "default"
}

variable "proton_user" {
  default = "XXXXXXXXXX"
}

variable "proton_password" {
  default = "XXXXXXXXXX"
}

variable "ssh_access_ip" {
  default = "0.0.0.0/0"
}

resource "aws_key_pair" "devlet_geray_key" {
  key_name   = "devlet_geray_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCxExepcPDuKxCgWbsTfD+UleiwkpogZ0BAapTuI89/kFs3vUJlV21MxTuzucmv2SWWzqPRLxo2LjNBFfW59rfw7NTldHedFaU8ETqvYDuq8gpSwrM3SFB1LxqhYvys368ZrrTE5eGCoxUXGpWFPywzL3DPGpRTXY/J/skYEjIjnK1IdyxSkSKYPXpmu2Iei/PFAZPaTNmzv+o3iIlNjYysilUQvuuavwWOoB0QPq+jY17noWbRvohIlF/KWs4Ubv5kvhybTlDJoZ+m+fReNaIkvD2AAgT6XL5vk83ISW3bPzGKwY7D6J0gDi76AY7aTcTsFI/pKfZKNb/PzYZzLMGn devlet_geray_ssh"
}


variable "instances_size" {
  default = "t3a.micro"
}

variable "asg_capacity" {
  default = "10"
}

variable "environment" {
  default = "devlet-geray"
}

variable "vpc_cidr_block" {
  default = "192.168.0.0/16"
}

variable "enable_dns_hostnames" {
  default = "true"
}

variable "vpc_subnet1_cidr_block" {
  default = "192.168.0.0/16"
}

variable "map_public_ip_on_launch" {
  default = "true"
}