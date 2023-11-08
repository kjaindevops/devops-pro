data "aws_ami" "demo-ami" {
  most_recent = "true"

  filter {
    name   = "name"
    values = ["al2023-ami-*.1-kernel-6.1-x86_64"]
  }
}

resource "aws_security_group" "ssh-allow" {
  name        = "ssh-allow"
  description = "Allowing SSH to the server."

  ingress {
    description = "Allowing SSH access from Macbook"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    name = "ssh-allow"
  }
}


resource "aws_instance" "demo-server" {
  ami             = data.aws_ami.demo-ami.id
  key_name        = "DevOps-Mac-kp"
  security_groups = ["ssh-allow"]
  instance_type   = "t2.micro"
}