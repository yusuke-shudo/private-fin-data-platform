output "workbench_instance_id" {
  value       = aws_instance.workbench.id
  description = "developer workbench EC2 instance id"
}

output "workbench_instance_private_ip" {
  value       = aws_instance.workbench.private_ip
  description = "developer workbench EC2 private ip"
}

output "workbench_instance_name" {
  value       = local.workbench_instance_name
  description = "developer workbench EC2 name"
}