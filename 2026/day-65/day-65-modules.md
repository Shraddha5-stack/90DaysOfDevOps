# Day 65 — Terraform Modules

## Overview

Today I learned and practiced Terraform Modules.

The main goal was to understand how Terraform modules help organize infrastructure code into reusable, maintainable, and scalable components.

In this practical exercise, I:

- Created a custom EC2 module
- Created a custom Security Group module
- Reused the EC2 module for multiple servers
- Used input variables and outputs
- Used the official Terraform Registry VPC module
- Migrated existing Terraform resources into a module
- Practiced `terraform state mv`
- Practiced `terraform import`
- Used module version constraints
- Verified the infrastructure using `terraform plan`
- Successfully migrated existing infrastructure without destroying it

---

# 1. What is a Terraform Module?

A Terraform module is a collection of Terraform configuration files that are grouped together to create reusable infrastructure components.

Instead of writing the same resource configuration repeatedly, we can create a module once and reuse it multiple times.

For example, instead of writing separate EC2 resources:

```hcl
resource "aws_instance" "web" {
  ...
}

resource "aws_instance" "api" {
  ...
}
````

we can create one reusable EC2 module:

```text
modules/
└── ec2-instance/
```

and call it multiple times:

```hcl
module "web_server" {
  source = "./modules/ec2-instance"
  ...
}

module "api_server" {
  source = "./modules/ec2-instance"
  ...
}
```

This makes Terraform code easier to maintain and reuse.

---

# 2. Root Module vs Child Module

## Root Module

The root module is the main Terraform configuration directory where Terraform commands are executed.

In this project:

```text
terraform-modules/
├── main.tf
├── variables.tf
├── outputs.tf
├── providers.tf
└── modules/
```

The root module calls child modules.

## Child Module

A child module is a reusable Terraform configuration located inside another directory or obtained from a Terraform Registry.

In this project:

```text
modules/
├── ec2-instance/
└── security-group/
```

These are custom child modules.

The project also uses the official Terraform Registry VPC module.

---

# 3. Module Directory Structure

The Day 65 project uses the following structure:

```text
terraform-modules/
│
├── main.tf
├── variables.tf
├── outputs.tf
├── providers.tf
│
└── modules/
    │
    ├── ec2-instance/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    └── security-group/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

The three common files inside a module are:

### `main.tf`

Contains the resources created by the module.

### `variables.tf`

Defines the inputs accepted by the module.

### `outputs.tf`

Defines the values returned by the module.

---

# 4. Why Use Terraform Modules?

Terraform modules provide several benefits:

* Code reusability
* Better organization
* Easier maintenance
* Consistent infrastructure
* Reduced duplication
* Easier scaling
* Separation of responsibilities
* Standardized infrastructure patterns

For example, the same EC2 module can be used to create:

```text
Web Server
API Server
Application Server
Monitoring Server
```

without duplicating the complete EC2 resource configuration.

---

# 5. Module Inputs

Modules receive values through variables.

Example:

```hcl
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}
```

The root module can provide a value:

```hcl
module "web_server" {
  source        = "./modules/ec2-instance"
  instance_type = "t3.micro"
}
```

The module accesses the value using:

```hcl
var.instance_type
```

This makes the module configurable and reusable.

---

# 6. Custom EC2 Module

I created a reusable EC2 module at:

```text
modules/ec2-instance/
├── main.tf
├── variables.tf
└── outputs.tf
```

## EC2 Module Variables

```hcl
variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "subnet_id" {
  description = "Subnet ID where the instance will be deployed"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
}

variable "tags" {
  description = "Additional tags for the EC2 instance"
  type        = map(string)
  default     = {}
}
```

These variables make the EC2 module reusable.

The module does not hard-code:

* AMI ID
* Instance type
* Subnet ID
* Security Group ID
* Instance name

These values are provided by the root module.

---

# 7. EC2 Module Resource

The EC2 module creates an AWS EC2 instance:

```hcl
resource "aws_instance" "this" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids

  tags = merge(var.tags, {
    Name = var.instance_name
  })
}
```

The module receives values through variables and uses them to create the EC2 instance.

---

# 8. EC2 Module Outputs

The module exposes useful information using outputs:

```hcl
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.this.id
}

output "public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.this.public_ip
}

output "private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.this.private_ip
}
```

The root module can access these values using:

```hcl
module.web_server.instance_id
```

or:

```hcl
module.web_server.public_ip
```

---

# 9. Reusing the EC2 Module

One of the most important concepts practiced today was module reuse.

I used the same EC2 module twice.

## Web Server

```hcl
module "web_server" {
  source             = "./modules/ec2-instance"
  ami_id             = data.aws_ami.amazon_linux.id
  instance_type      = "t3.micro"
  subnet_id          = module.vpc.public_subnets[0]
  security_group_ids = [module.web_sg.sg_id]
  instance_name      = "terraweek-web"
  tags               = local.common_tags
}
```

## API Server

```hcl
module "api_server" {
  source             = "./modules/ec2-instance"
  ami_id             = data.aws_ami.amazon_linux.id
  instance_type      = "t3.micro"
  subnet_id          = module.vpc.public_subnets[0]
  security_group_ids = [module.web_sg.sg_id]
  instance_name      = "terraweek-api"
  tags               = local.common_tags
}
```

Both servers use the same reusable EC2 module.

Only the values that are different are passed as variables.

---

# 10. Why Module Reuse is Important

Without modules, infrastructure code can become repetitive.

For example:

```text
EC2 configuration
EC2 configuration
EC2 configuration
EC2 configuration
```

With modules:

```text
                 EC2 Module
                     |
          +----------+----------+
          |          |          |
        Web         API      Application
       Server      Server       Server
```

One module can therefore provide a standardized pattern for many resources.

---

# 11. Custom Security Group Module

I also created a reusable Security Group module:

```text
modules/security-group/
├── main.tf
├── variables.tf
└── outputs.tf
```

The Security Group module accepts:

* VPC ID
* Security Group name
* Ingress ports
* Additional tags

---

# 12. Security Group Module Variables

```hcl
variable "vpc_id" {
  description = "VPC ID where the security group will be created"
  type        = string
}

variable "sg_name" {
  description = "Name of the security group"
  type        = string
}

variable "ingress_ports" {
  description = "List of TCP ports to allow"
  type        = list(number)
  default     = [22, 80]
}

variable "tags" {
  description = "Additional tags for the security group"
  type        = map(string)
  default     = {}
}
```

The module can therefore be reused with different VPCs, names and ports.

---

# 13. Security Group Resource

The Security Group module uses a dynamic block to create ingress rules:

```hcl
resource "aws_security_group" "this" {
  name        = var.sg_name
  description = "Security group managed by Terraform module"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_ports

    content {
      description = "Allow TCP port ${ingress.value}"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = var.sg_name
  })
}
```

For this project, the Security Group allows:

```text
22  -> SSH
80  -> HTTP
443 -> HTTPS
```

---

# 14. Security Group Output

The module returns the Security Group ID:

```hcl
output "sg_id" {
  description = "ID of the security group"
  value       = aws_security_group.this.id
}
```

The root module can use:

```hcl
module.web_sg.sg_id
```

This output is then passed to the EC2 module.

---

# 15. Module Dependency

The EC2 module depends on the Security Group module.

The dependency is created through this reference:

```hcl
security_group_ids = [module.web_sg.sg_id]
```

Terraform understands that the Security Group must exist before the EC2 instance can use its ID.

This is an example of an implicit dependency.

---

# 16. Terraform Registry Modules

Terraform also provides a public registry containing reusable modules.

Instead of creating the complete VPC configuration manually, I used the official AWS VPC module:

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "terraweek-vpc"
  cidr = "10.0.0.0/16"

  azs = [
    "ap-south-1a",
    "ap-south-1b"
  ]

  public_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]

  private_subnets = [
    "10.0.3.0/24",
    "10.0.4.0/24"
  ]

  enable_nat_gateway   = false
  enable_dns_hostnames = true

  tags = local.common_tags
}
```

This module provides a standardized way to create VPC infrastructure.

---

# 17. Terraform Module Versioning

The VPC module uses:

```hcl
version = "~> 5.0"
```

The `~>` operator is called the pessimistic constraint operator.

Examples:

```text
~> 5.0
>= 5.0
= 5.0.0
```

### `~> 5.0`

Allows compatible versions in the 5.x range according to Terraform's version constraint rules.

### `>= 5.0`

Allows version 5.0 or newer, subject to other constraints.

### `= 5.0.0`

Requires exactly version 5.0.0.

Using version constraints helps make infrastructure deployments more predictable.

---

# 18. Terraform Module Initialization

When a new module is added, Terraform needs to download it.

The command used is:

```bash
terraform init
```

Terraform downloaded the VPC module:

```text
terraform-aws-modules/vpc/aws
```

The selected version was:

```text
5.21.0
```

because the configuration used:

```hcl
version = "~> 5.0"
```

---

# 19. Migrating Existing Resources into a Module

An important practical lesson from Day 65 was migrating existing infrastructure from hand-written resources to a module.

Initially, the VPC was created using individual resources such as:

```hcl
resource "aws_vpc" "main" {
  ...
}
```

Later, it was replaced by:

```hcl
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  ...
}
```

Terraform does not automatically know that the existing VPC and the module VPC represent the same physical resource.

Without state migration, Terraform could plan to:

```text
Destroy old VPC
Create new VPC
```

This would be dangerous for existing infrastructure.

---

# 20. Using `terraform state mv`

To preserve the existing infrastructure, I used:

```bash
terraform state mv
```

For example:

```bash
terraform state mv aws_vpc.main \
  'module.vpc.aws_vpc.this[0]'
```

This changed the Terraform state address without destroying the physical VPC.

Other resources were migrated in the same way:

```bash
terraform state mv aws_internet_gateway.main \
  'module.vpc.aws_internet_gateway.this[0]'
```

```bash
terraform state mv aws_subnet.public \
  'module.vpc.aws_subnet.public[0]'
```

```bash
terraform state mv aws_route_table.public \
  'module.vpc.aws_route_table.public[0]'
```

```bash
terraform state mv aws_route_table_association.public \
  'module.vpc.aws_route_table_association.public[0]'
```

The important concept is:

```text
terraform state mv
        |
        v
Changes Terraform state address
        |
        v
Does NOT recreate the physical resource
```

---

# 21. Using `terraform import`

After migrating the route table, the VPC module expected an internet route that already existed in AWS.

Terraform attempted to create:

```text
0.0.0.0/0
```

but AWS returned:

```text
RouteAlreadyExists
```

The existing route was therefore imported:

```bash
terraform import \
  'module.vpc.aws_route.public_internet_gateway[0]' \
  'rtb-06ecf187d6edb1c17_0.0.0.0/0'
```

The import was successful.

The important lesson is:

```text
Existing AWS resource
        |
        v
terraform import
        |
        v
Terraform state
        |
        v
Terraform manages existing resource
```

---

# 22. State Migration Result

After the migration, the Terraform state contained resources under the module addresses:

```text
module.vpc.aws_vpc.this[0]
module.vpc.aws_internet_gateway.this[0]
module.vpc.aws_route.public_internet_gateway[0]
module.vpc.aws_route_table.public[0]
module.vpc.aws_subnet.public[0]
module.vpc.aws_subnet.public[1]
module.vpc.aws_subnet.private[0]
module.vpc.aws_subnet.private[1]

module.web_sg.aws_security_group.this

module.web_server.aws_instance.this
module.api_server.aws_instance.this
```

---

# 23. Final Terraform State Verification

The final command used was:

```bash
terraform state list
```

The state contained:

```text
data.aws_ami.amazon_linux

module.api_server.aws_instance.this

module.vpc.aws_default_network_acl.this[0]
module.vpc.aws_default_route_table.default[0]
module.vpc.aws_default_security_group.this[0]
module.vpc.aws_internet_gateway.this[0]
module.vpc.aws_route.public_internet_gateway[0]

module.vpc.aws_route_table.private[0]
module.vpc.aws_route_table.private[1]
module.vpc.aws_route_table.public[0]

module.vpc.aws_route_table_association.private[0]
module.vpc.aws_route_table_association.private[1]
module.vpc.aws_route_table_association.public[0]
module.vpc.aws_route_table_association.public[1]

module.vpc.aws_subnet.private[0]
module.vpc.aws_subnet.private[1]
module.vpc.aws_subnet.public[0]
module.vpc.aws_subnet.public[1]

module.vpc.aws_vpc.this[0]

module.web_server.aws_instance.this
module.web_sg.aws_security_group.this
```

---

# 24. Terraform Plan Verification

After the migration, I ran:

```bash
terraform plan
```

Terraform returned:

```text
No changes. Your infrastructure matches the configuration.
```

This confirmed that:

* Terraform configuration matches AWS
* Terraform state matches the configuration
* Existing infrastructure was preserved
* No resources needed to be destroyed
* Module migration was successful

---

# 25. Final Architecture

```text
                         Terraform Root Module
                                  |
             +--------------------+--------------------+
             |                    |                    |
             v                    v                    v
       Registry VPC        Security Group        EC2 Module
          Module                Module                |
             |                    |             +------+------+
             |                    |             |             |
             |                    +-----------> Web          API
             |                                  EC2          EC2
             |
      +------+------+
      |             |
   Public         Private
   Subnets        Subnets
      |
   Internet
   Gateway
```

---

# 26. Infrastructure Created

The final infrastructure includes:

```text
VPC
|
+-- Internet Gateway
|
+-- Public Subnet 1
|     |
|     +-- Web EC2
|     +-- API EC2
|
+-- Public Subnet 2
|
+-- Private Subnet 1
|
+-- Private Subnet 2
|
+-- Public Route Table
|
+-- Private Route Tables
|
+-- Default Network ACL
|
+-- Default Route Table
|
+-- Default Security Group
|
+-- Custom Web Security Group
```

The Web and API servers use:

```text
Instance Type: t3.micro
```

---

# 27. Important Terraform Commands Practiced

## Initialize Terraform

```bash
terraform init
```

## Validate configuration

```bash
terraform validate
```

## Create execution plan

```bash
terraform plan
```

## Apply infrastructure

```bash
terraform apply
```

## View state

```bash
terraform state list
```

## Move state resource

```bash
terraform state mv SOURCE DESTINATION
```

## Import existing resource

```bash
terraform import ADDRESS ID
```

## Destroy infrastructure

```bash
terraform destroy
```

---

# 28. Best Practices Learned

### 1. Use modules for reusable infrastructure

Create modules for components that are repeated or logically grouped.

### 2. Keep modules configurable

Use variables instead of hard-coded values.

### 3. Expose useful outputs

Return IDs, IP addresses and other important information through outputs.

### 4. Pin module versions

Use version constraints for predictable deployments.

Example:

```hcl
version = "~> 5.0"
```

### 5. Use meaningful module names

Examples:

```text
web_server
api_server
web_sg
vpc
```

### 6. Use common tags

Example:

```hcl
locals {
  common_tags = {
    Project     = "Terraform Modules"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
```

### 7. Review plans before applying

Always inspect:

```bash
terraform plan
```

before:

```bash
terraform apply
```

### 8. Be careful when changing resource addresses

Changing a resource into a module can cause Terraform to think the resource was removed.

Use state migration techniques when the physical resource already exists.

---

# 29. Important Lesson from the Migration

One of the biggest lessons from Day 65 was that Terraform state is extremely important.

Terraform tracks resources using addresses.

For example:

```text
aws_vpc.main
```

and:

```text
module.vpc.aws_vpc.this[0]
```

are different Terraform addresses even if they refer to the same physical AWS VPC.

Therefore, when moving resources into modules, the Terraform state may need to be migrated.

The correct approach is:

```text
Existing Resource
       |
       v
Review Terraform State
       |
       v
terraform state mv
       |
       v
terraform import (when necessary)
       |
       v
terraform plan
       |
       v
No unexpected destruction
```

---

# 30. Interview Questions

## Q1. What is a Terraform module?

A Terraform module is a collection of Terraform configuration files used to create reusable infrastructure components.

## Q2. What is the difference between a root module and child module?

The root module is the main configuration from which Terraform commands are executed. A child module is a reusable module called by the root module or another module.

## Q3. Why are modules used?

Modules improve reusability, maintainability, organization and consistency.

## Q4. What are the common files in a Terraform module?

The common files are:

```text
main.tf
variables.tf
outputs.tf
```

## Q5. How do you pass values to a module?

Using module arguments:

```hcl
module "web_server" {
  source        = "./modules/ec2-instance"
  instance_type = "t3.micro"
}
```

## Q6. How does a module return values?

Using outputs:

```hcl
output "instance_id" {
  value = aws_instance.this.id
}
```

## Q7. Can one module be used multiple times?

Yes.

For example:

```hcl
module "web_server" {
  source = "./modules/ec2-instance"
}

module "api_server" {
  source = "./modules/ec2-instance"
}
```

## Q8. What is the Terraform Registry?

The Terraform Registry is a public repository of Terraform providers and reusable modules.

## Q9. Why should module versions be specified?

Version constraints help prevent unexpected module changes and make deployments more predictable.

## Q10. What does `terraform state mv` do?

It changes the address of a resource in Terraform state without destroying the physical infrastructure.

## Q11. What does `terraform import` do?

It adds an existing infrastructure resource to Terraform state so Terraform can manage it.

## Q12. Why was `terraform import` needed during this project?

The VPC module expected an internet route that already existed in AWS. Importing it prevented Terraform from attempting to create a duplicate route.

## Q13. What should you check before applying a module migration?

Run:

```bash
terraform plan
```

and carefully check for unexpected resource destruction or replacement.

---

# 31. Key Takeaways

Today's biggest takeaways:

1. Terraform modules make infrastructure reusable.
2. Variables make modules configurable.
3. Outputs allow modules to expose important resource information.
4. One module can be reused multiple times.
5. Terraform Registry provides reusable community and official modules.
6. Module versions should be constrained.
7. Terraform state addresses are important.
8. `terraform state mv` can migrate an existing resource to a new state address.
9. `terraform import` can bring an existing AWS resource under Terraform management.
10. Always review `terraform plan` before applying infrastructure changes.

The most important lesson:

> **Modules improve reusability, while Terraform state migration helps safely move existing infrastructure into a new module structure without unnecessary destruction.**

---

# 32. Final Verification

Commands used for final verification:

```bash
terraform validate
```

```bash
terraform plan
```

```bash
terraform state list
```

Final result:

```text
No changes. Your infrastructure matches the configuration.
```

Day 65 completed successfully. 🚀

---

## Technologies Practiced

```text
Terraform
AWS
Terraform Modules
Terraform Registry
EC2
VPC
Security Groups
Subnets
Route Tables
Internet Gateway
Terraform State
terraform state mv
terraform import
Terraform Version Constraints
Infrastructure as Code
```

---

## Day 65 Status

**Status: Completed ✅**

**Main Topic:** Terraform Modules

**AWS Region:** `ap-south-1`

**Terraform Version:** `1.16.0`

**EC2 Instance Type:** `t3.micro`

**Registry VPC Module:** `terraform-aws-modules/vpc/aws`

**Final Terraform Plan:** No changes

