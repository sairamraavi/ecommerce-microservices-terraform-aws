
output "ec2_instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.ecommerce.id
}

output "ec2_public_ip" {
  description = "EC2 public IPv4 address"
  value       = aws_instance.ecommerce.public_ip
}

output "ec2_public_dns" {
  description = "EC2 public DNS hostname"
  value       = aws_instance.ecommerce.public_dns
}

output "frontend_url" {
  description = "Public URL of the ecommerce frontend"
  value       = "http://${aws_instance.ecommerce.public_ip}"
}
