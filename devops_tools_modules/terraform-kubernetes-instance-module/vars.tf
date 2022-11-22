variable "key-name" {
  default = "devopskey"
}

variable "instance-ami" {
  default = "ami-08c40ec9ead489470"
}

variable "instance-type" {
  default = "t3a.medium"
}

locals {
  name = "devops"
}