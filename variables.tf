variable "aws_region" {
}

variable "service" {
}

variable "environment" {
}

variable "costcenter" {
}

variable "group" {
  default = ""
}

variable "poc" {
}

variable "vpc_cidr_block" {
  default = "172.20.0.0/16"
}

variable "az" {
  default = "us-east-1c,us-east-1d"
}

variable "pub_subnet_cidr" {
  default = "172.20.0.0/24,172.20.1.0/24,172.20.2.0/24"
}

variable "priv_subnet_cidr" {
  default = "172.20.3.0/24,172.20.4.0/24,172.20.5.0/24"
}

variable "enable_bastion" {
  default = 0
}

variable "bastion_ami_id" {
  default = "ami-6057e21a"
}

variable "bastion_instance_type" {
  default = "t2.small"
}

variable "key_name" {
}

