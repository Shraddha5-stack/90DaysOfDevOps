variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "ingress_ports" {
  description = "List of ports allowed for inbound traffic"
  type        = list(number)
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}
