output "instance_id" {
  description = "ID of the EC2 instance."
  value       = aws_instance.this.id
}

output "public_ip" {
  description = "Public IPv4 address (empty if the default subnet does not auto-assign public IPs)."
  value       = aws_instance.this.public_ip
}
