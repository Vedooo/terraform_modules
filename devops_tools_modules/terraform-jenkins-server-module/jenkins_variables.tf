variable "mykey" {}
variable "ami" {
    description = "Amazon Linux 2 AMI"
}
variable "region" {}
variable "instance_type" {}
variable "jenkins_server_secgr" {}
variable "jenkins_server_tag" {}
variable "jenkins_profile" {}
variable "jenkins_role" {}