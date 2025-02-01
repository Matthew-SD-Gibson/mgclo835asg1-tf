output "ecr_repository_url" {
  value = aws_ecr_repository.mg13rep.repository_url
}

output "ec2_instance_public_ip" {
  value = aws_instance.ec2.public_ip
}
