output "linux_public_ip" {
  description = "Public IP of the Linux EC2 instance"
  value       = aws_instance.linux_web.public_ip
}

output "windows_public_ip" {
  description = "Public IP of the Windows EC2 instance"
  value       = aws_instance.windows_web.public_ip
}

output "vpc_id" {
  value = aws_vpc.main.id
}
