terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.40.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "devops-instance" {
  ami = "ami-0b0dcb5067f052a63"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.devops-sbn.id}"
  vpc_security_group_ids = ["${aws_security_group.devops-sg.id}"]
  key_name = "devopskey"
  user_data = "${file("git-install.sh")}"
  tags = {
    Name = "devops-Instance"
  }
}

