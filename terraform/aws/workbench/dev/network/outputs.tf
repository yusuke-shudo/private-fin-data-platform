output "platform_vpc_id" {
  value       = aws_vpc.platform_vpc.id
  description = "platform-vpc id"
}

output "platform_public_subnet_az1_id" {
  value       = aws_subnet.platform_public_subnet_az1.id
  description = "platform-public-subnet-az1 id"
}

output "platform_private_subnet_az1_id" {
  value       = aws_subnet.platform_private_subnet_az1.id
  description = "platform-private-subnet-az1 id"
}

output "platform_private_subnet_az2_id" {
  value       = aws_subnet.platform_private_subnet_az2.id
  description = "platform-private-subnet-az2 id"
}

output "platform_workbench_sg_id" {
  value       = aws_security_group.platform_workbench_sg.id
  description = "platform-workbench-sg id"
}

output "platform_nat_eip_public_ips" {
  value       = { for slot, eip in aws_eip.platform_nat_eip : slot => eip.public_ip }
  description = "platform NAT EIP public IPs by AZ slot"
}

output "platform_nat_instance_ids" {
  value       = { for slot, instance in aws_instance.platform_nat_instance : slot => instance.id }
  description = "active platform NAT instance ids by AZ slot"
}