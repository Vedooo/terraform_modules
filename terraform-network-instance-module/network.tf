resource "aws_vpc" "devops-vpc" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "devops-vpc"
  }
}

resource "aws_subnet" "devops-sbn" {
  vpc_id = "${aws_vpc.devops-vpc.id}"
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "devops-sbn"
  }
}

resource "aws_internet_gateway" "devops-igw" {
  vpc_id = "${aws_vpc.devops-vpc.id}"
}

resource "aws_route_table" "devops-rt" {
  vpc_id = "${aws_vpc.devops-vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.devops-igw.id}"
  }
  tags = {
    Name = "devops-rt"
  }
}

resource "aws_route_table_association" "devops-rtas" {
  subnet_id = "${aws_subnet.devops-sbn.id}"
  route_table_id = "${aws_route_table.devops-rt.id}"
}

resource "aws_security_group" "devops-sg" {
  vpc_id = "${aws_vpc.devops-vpc.id}"
  name = "devops-sg-exp"
  description = "this sg lead to learn something about tf"
  ingress {
    description = "open ssh tunnel for ec2"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP for ec2"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTPS for ec2"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}