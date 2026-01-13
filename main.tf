provider "aws" {
  region     = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "ashed-jenkins"
    key    = "dennis.tfstate"
    region = "us-east-1"
  }
}

# custom vpc
resource "aws_vpc" "demo" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "demo"
  }
}
# create subnet
resource "aws_subnet" "demo_subnet" {
  vpc_id     = aws_vpc.demo.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"

  tags = {
    Name = "demo_subnet"
  }
}

# create internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.demo.id

  tags = {
    Name = "gw"
  }
}

# create route table
resource "aws_route_table" "example" {
  vpc_id = aws_vpc.demo.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "demo_route_table"
  }
}

# route table association
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.demo_subnet.id
  route_table_id = aws_route_table.example.id
}

# create security group
resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.demo.id

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = aws_vpc.demo.cidr_block
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}
resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = aws_vpc.demo.cidr_block
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}
resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = aws_vpc.demo.cidr_block
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
resource "aws_instance" "foo" {
  ami           = "ami-084568db4383264d4" # us-east-1
  instance_type = "t2.micro"
  subnet_id = aws_subnet.demo_subnet.id
  vpc_security_group_ids = [aws_security_group.allow_tls.id]
  availability_zone = "us-east-1a"
  key_name = "devopskeypair"
  count = 5

  tags = {
    Name = "server1"
  }


}
