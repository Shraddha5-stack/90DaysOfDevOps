output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "subnet_id" {
  description = "ID of the public subnet"
  value       = module.vpc.subnet_id
}

output "security_group_id" {
  description = "ID of the security group"
  value       = module.security_group.sg_id
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = module.ec2_instance.instance_id
}

output "public_ip" {
  description = "Public IP of the EC2 instance"
  value       = module.ec2_instance.public_ip
}
