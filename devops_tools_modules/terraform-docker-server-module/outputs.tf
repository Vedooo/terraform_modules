output "instance_public_ip" {
  value = aws_instance.docker-instance.*.public_ip
}

output "sec_grp_id" {
  value = aws_security_group.docker-sec-gr.id
}

output "instance_id" {
  value = aws_instance.docker-instance.*.id
}