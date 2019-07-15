resource "aws_security_group" "ssh" {
  count       = var.enable_bastion
  name        = "ssh"
  description = "allow ssh"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["149.24.0.0/16"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "ssh"
    CostCenter  = var.costcenter
    Environment = var.environment
    Service     = var.service
    POC         = var.poc
    Group       = var.group
  }
}

resource "aws_instance" "bastion_host" {
  count                       = var.enable_bastion
  ami                         = var.bastion_ami_id
  instance_type               = var.bastion_instance_type
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.ssh[0].id]
  associate_public_ip_address = true
  subnet_id                   = element(aws_subnet.public.*.id, 0)

  tags = {
    Name        = "${var.service}-bastion"
    CostCenter  = var.costcenter
    Environment = var.environment
    Service     = var.service
    POC         = var.poc
    Group       = var.group
  }
}

output "bastion_host" {
  value = aws_instance.bastion_host.*.public_dns
}

output "bastion_ip" {
  value = aws_instance.bastion_host.*.public_ip
}

