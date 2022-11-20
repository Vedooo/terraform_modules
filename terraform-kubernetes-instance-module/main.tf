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

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "template_file" "worker" {
  template = file("worker.sh")
  vars = {
    region = data.aws_region.current.name
    master-id = aws_instance.master.id
    master-private = aws_instance.master.private_ip
  }
}

data "template_file" "master" {
  template = file("master.sh")
}

resource "aws_instance" "master" {
  ami = "${var.instance-ami}"
  instance_type = "${var.instance-type}"
  key_name = "${var.key-name}"
  iam_instance_profile = "${aws_iam_instance_profile.ec2-connect-profile.name}"
  vpc_security_group_ids = ["${aws_security_group.k8s-sec-gr.id}"]
  user_data = data.template_file.master.rendered
  tags = {
    Name = "${local.name}-kube-master"
  }
}

resource "aws_instance" "worker" {
  ami = "${var.instance-ami}"
  instance_type = "${var.instance-type}"
  key_name = "${var.key-name}"
  iam_instance_profile = "${aws_iam_instance_profile.ec2-connect-profile.name}"
  vpc_security_group_ids = ["${aws_security_group.k8s-sec-gr.id}"]
  user_data = data.template_file.worker.rendered
  tags = {
    Name = "${local.name}-kube-worker"
  }
  depends_on = [aws_instance.master]
}

output "master_public_dns" {
  value = aws_instance.master.public_dns
}

output "master_private_dns" {
  value = aws_instance.master.private_dns
}

output "worker_public_dns" {
  value = aws_instance.worker.public_dns
}

output "worker_private_dns" {
  value = aws_instance.worker.private_dns
}