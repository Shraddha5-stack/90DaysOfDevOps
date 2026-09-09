variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "terraweek"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "ingress_ports" {
  description = "List of ports allowed for inbound traffic"
  type        = list(number)
  default     = [22, 80]
}
