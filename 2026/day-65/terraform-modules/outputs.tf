output "web_server_ip" {
  description = "Public IP of the web server"
  value       = module.web_server.public_ip
}

output "api_server_ip" {
  description = "Public IP of the API server"
  value       = module.api_server.public_ip
}

output "web_server_id" {
  description = "ID of the web server"
  value       = module.web_server.instance_id
}

output "api_server_id" {
  description = "ID of the API server"
  value       = module.api_server.instance_id
}

output "security_group_id" {
  description = "Web security group ID"
  value       = module.web_sg.sg_id
}
