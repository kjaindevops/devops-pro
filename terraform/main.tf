data "aws_ami" "demo-ami" {
  most_recent = "true"

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_vpc" "client-vpc" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "client-vpc"
  }
}

resource "aws_subnet" "client-pubsub-01" {
  vpc_id                  = aws_vpc.client-vpc.id
  cidr_block              = "10.1.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "client-pubsub-01"
  }
}

resource "aws_subnet" "client-pubsub-02" {
  vpc_id                  = aws_vpc.client-vpc.id
  cidr_block              = "10.1.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "client-pubsub-02"
  }
}

resource "aws_internet_gateway" "client-igw" {
  vpc_id = aws_vpc.client-vpc.id
  tags = {
    Name = "client-igw"
  }
}

resource "aws_route_table" "client-pub-rt" {
  vpc_id = aws_vpc.client-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.client-igw.id
  }

  tags = {
    Name = "client-pub-rt"
  }
}

resource "aws_route_table_association" "client-pub-rta1" {
  subnet_id      = aws_subnet.client-pubsub-01.id
  route_table_id = aws_route_table.client-pub-rt.id

}

resource "aws_route_table_association" "client-pub-rta2" {
  subnet_id      = aws_subnet.client-pubsub-02.id
  route_table_id = aws_route_table.client-pub-rt.id
}

resource "aws_security_group" "ssh-allow" {
  name        = "ssh-allow"
  description = "Allowing SSH to the server."
  vpc_id      = aws_vpc.client-vpc.id

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
  ami                    = data.aws_ami.demo-ami.id
  key_name               = "DevOps-Mac-kp"
  vpc_security_group_ids = [aws_security_group.ssh-allow.id]
  instance_type          = "t2.micro"
}