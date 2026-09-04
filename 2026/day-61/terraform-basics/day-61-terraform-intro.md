# Day 61 — Introduction to Terraform and Your First AWS Infrastructure

## 📌 Day 61 Overview

Today I started learning **Terraform**, an Infrastructure as Code (IaC) tool used to define, provision, modify, and destroy infrastructure using configuration files.

For this practical, I used Terraform with AWS to:

- Configure the AWS provider
- Create an S3 bucket
- Create an EC2 instance
- Understand Terraform state
- Modify an EC2 resource in-place
- Understand Terraform plan symbols
- Destroy the infrastructure using Terraform
- Verify that Terraform state was cleaned up

---

# 🎯 Objectives

By the end of Day 61, I learned:

- What Infrastructure as Code (IaC) means
- Why IaC is useful in DevOps
- What Terraform is
- How Terraform works with AWS
- How to initialize a Terraform project
- How to create AWS resources using Terraform
- How Terraform state works
- How Terraform detects infrastructure changes
- How to update resources in-place
- How to destroy infrastructure using Terraform

---

# 1. What is Infrastructure as Code?

**Infrastructure as Code (IaC)** is the practice of managing and provisioning infrastructure using machine-readable configuration files instead of manually creating resources through a cloud provider's web console.

For example, instead of manually creating an EC2 instance from the AWS Console, Terraform allows us to define the instance in a `.tf` file.

Example:

```hcl
resource "aws_instance" "terraform_ec2" {
  ami           = "ami-0f5ee92e2d63afc18"
  instance_type = "t3.micro"

  tags = {
    Name = "TerraWeek-Modified"
  }
}
````

Terraform reads this configuration and creates the required infrastructure in AWS.

---

# 2. Why is IaC Important in DevOps?

IaC is important because it makes infrastructure:

* Repeatable
* Consistent
* Automated
* Version controlled
* Easier to review
* Easier to reproduce
* Easier to modify
* Easier to destroy and recreate

### Without IaC

A developer or DevOps engineer might manually:

1. Open AWS Console
2. Create a VPC
3. Create a subnet
4. Create security groups
5. Create an EC2 instance
6. Configure settings
7. Add tags
8. Repeat the process for another environment

This can lead to:

* Human errors
* Configuration differences
* Manual work
* Difficult troubleshooting
* Poor reproducibility

### With IaC

The infrastructure can be described in code and managed through Terraform:

```text
Terraform Configuration
        ↓
terraform plan
        ↓
Review Changes
        ↓
terraform apply
        ↓
AWS Infrastructure
```

---

# 3. What is Terraform?

Terraform is an **Infrastructure as Code tool** developed by HashiCorp.

Terraform uses a **declarative configuration language** called **HCL (HashiCorp Configuration Language)**.

Instead of describing every step required to create infrastructure, we describe the desired final state.

For example:

```hcl
resource "aws_s3_bucket" "terraform_bucket" {
  bucket = "terraweek-shraddha-2026"
}
```

This tells Terraform:

> I want an S3 bucket with this configuration.

Terraform determines what actions are required to achieve that desired state.

---

# 4. Terraform is Declarative

Terraform is declarative.

This means we define **what we want**, rather than describing every individual command required to create it.

Example:

```hcl
instance_type = "t3.micro"
```

We don't manually tell Terraform:

```text
Open AWS
Select EC2
Select an AMI
Select instance type
Click Launch
Add tag
```

Instead, Terraform determines the required actions.

---

# 5. Terraform is Cloud-Agnostic

Terraform can manage infrastructure across many platforms using providers.

Examples include:

* AWS
* Azure
* Google Cloud
* Kubernetes
* GitHub
* Cloudflare
* Docker

This allows Terraform to be used across different environments.

---

# 6. Terraform vs Other Tools

## Terraform vs AWS CloudFormation

| Terraform                     | CloudFormation          |
| ----------------------------- | ----------------------- |
| Multi-cloud                   | AWS-focused             |
| Developed by HashiCorp        | Developed by AWS        |
| Uses HCL                      | Uses YAML/JSON          |
| Large provider ecosystem      | AWS service integration |
| Can manage multiple platforms | Primarily AWS           |

## Terraform vs Ansible

| Terraform                   | Ansible                                                       |
| --------------------------- | ------------------------------------------------------------- |
| Infrastructure provisioning | Configuration management                                      |
| Declarative                 | Primarily procedural/declarative automation                   |
| Creates infrastructure      | Configures systems                                            |
| Uses state                  | Usually does not maintain infrastructure state like Terraform |

Terraform can create an EC2 instance, while Ansible can configure software and services on that instance.

## Terraform vs Pulumi

| Terraform                                      | Pulumi                                                 |
| ---------------------------------------------- | ------------------------------------------------------ |
| Uses HCL                                       | Uses programming languages                             |
| HCL is Terraform's main configuration language | Supports languages such as Python, TypeScript and Go   |
| Large provider ecosystem                       | Infrastructure as Code using general-purpose languages |

---

# 7. Environment Used

### Operating System

```text
Ubuntu Linux
```

### Terraform

```text
Terraform v1.16.0
```

### Architecture

```text
linux_amd64
```

### AWS CLI

```text
AWS CLI v2
```

### AWS Region

```text
ap-south-1
```

### AWS Resources

```text
S3
EC2
```

---

# 8. Terraform Installation Verification

I verified Terraform using:

```bash
terraform -version
```

Output:

```text
Terraform v1.16.0
on linux_amd64
```

This confirmed that Terraform was successfully installed.

---

# 9. AWS CLI Verification

I verified AWS CLI:

```bash
aws --version
```

I also verified that the AWS credentials were working:

```bash
aws sts get-caller-identity
```

This confirmed that Terraform/AWS CLI could authenticate with AWS.

---

# 10. Terraform Project Structure

My Terraform project was created inside:

```text
2026/day-61/terraform-basics/
```

The project contained:

```text
terraform-basics/
├── .terraform/
├── .terraform.lock.hcl
├── main.tf
├── terraform.tfstate
└── terraform.tfstate.backup
```

---

# 11. Terraform Configuration

My `main.tf` contains the AWS provider, S3 bucket, and EC2 instance.

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  required_version = ">= 1.6.0"
}

provider "aws" {
  region = "ap-south-1"
}

resource "aws_s3_bucket" "terraform_bucket" {
  bucket = "terraweek-shraddha-2026"

  tags = {
    Name        = "TerraWeek-S3"
    Environment = "Learning"
    Day         = "Day61"
  }
}

resource "aws_instance" "terraform_ec2" {
  ami           = "ami-0f5ee92e2d63afc18"
  instance_type = "t3.micro"

  tags = {
    Name = "TerraWeek-Modified"
  }
}
```

> Note: I originally used `t2.micro`, but AWS reported that it was not eligible for Free Tier for my account. I checked the eligible instance types and changed the configuration to `t3.micro`.

---

# 12. Terraform Init

The first Terraform command I used was:

```bash
terraform init
```

### Purpose

`terraform init` initializes a Terraform working directory.

It:

* Downloads required providers
* Initializes the `.terraform` directory
* Creates or updates `.terraform.lock.hcl`
* Prepares the project for other Terraform commands

---

# 13. Terraform Plan

I used:

```bash
terraform plan
```

### Purpose

`terraform plan` shows what Terraform intends to change.

It allows us to review changes before actually modifying infrastructure.

For example:

```text
Plan: 1 to add, 0 to change, 0 to destroy.
```

means Terraform planned to create one resource.

---

# 14. Creating the S3 Bucket

I created an S3 bucket using Terraform.

Resource:

```hcl
resource "aws_s3_bucket" "terraform_bucket" {
  bucket = "terraweek-shraddha-2026"

  tags = {
    Name        = "TerraWeek-S3"
    Environment = "Learning"
    Day         = "Day61"
  }
}
```

Then I applied the configuration:

```bash
terraform apply
```

Terraform successfully created the S3 bucket.

The bucket name was:

```text
terraweek-shraddha-2026
```

Region:

```text
ap-south-1
```

---

# 15. Checking Terraform State

I checked the managed resources using:

```bash
terraform state list
```

The output showed:

```text
aws_s3_bucket.terraform_bucket
```

After creating EC2, the state contained:

```text
aws_instance.terraform_ec2
aws_s3_bucket.terraform_bucket
```

This confirmed that Terraform was managing both resources.

---

# 16. Creating the EC2 Instance

I added an EC2 resource:

```hcl
resource "aws_instance" "terraform_ec2" {
  ami           = "ami-0f5ee92e2d63afc18"
  instance_type = "t3.micro"

  tags = {
    Name = "TerraWeek-Day1"
  }
}
```

I first attempted to use:

```text
t2.micro
```

AWS rejected it because it was not eligible for Free Tier for my account.

I checked eligible instance types with:

```bash
aws ec2 describe-instance-types \
  --filters Name=free-tier-eligible,Values=true \
  --query 'InstanceTypes[*].InstanceType' \
  --output table
```

AWS showed:

```text
c7i-flex.large
t4g.small
t3.micro
t4g.micro
t3.small
m7i-flex.large
```

I selected:

```text
t3.micro
```

The EC2 instance was then successfully created.

---

# 17. Terraform State

Terraform state is one of the most important Terraform concepts.

Terraform stores information about managed infrastructure in:

```text
terraform.tfstate
```

The state allows Terraform to map resources in the configuration to real infrastructure.

For example:

```text
main.tf
   ↓
Terraform
   ↓
terraform.tfstate
   ↓
AWS resources
```

Terraform uses state to determine:

* Which resources it manages
* Resource IDs
* Current infrastructure attributes
* Relationships between resources
* What changes are required

---

# 18. Inspecting Terraform State

I used:

```bash
terraform state list
```

to list managed resources.

I also used:

```bash
terraform state show aws_instance.terraform_ec2
```

to inspect the EC2 resource.

And:

```bash
terraform show
```

to display the Terraform state in a human-readable form.

---

# 19. Important Terraform Files

## `main.tf`

Contains the desired infrastructure configuration.

```text
main.tf
```

## `terraform.tfstate`

Contains Terraform's state information about managed resources.

```text
terraform.tfstate
```

## `terraform.tfstate.backup`

Contains a backup of the previous state.

```text
terraform.tfstate.backup
```

## `.terraform/`

Contains Terraform's local working data and provider information.

```text
.terraform/
```

## `.terraform.lock.hcl`

Records provider dependency selections and checksums.

```text
.terraform.lock.hcl
```

---

# 20. Why Terraform State Should Not Be Manually Edited

Terraform state should not normally be manually edited.

Terraform expects the state to have a specific structure and relationship with the infrastructure.

Manual modifications can cause:

* Incorrect resource tracking
* State inconsistencies
* Unexpected Terraform plans
* Infrastructure problems

Terraform provides commands for managing state safely, such as:

```bash
terraform state list
terraform state show
terraform state mv
terraform state rm
```

---

# 21. Why Terraform State Should Not Be Committed to Git

Terraform state can contain infrastructure information and potentially sensitive values.

Therefore, Terraform state should normally not be committed to a public Git repository.

A `.gitignore` should include:

```gitignore
.terraform/
*.tfstate
*.tfstate.*
```

The provider lock file should generally be committed:

```text
.terraform.lock.hcl
```

because it helps keep provider dependency selections consistent.

---

# 22. Modifying the EC2 Instance

Initially, the EC2 tag was:

```hcl
tags = {
  Name = "TerraWeek-Day1"
}
```

I changed it to:

```hcl
tags = {
  Name = "TerraWeek-Modified"
}
```

Then I ran:

```bash
terraform fmt
```

followed by:

```bash
terraform plan
```

Terraform detected:

```text
~ "Name" = "TerraWeek-Day1" -> "TerraWeek-Modified"
```

The plan showed:

```text
Plan: 0 to add, 1 to change, 0 to destroy.
```

---

# 23. Terraform Plan Symbols

Terraform uses symbols to show resource actions.

```text
+    Create
~    Update in-place
-    Destroy
-/+  Destroy and recreate
```

In my example:

```text
~ update in-place
```

meant that Terraform could update the EC2 tag without replacing the EC2 instance.

---

# 24. Applying the EC2 Tag Change

I ran:

```bash
terraform apply
```

Terraform successfully updated the EC2 instance.

Output:

```text
Apply complete! Resources: 0 added, 1 changed, 0 destroyed.
```

I then verified the state:

```bash
terraform state show aws_instance.terraform_ec2
```

The tag showed:

```text
tags = {
  "Name" = "TerraWeek-Modified"
}
```

---

# 25. Testing Terraform Idempotency

I ran:

```bash
terraform apply
```

again.

Terraform returned:

```text
No changes. Your infrastructure matches the configuration.
```

This demonstrates an important Terraform behavior:

> When the real infrastructure already matches the desired configuration, Terraform does not make unnecessary changes.

---

# 26. Destroying Infrastructure

After completing the practical work, I cleaned up the AWS resources using:

```bash
terraform destroy
```

Terraform planned:

```text
Plan: 0 to add, 0 to change, 2 to destroy.
```

The resources were:

```text
aws_instance.terraform_ec2
aws_s3_bucket.terraform_bucket
```

I confirmed the destruction by entering:

```text
yes
```

Terraform successfully destroyed both resources:

```text
Destroy complete! Resources: 2 destroyed.
```

---

# 27. Verifying Terraform State After Destroy

I ran:

```bash
terraform state list
```

There was no output.

This means Terraform no longer has any managed resources in the state.

The infrastructure was successfully cleaned up.

---

# 28. Why `terraform plan` Shows Resources Again After Destroy

After destroying the infrastructure, I ran:

```bash
terraform plan
```

Terraform showed:

```text
Plan: 2 to add, 0 to change, 0 to destroy.
```

This is expected.

The reason is:

```text
main.tf
   ↓
Still defines S3 + EC2
   ↓
AWS resources were destroyed
   ↓
Terraform compares desired state with actual state
   ↓
Terraform wants to create them again
```

So:

```text
2 to add
```

does not mean the resources currently exist.

It means Terraform would recreate them if I ran:

```bash
terraform apply
```

---

# 29. Complete Terraform Workflow

The Terraform workflow I practiced was:

```text
Write Terraform Configuration
          ↓
terraform init
          ↓
terraform fmt
          ↓
terraform plan
          ↓
terraform apply
          ↓
Infrastructure Created
          ↓
terraform state list
          ↓
terraform state show
          ↓
Modify Configuration
          ↓
terraform plan
          ↓
terraform apply
          ↓
Infrastructure Updated
          ↓
terraform destroy
          ↓
Infrastructure Destroyed
```

---

# 30. Important Commands Learned

## Check Terraform version

```bash
terraform -version
```

## Initialize Terraform

```bash
terraform init
```

## Format Terraform files

```bash
terraform fmt
```

## Validate configuration

```bash
terraform validate
```

## Preview changes

```bash
terraform plan
```

## Apply configuration

```bash
terraform apply
```

## Show state

```bash
terraform show
```

## List resources in state

```bash
terraform state list
```

## Show one resource

```bash
terraform state show aws_instance.terraform_ec2
```

## Destroy infrastructure

```bash
terraform destroy
```

---

# 31. Key Terraform Concepts

### Infrastructure as Code

Infrastructure is managed through code instead of manual cloud-console operations.

### Declarative

We describe the desired final state.

### Provider

A provider allows Terraform to communicate with an infrastructure platform.

Example:

```hcl
provider "aws" {
  region = "ap-south-1"
}
```

### Resource

A resource represents infrastructure managed by Terraform.

Example:

```hcl
resource "aws_instance" "terraform_ec2" {
}
```

### State

Terraform state tracks resources managed by Terraform.

```text
terraform.tfstate
```

### Plan

Shows proposed changes before applying them.

```bash
terraform plan
```

### Apply

Applies the planned changes.

```bash
terraform apply
```

### Destroy

Removes infrastructure managed by Terraform.

```bash
terraform destroy
```

---

# 32. What I Learned

Today I learned that Terraform allows infrastructure to be managed as code.

The most important concepts I learned were:

* Infrastructure as Code
* Declarative infrastructure
* Terraform providers
* Terraform resources
* Terraform state
* Terraform plan
* Terraform apply
* Terraform destroy
* Resource lifecycle
* In-place updates
* Terraform state management
* Idempotency

I also learned how Terraform compares the desired configuration with the actual infrastructure and determines what changes are required.

---

# 33. Practical Result

By the end of the practical, I successfully:

* Installed Terraform
* Configured AWS CLI
* Verified AWS authentication
* Initialized a Terraform project
* Created an S3 bucket
* Created an EC2 instance
* Used Terraform state commands
* Modified an EC2 tag
* Updated the resource in-place
* Verified that no unnecessary changes were made
* Destroyed the AWS infrastructure
* Verified that Terraform state was empty

---

# 34. Screenshots / Evidence

## Terraform Installation

Add screenshot here:

```text
Screenshot: terraform -version
```

## AWS Authentication

Add screenshot here:

```text
Screenshot: aws sts get-caller-identity
```

## Terraform Init

Add screenshot here:

```text
Screenshot: terraform init
```

## S3 Creation

Add screenshot here:

```text
Screenshot: terraform apply — S3 bucket creation
```

## AWS S3 Console

Add screenshot here:

```text
Screenshot: S3 bucket in AWS Console
```

## EC2 Creation

Add screenshot here:

```text
Screenshot: terraform apply — EC2 creation
```

## AWS EC2 Console

Add screenshot here:

```text
Screenshot: EC2 instance TerraWeek-Modified
```

## Terraform State

Add screenshot here:

```text
Screenshot: terraform state list
```

## Terraform Plan

Add screenshot here:

```text
Screenshot: terraform plan showing ~ update in-place
```

## Terraform Destroy

Add screenshot here:

```text
Screenshot: terraform destroy
```

---

# 35. Interview Questions

### 1. What is Terraform?

Terraform is an Infrastructure as Code tool used to provision and manage infrastructure using configuration files.

### 2. What is Infrastructure as Code?

IaC is the practice of managing infrastructure using machine-readable configuration files instead of manual operations.

### 3. What is a Terraform provider?

A provider is a plugin that allows Terraform to communicate with an infrastructure platform or service.

### 4. What is Terraform state?

Terraform state is the record Terraform uses to track resources it manages and map configuration resources to real infrastructure.

### 5. What does `terraform plan` do?

It creates an execution plan showing what Terraform intends to create, modify, or destroy.

### 6. What does `terraform apply` do?

It applies the changes described by the Terraform configuration.

### 7. What does `terraform destroy` do?

It destroys resources managed by the Terraform configuration.

### 8. What does `~` mean in Terraform plan?

It means the resource will be updated in-place.

### 9. What does `+` mean?

It means Terraform will create a resource.

### 10. What does `-` mean?

It means Terraform will destroy a resource.

### 11. Why should Terraform state not be manually edited?

Because manual changes can make Terraform state inconsistent with the infrastructure and cause unexpected behavior.

### 12. Why should Terraform state not normally be committed to Git?

Because state can contain sensitive infrastructure information and can create collaboration and state-management problems.

---

# 36. Day 61 Summary

```text
Day 61 — Terraform Fundamentals
        ↓
Infrastructure as Code
        ↓
Terraform Installation
        ↓
AWS Provider
        ↓
S3 Bucket
        ↓
EC2 Instance
        ↓
Terraform State
        ↓
In-place Update
        ↓
Terraform Destroy
```

## 🚀 Day 61 Completed

I successfully completed the Terraform and AWS practical for Day 61.



