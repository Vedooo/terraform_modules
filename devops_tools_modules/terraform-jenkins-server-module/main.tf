terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
}

resource "aws_instance" "jenkins-server" {
  ami = var.ami
  instance_type = var.instance_type
  key_name = var.mykey
  vpc_security_group_ids = [aws_security_group.jenkins-security-group.id]
  iam_instance_profile = aws_iam_instance_profile.jenkins-server-profile.name
  ebs_block_device {
    device_name = "/dev/xvda"
    volume_type = "gp2"
    volume_size = 16
  }
  tags = {
    Name = var.jenkins_server_tag
    server = "Jenkins"
  }
  user_data = file("jenkinsdata.sh")
}

resource "aws_security_group" "jenkins-security-group" {
  name = var.jenkins_server_secgr
  tags = {
    Name = var.jenkins_server_secgr
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks= ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "jenkins-server-role" {
  name = var.jenkins_role
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess", "arn:aws:iam::aws:policy/AWSCloudFormationFullAccess", "arn:aws:iam::aws:policy/AdministratorAccess"]
}

resource "aws_iam_instance_profile" "jenkins-server-profile" {
  name = var.jenkins_profile
  role = aws_iam_role.jenkins-server-role.name
}

output "JenkinsDNS" {
  value = aws_instance.jenkins-server.public_dns
}

output "JenkinsURL" {
  value = "http://${aws_instance.jenkins-server.public_dns}:8080"
}