# Day 62 — Providers, Resources and Dependencies

## 📌 Overview

Today I learned how Terraform works with AWS providers, resources, implicit dependencies, explicit dependencies, dependency graphs, and lifecycle rules.

I built an AWS infrastructure from scratch using Terraform:

* VPC
* Public Subnet
* Internet Gateway
* Route Table
* Route Table Association
* Security Group
* EC2 Instance
* S3 Bucket

I also used `terraform graph` to visualize resource dependencies and tested the `create_before_destroy` lifecycle rule by changing the EC2 AMI.

---

## 🎯 Objectives

* Understand Terraform providers
* Understand provider version constraints
* Configure the AWS provider
* Create an AWS VPC using Terraform
* Create a public subnet
* Create an Internet Gateway
* Create a route table
* Associate the route table with the subnet
* Understand implicit dependencies
* Create a Security Group
* Create an EC2 instance
* Understand explicit dependencies using `depends_on`
* Create an S3 bucket with an explicit dependency
* Generate a Terraform dependency graph
* Understand Terraform lifecycle rules
* Test `create_before_destroy`
* Destroy all infrastructure safely

---

# 1. Terraform Provider

Terraform uses providers to communicate with external platforms and services.

For this project, I used the AWS provider.

The provider configuration was stored in `providers.tf`.

## `providers.tf`

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.6.0"
}

provider "aws" {
  region = "ap-south-1"
}
```

### Explanation

### `required_providers`

Defines which Terraform providers the project requires.

```hcl
required_providers {
  aws = {
    source  = "hashicorp/aws"
    version = "~> 5.0"
  }
}
```

The AWS provider comes from:

```text
hashicorp/aws
```

### Provider version

```hcl
version = "~> 5.0"
```

This allows compatible versions in the 5.x series while preventing Terraform from automatically moving to version 6.x.

### Terraform version

```hcl
required_version = ">= 1.6.0"
```

This means Terraform 1.6.0 or newer is required.

### AWS region

```hcl
region = "ap-south-1"
```

All AWS resources in this project were created in the Mumbai region.

---

# 2. Terraform Initialization

I initialized the Terraform project using:

```bash
terraform init
```

Terraform downloaded the AWS provider and created the provider lock file:

```text
.terraform.lock.hcl
```

The lock file records the selected provider version and checksums.

It should normally be committed to Git.

The `.terraform` directory should not be committed.

---

# 3. Build the VPC

The first resource created was the VPC.

```hcl
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "TerraWeek-VPC"
  }
}
```

### What this creates

A VPC with CIDR:

```text
10.0.0.0/16
```

The resource name inside Terraform is:

```text
aws_vpc.main
```

---

# 4. Create a Public Subnet

```hcl
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "TerraWeek-Public-Subnet"
  }
}
```

The subnet uses:

```text
10.0.1.0/24
```

The important dependency is:

```hcl
vpc_id = aws_vpc.main.id
```

Terraform understands that the subnet requires the VPC.

---

# 5. Create an Internet Gateway

```hcl
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "TerraWeek-IGW"
  }
}
```

The Internet Gateway is attached to the VPC.

The dependency is created automatically through:

```hcl
vpc_id = aws_vpc.main.id
```

---

# 6. Create a Public Route Table

```hcl
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "TerraWeek-Public-RT"
  }
}
```

The route:

```text
0.0.0.0/0
```

sends internet-bound traffic through the Internet Gateway.

The important dependency is:

```hcl
gateway_id = aws_internet_gateway.main.id
```

Therefore Terraform knows that the Internet Gateway must exist before the route can use it.

---

# 7. Associate the Route Table with the Subnet

```hcl
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
```

This connects:

```text
Public Subnet
      ↓
Public Route Table
```

Terraform automatically detects both dependencies.

---

# 8. Implicit Dependencies

Terraform can automatically detect dependencies when one resource references another resource.

For example:

```hcl
vpc_id = aws_vpc.main.id
```

This creates an implicit dependency.

Terraform understands:

```text
Subnet
  ↓
VPC
```

Another example:

```hcl
gateway_id = aws_internet_gateway.main.id
```

Terraform understands:

```text
Route Table
  ↓
Internet Gateway
```

Another example:

```hcl
subnet_id      = aws_subnet.public.id
route_table_id = aws_route_table.public.id
```

Terraform understands:

```text
Route Table Association
       ├── Subnet
       └── Route Table
```

### Dependency chain

The infrastructure therefore has relationships such as:

```text
VPC
├── Subnet
│
├── Internet Gateway
│
├── Route Table
│   └── Internet Gateway
│
└── Security Group
```

Terraform automatically builds this dependency graph from resource references.

---

# 9. Security Group

I created a Security Group inside the VPC.

```hcl
resource "aws_security_group" "main" {
  name        = "TerraWeek-SG"
  description = "Allow SSH and HTTP traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "TerraWeek-SG"
  }
}
```

The Security Group depends on the VPC because of:

```hcl
vpc_id = aws_vpc.main.id
```

### Security Group rules

SSH:

```text
Port: 22
Protocol: TCP
```

HTTP:

```text
Port: 80
Protocol: TCP
```

Outbound traffic:

```text
All traffic
```

> This configuration is for learning purposes. In production, SSH access should not normally be open to `0.0.0.0/0`.

---

# 10. EC2 Instance

I created an EC2 instance using Terraform.

```hcl
resource "aws_instance" "main" {
  ami                         = "ami-094210f044117049d"
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids     = [aws_security_group.main.id]
  associate_public_ip_address = true

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "TerraWeek-Server"
  }
}
```

### Important configuration

Instance type:

```text
t3.micro
```

Subnet:

```hcl
subnet_id = aws_subnet.public.id
```

Security Group:

```hcl
vpc_security_group_ids = [aws_security_group.main.id]
```

Public IP:

```hcl
associate_public_ip_address = true
```

The EC2 instance therefore depends on:

```text
Subnet
Security Group
```

Terraform automatically understands these dependencies.

---

# 11. Explicit Dependencies

Sometimes Terraform cannot determine a dependency from resource arguments alone.

Terraform provides:

```hcl
depends_on
```

for explicit dependencies.

I created an S3 bucket:

```hcl
resource "aws_s3_bucket" "app_logs" {
  bucket = "terraweek-app-logs-shraddha-2026"

  depends_on = [aws_instance.main]

  tags = {
    Name        = "TerraWeek-App-Logs"
    Environment = "Learning"
    Day         = "Day62"
  }
}
```

The important line is:

```hcl
depends_on = [aws_instance.main]
```

This tells Terraform:

```text
Create EC2 first
      ↓
Create S3 bucket
```

The S3 bucket does not technically need the EC2 instance for AWS functionality.

The dependency was added specifically to demonstrate an explicit Terraform dependency.

---

# 12. Implicit vs Explicit Dependencies

## Implicit dependency

Created automatically through a resource reference.

Example:

```hcl
subnet_id = aws_subnet.public.id
```

Terraform sees the reference and creates the dependency automatically.

```text
EC2
 ↓
Subnet
```

## Explicit dependency

Created manually with:

```hcl
depends_on = [aws_instance.main]
```

Example:

```hcl
resource "aws_s3_bucket" "app_logs" {
  bucket = "terraweek-app-logs-shraddha-2026"

  depends_on = [aws_instance.main]
}
```

Dependency:

```text
S3 Bucket
    ↓
EC2 Instance
```

### Comparison

| Dependency | How it is created  | Example                            |
| ---------- | ------------------ | ---------------------------------- |
| Implicit   | Resource reference | `aws_vpc.main.id`                  |
| Explicit   | `depends_on`       | `depends_on = [aws_instance.main]` |

Implicit dependencies should generally be preferred when a real resource relationship exists.

Use `depends_on` when Terraform needs a dependency that cannot be expressed naturally through an argument reference.

---

# 13. Terraform Dependency Graph

Terraform can generate a dependency graph using:

```bash
terraform graph
```

I generated a PNG graph using Graphviz:

```bash
terraform graph | dot -Tpng > graph.png
```

The generated file was:

```text
graph.png
```

I verified the file using:

```bash
ls -lh graph.png
```

The graph file was successfully generated.

---

# 14. Dependency Graph Output

The important relationships from the Terraform graph were:

```text
aws_instance.main -> aws_security_group.main
aws_instance.main -> aws_subnet.public

aws_internet_gateway.main -> aws_vpc.main

aws_route_table.public -> aws_internet_gateway.main

aws_route_table_association.public -> aws_route_table.public
aws_route_table_association.public -> aws_subnet.public

aws_s3_bucket.app_logs -> aws_instance.main

aws_security_group.main -> aws_vpc.main
aws_subnet.public -> aws_vpc.main
```

The most important explicit dependency was:

```text
aws_s3_bucket.app_logs
        ↓
aws_instance.main
```

This was created using:

```hcl
depends_on = [aws_instance.main]
```

---

# 15. Terraform State

After applying the infrastructure, I verified the Terraform state using:

```bash
terraform state list
```

The state contained:

```text
aws_instance.main
aws_internet_gateway.main
aws_route_table.public
aws_route_table_association.public
aws_s3_bucket.app_logs
aws_security_group.main
aws_subnet.public
aws_vpc.main
```

This confirmed that all eight resources were managed by Terraform.

---

# 16. Terraform Lifecycle Rules

Terraform provides lifecycle settings that control how resources are created, updated, and destroyed.

The lifecycle block used in this project was:

```hcl
lifecycle {
  create_before_destroy = true
}
```

---

# 17. `create_before_destroy`

```hcl
lifecycle {
  create_before_destroy = true
}
```

This tells Terraform to create the replacement resource before destroying the existing resource.

Normally, a replacement may involve:

```text
Destroy old resource
        ↓
Create new resource
```

With:

```hcl
create_before_destroy = true
```

Terraform attempts:

```text
Create new resource
        ↓
Destroy old resource
```

This can help reduce downtime when replacing resources.

---

# 18. Testing Lifecycle Replacement

To test the lifecycle behavior, I changed the EC2 AMI.

Original AMI:

```text
ami-090d68841c2a28756
```

New AMI:

```text
ami-094210f044117049d
```

I first validated the configuration:

```bash
terraform fmt
terraform validate
```

Terraform returned:

```text
Success! The configuration is valid.
```

Then I ran:

```bash
terraform plan
```

Terraform detected that the AMI change required the EC2 instance to be replaced.

The plan showed:

```text
+/- create replacement and then destroy
```

It also showed:

```text
ami = "ami-090d68841c2a28756" -> "ami-094210f044117049d" # forces replacement
```

The final plan was:

```text
Plan: 1 to add, 0 to change, 1 to destroy.
```

This demonstrated the effect of:

```hcl
create_before_destroy = true
```

---

# 19. Other Lifecycle Arguments

Terraform provides several useful lifecycle arguments.

## `create_before_destroy`

```hcl
lifecycle {
  create_before_destroy = true
}
```

Creates a replacement before destroying the old resource.

Useful when reducing downtime is important.

---

## `prevent_destroy`

```hcl
lifecycle {
  prevent_destroy = true
}
```

Prevents Terraform from destroying the resource.

If Terraform attempts to destroy a protected resource, Terraform returns an error instead of proceeding.

This can be useful for important resources such as production databases.

---

## `ignore_changes`

Example:

```hcl
lifecycle {
  ignore_changes = [
    tags
  ]
}
```

This tells Terraform to ignore changes to selected attributes.

It can be useful when some attributes are managed outside Terraform.

---

# 20. Complete `main.tf`

The final Terraform configuration used for this practical was:

```hcl
# 1. Create the VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "TerraWeek-VPC"
  }
}

# 2. Create a public subnet inside the VPC
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "TerraWeek-Public-Subnet"
  }
}

# 3. Create an Internet Gateway and attach it to the VPC
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "TerraWeek-IGW"
  }
}

# 4. Create a route table for the VPC
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "TerraWeek-Public-RT"
  }
}

# 5. Associate the route table with the public subnet
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# 6. Create a Security Group inside the VPC
resource "aws_security_group" "main" {
  name        = "TerraWeek-SG"
  description = "Allow SSH and HTTP traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "TerraWeek-SG"
  }
}

# 7. Create an EC2 instance inside the public subnet
resource "aws_instance" "main" {
  ami                         = "ami-094210f044117049d"
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids     = [aws_security_group.main.id]
  associate_public_ip_address = true

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "TerraWeek-Server"
  }
}

# 8. Create an S3 bucket for application logs
resource "aws_s3_bucket" "app_logs" {
  bucket = "terraweek-app-logs-shraddha-2026"

  depends_on = [aws_instance.main]

  tags = {
    Name        = "TerraWeek-App-Logs"
    Environment = "Learning"
    Day         = "Day62"
  }
}
```

The AWS provider configuration was kept separately in:

```text
providers.tf
```

---

# 21. Important Terraform Commands

### Initialize Terraform

```bash
terraform init
```

### Format configuration

```bash
terraform fmt
```

### Validate configuration

```bash
terraform validate
```

### Preview changes

```bash
terraform plan
```

### Apply infrastructure

```bash
terraform apply
```

### Show Terraform state

```bash
terraform state list
```

### Generate dependency graph

```bash
terraform graph
```

### Generate PNG dependency graph

```bash
terraform graph | dot -Tpng > graph.png
```

### Destroy infrastructure

```bash
terraform destroy
```

---

# 22. Verification

Terraform successfully created:

```text
VPC
Subnet
Internet Gateway
Route Table
Route Table Association
Security Group
EC2 Instance
S3 Bucket
```

The infrastructure was successfully applied.

The dependency graph was successfully generated.

The explicit dependency between the S3 bucket and EC2 instance was verified.

The lifecycle replacement behavior was successfully demonstrated by changing the EC2 AMI.

Finally, all infrastructure was destroyed.

The final destroy operation returned:

```text
Destroy complete! Resources: 8 destroyed.
```

After destruction:

```bash
terraform state list
```

returned no resources.

This confirmed that the Terraform state was clean.

---

# 23. What I Learned

### Providers

Providers allow Terraform to communicate with platforms such as AWS.

### Resources

Resources represent infrastructure objects such as:

```text
VPC
Subnet
EC2
Security Group
S3 Bucket
```

### Implicit Dependencies

Terraform automatically detects dependencies from resource references.

Example:

```hcl
vpc_id = aws_vpc.main.id
```

### Explicit Dependencies

Terraform allows manual dependency definitions using:

```hcl
depends_on
```

Example:

```hcl
depends_on = [aws_instance.main]
```

### Dependency Graph

Terraform can visualize dependencies using:

```bash
terraform graph
```

### Lifecycle

Terraform lifecycle rules control how resources are replaced or protected.

Example:

```hcl
create_before_destroy = true
```

---

# 24. Day 62 Final Architecture

```text
                         AWS
                          |
                         VPC
                    10.0.0.0/16
                          |
        +-----------------+-----------------+
        |                 |                 |
      Subnet          Internet GW       Security Group
  10.0.1.0/24             |                 |
        |                  |                 |
        +--------+---------+                 |
                 |                           |
              Route Table                   |
                 |                           |
                 +------------+--------------+
                              |
                           EC2 t3.micro
                              |
                              |
                        S3 Bucket
                    explicit depends_on
```

---

# 25. Key Takeaways

```text
Terraform Provider
       ↓
Terraform Resources
       ↓
Resource References
       ↓
Implicit Dependencies
       ↓
Explicit Dependencies
       ↓
Dependency Graph
       ↓
Lifecycle Management
```

The main concepts learned in Day 62 were:

1. Terraform providers connect Terraform to cloud platforms.
2. Resources define infrastructure.
3. Resource references create implicit dependencies.
4. `depends_on` creates explicit dependencies.
5. `terraform graph` visualizes dependencies.
6. `create_before_destroy` controls replacement behavior.
7. `prevent_destroy` protects important resources.
8. `ignore_changes` allows Terraform to ignore selected external changes.
9. `terraform destroy` removes resources managed by Terraform.
10. Always verify that temporary AWS infrastructure has been destroyed after practical work.

---

## ✅ Day 62 Completed

**Status: COMPLETE**

```text
Provider                 ✅
VPC                      ✅
Subnet                   ✅
Internet Gateway         ✅
Route Table              ✅
Route Table Association  ✅
Security Group           ✅
EC2 Instance             ✅
Implicit Dependencies    ✅
Explicit Dependencies    ✅
S3 Bucket                ✅
Terraform Graph          ✅
Lifecycle Rules          ✅
AMI Replacement Test     ✅
Terraform Destroy        ✅
State Cleanup             ✅
```
