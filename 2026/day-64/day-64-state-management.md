# Day 64 — Terraform State Management and Remote Backends

## 📌 Overview

Terraform state is one of the most important components of Terraform.

Terraform uses the state file to keep track of the infrastructure it manages. It maps Terraform configuration resources to real infrastructure resources in AWS.

In this practical, I learned and implemented:

* Terraform state inspection
* Local vs remote Terraform state
* Amazon S3 remote backend
* DynamoDB state locking
* State migration
* Terraform state locking demonstration
* Importing existing AWS resources
* Terraform state surgery
* `terraform state mv`
* `terraform state rm`
* Re-importing resources
* State drift detection
* Drift reconciliation
* Remote state verification

---

# 1. Terraform State

Terraform state stores information about infrastructure managed by Terraform.

The state allows Terraform to understand:

```text
Terraform Configuration
        ↓
     State File
        ↓
   AWS Infrastructure
```

Terraform compares:

```text
Configuration
      +
Current State
      +
Real Infrastructure
      ↓
Terraform Plan
```

Terraform then determines what changes are required.

---

# 2. Local State vs Remote State

## Local State

By default, Terraform stores state locally:

```text
terraform.tfstate
```

Example:

```text
~/90DaysOfDevOps/2026/day-63/terraform-aws-infra/
│
├── main.tf
├── variables.tf
├── outputs.tf
├── locals.tf
├── data.tf
├── backend.tf
└── terraform.tfstate
```

### Problems with local state

Local state is not ideal for team environments because:

* It exists on one machine.
* Multiple engineers cannot safely work with it.
* There is no centralized state storage.
* State locking is difficult.
* State can be accidentally deleted.
* Collaboration becomes difficult.

---

# 3. Remote State

For team environments, Terraform state can be stored remotely.

For this project, I used:

```text
Amazon S3
+
DynamoDB
```

Architecture:

```text
                    Terraform
                        |
                        |
                        v
              ┌─────────────────┐
              │   S3 Backend    │
              │                 │
              │ terraform.tfstate│
              └────────┬────────┘
                       |
                       |
                 State Locking
                       |
                       v
              ┌─────────────────┐
              │    DynamoDB     │
              │                 │
              │    LockID       │
              └─────────────────┘
```

---

# 4. AWS Remote Backend Configuration

The S3 bucket used for Terraform state:

```text
terraweek-state-shraddha
```

Terraform state key:

```text
dev/terraform.tfstate
```

DynamoDB table:

```text
terraweek-state-lock
```

Region:

```text
ap-south-1
```

---

# 5. S3 Backend Configuration

The `backend.tf` file contains:

```hcl
terraform {
  backend "s3" {
    bucket         = "terraweek-state-shraddha"
    key            = "dev/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraweek-state-lock"
    encrypt        = true
  }
}
```

### Explanation

| Parameter        | Purpose                           |
| ---------------- | --------------------------------- |
| `bucket`         | S3 bucket storing Terraform state |
| `key`            | Location/path of the state file   |
| `region`         | AWS region                        |
| `dynamodb_table` | Table used for state locking      |
| `encrypt`        | Encrypts the state                |

---

# 6. S3 Versioning

S3 versioning was enabled for the state bucket.

This is important because Terraform state is critical.

If the state changes incorrectly, previous versions can be recovered.

Example:

```text
S3 Bucket
│
└── dev/
    └── terraform.tfstate
         │
         ├── Version 1
         ├── Version 2
         ├── Version 3
         └── Version 4
```

---

# 7. DynamoDB State Locking

The DynamoDB table used was:

```text
terraweek-state-lock
```

Primary key:

```text
LockID
```

Type:

```text
String
```

Billing mode:

```text
PAY_PER_REQUEST
```

The purpose of locking is to prevent multiple Terraform operations from modifying the same state simultaneously.

---

# 8. Terraform State Inspection

Before working with remote state, Terraform state can be inspected using:

```bash
terraform show
```

This displays the resources currently tracked by Terraform.

---

## List Resources

```bash
terraform state list
```

Example resources:

```text
data.aws_ami.amazon_linux
data.aws_availability_zones.available
aws_instance.main
aws_internet_gateway.main
aws_route_table.public
aws_route_table_association.public
aws_s3_bucket.app_logs
aws_s3_bucket.logs_bucket
aws_security_group.main
aws_subnet.public
aws_vpc.main
```

---

## Inspect an EC2 Instance

```bash
terraform state show aws_instance.main
```

---

## Inspect the VPC

```bash
terraform state show aws_vpc.main
```

These commands are useful for inspecting the exact attributes Terraform has stored for a resource.

---

# 9. Terraform State Serial

Terraform state contains metadata including a state `serial`.

The serial number changes whenever the state changes.

Conceptually:

```text
State Version 1
      ↓
Resource changed
      ↓
State Version 2
      ↓
serial increases
```

The serial helps Terraform identify the latest state version.

---

# 10. Migrating Local State to S3

The state was migrated from local storage to the S3 backend.

Command:

```bash
terraform init -migrate-state
```

Terraform asked for confirmation to migrate the existing local state.

After migration, Terraform began using the S3 backend.

---

# 11. Verify Remote State

The remote state object was verified using:

```bash
aws s3api head-object \
  --bucket terraweek-state-shraddha \
  --key dev/terraform.tfstate \
  --region ap-south-1
```

The state was successfully stored in S3.

The S3 bucket also had:

* Versioning enabled
* Encryption enabled

---

# 12. Verify Terraform Plan

After migrating state:

```bash
terraform plan
```

Final result:

```text
No changes.
Your infrastructure matches the configuration.
```

This confirmed that Terraform was correctly reading the remote state.

---

# 13. Terraform State Locking

Terraform state locking prevents two Terraform operations from modifying the same state simultaneously.

For example:

```text
Terminal 1
terraform apply
       │
       ↓
   State Lock
       │
       ↓
S3 + DynamoDB
       │
       X
Terminal 2
terraform plan
```

Terminal 2 cannot acquire the lock while Terminal 1 is using it.

---

# 14. Locking Demonstration

Two terminal sessions were used.

### Terminal 1

A Terraform apply operation was started and held the state lock.

### Terminal 2

The following command was executed:

```bash
terraform plan
```

Terraform returned:

```text
Error: Error acquiring the state lock
```

The lock information showed:

```text
ID:      22862f3e-3310-ba15-f0fa-ce4241bbd1c7
Path:    terraweek-state-shraddha/dev/terraform.tfstate
Operation: OperationTypeApply
Who:     shraddha@shraddha-HP-Laptop-15s-fr4xxx
Version: 1.16.0
```

This proved that DynamoDB state locking was working.

---

# 15. Important: Force Unlock

Terraform provides:

```bash
terraform force-unlock <LOCK_ID>
```

However, this command should **not** be used casually.

It should only be used when a lock is genuinely stale and no Terraform operation is actually running.

In this practical, the lock was released normally after the operation completed.

Therefore, `force-unlock` was not required.

---

# 16. Import Existing AWS Resource

Terraform can import infrastructure that already exists in AWS.

First, an S3 bucket was manually created:

```text
terraweek-import-test-shraddha
```

AWS CLI command:

```bash
aws s3api create-bucket \
  --bucket terraweek-import-test-shraddha \
  --region ap-south-1 \
  --create-bucket-configuration LocationConstraint=ap-south-1
```

The bucket was verified using:

```bash
aws s3api head-bucket \
  --bucket terraweek-import-test-shraddha
```

---

# 17. Terraform Configuration for Imported Resource

The resource was defined in `import.tf`:

```hcl
resource "aws_s3_bucket" "imported" {
  bucket = "terraweek-import-test-shraddha"
}
```

Terraform configuration was formatted:

```bash
terraform fmt
```

And validated:

```bash
terraform validate
```

Result:

```text
Success! The configuration is valid.
```

---

# 18. Import the Existing Bucket

The existing AWS bucket was imported into Terraform:

```bash
terraform import \
  aws_s3_bucket.imported \
  terraweek-import-test-shraddha
```

Result:

```text
Import successful!
```

---

# 19. Verify Imported Resource

List Terraform resources:

```bash
terraform state list
```

The imported resource appeared as:

```text
aws_s3_bucket.imported
```

Inspect it:

```bash
terraform state show aws_s3_bucket.imported
```

This showed the bucket information stored in Terraform state.

---

# 20. Verify Import With Terraform Plan

After importing:

```bash
terraform plan
```

Result:

```text
No changes.
Your infrastructure matches the configuration.
```

This confirmed that the Terraform configuration matched the imported AWS resource.

---

# 21. Terraform State Surgery

Terraform provides commands for modifying the state without destroying the real infrastructure.

Important commands include:

```text
terraform state mv
terraform state rm
terraform import
terraform force-unlock
```

---

# 22. `terraform state mv`

The imported resource initially had this address:

```text
aws_s3_bucket.imported
```

It was renamed in Terraform state:

```bash
terraform state mv \
  aws_s3_bucket.imported \
  aws_s3_bucket.logs_bucket
```

Terraform reported:

```text
Successfully moved 1 object(s).
```

---

# 23. Update Terraform Configuration

The configuration was changed from:

```hcl
resource "aws_s3_bucket" "imported" {
  bucket = "terraweek-import-test-shraddha"
}
```

to:

```hcl
resource "aws_s3_bucket" "logs_bucket" {
  bucket = "terraweek-import-test-shraddha"
}
```

Then:

```bash
terraform fmt
```

and:

```bash
terraform plan
```

Result:

```text
No changes.
Your infrastructure matches the configuration.
```

This demonstrated that `terraform state mv` changed the Terraform resource address without recreating the AWS bucket.

---

# 24. `terraform state rm`

Next, the resource was removed from Terraform state:

```bash
terraform state rm aws_s3_bucket.logs_bucket
```

Terraform returned:

```text
Successfully removed 1 resource instance(s).
```

Important:

`terraform state rm` does **not** delete the actual AWS resource.

It only removes the resource from Terraform's state.

---

# 25. Verify AWS Resource Still Exists

The bucket was checked directly in AWS:

```bash
aws s3api head-bucket \
  --bucket terraweek-import-test-shraddha
```

The bucket still existed.

Therefore:

```text
terraform state rm
        ↓
Removed from Terraform state
        ↓
AWS resource still exists
```

---

# 26. Re-import the Resource

Because the bucket still existed in AWS, it was imported again:

```bash
terraform import \
  aws_s3_bucket.logs_bucket \
  terraweek-import-test-shraddha
```

Then:

```bash
terraform plan
```

Result:

```text
No changes.
Your infrastructure matches the configuration.
```

This completed the state surgery exercise.

---

# 27. State Drift

## What is Drift?

Drift occurs when infrastructure is changed outside Terraform.

Example:

```text
Terraform Configuration
        |
        | expected
        v
Name = terraweek-dev-server

AWS Infrastructure
        |
        | manually changed
        v
Name = ManuallyChanged
```

Now Terraform configuration and AWS infrastructure are different.

---

# 28. Simulate Drift

The EC2 instance was manually modified in AWS.

The EC2 `Name` tag was changed from:

```text
terraweek-dev-server
```

to:

```text
ManuallyChanged
```

This created intentional infrastructure drift.

---

# 29. Detect Drift

The following command was executed:

```bash
terraform plan
```

Terraform detected the difference:

```text
~ tags = {
    "Environment" = "dev"
    "ManagedBy"   = "Terraform"
  ~ "Name"        = "ManuallyChanged" -> "terraweek-dev-server"
    "Project"      = "terraweek"
}
```

Terraform showed:

```text
Plan: 0 to add, 1 to change, 0 to destroy.
```

This confirmed that Terraform detected the manually changed tag.

---

# 30. Reconcile Drift

The drift was fixed by applying the Terraform configuration:

```bash
terraform apply
```

Terraform detected the change and modified the EC2 instance.

Result:

```text
Apply complete!
Resources: 0 added, 1 changed, 0 destroyed.
```

The `Name` tag was restored to:

```text
terraweek-dev-server
```

---

# 31. Final Drift Verification

After reconciliation:

```bash
terraform plan
```

Result:

```text
No changes.
Your infrastructure matches the configuration.
```

This confirmed that:

```text
Configuration = State = AWS Infrastructure
```

---

# 32. Important Terraform State Commands

| Command                  | Purpose                           |
| ------------------------ | --------------------------------- |
| `terraform show`         | Display current state             |
| `terraform state list`   | List resources in state           |
| `terraform state show`   | Display one resource              |
| `terraform state mv`     | Rename/move resource address      |
| `terraform state rm`     | Remove resource from state        |
| `terraform import`       | Import existing infrastructure    |
| `terraform force-unlock` | Remove a stale state lock         |
| `terraform plan`         | Detect required changes and drift |
| `terraform apply`        | Apply configuration changes       |
| `terraform refresh`      | Legacy state refresh operation    |

---

# 33. When to Use `terraform state mv`

Use:

```bash
terraform state mv
```

when changing a Terraform resource address without wanting Terraform to destroy and recreate the actual infrastructure.

Example:

```text
aws_s3_bucket.imported
        ↓
aws_s3_bucket.logs_bucket
```

The AWS bucket remains the same.

---

# 34. When to Use `terraform state rm`

Use:

```bash
terraform state rm
```

when Terraform should stop managing a resource while the real infrastructure remains.

Example:

```text
Terraform State
       ↓
Resource removed

AWS
       ↓
Resource remains
```

Be careful because Terraform may attempt to create the resource again if it remains in configuration and is not subsequently handled correctly.

---

# 35. When to Use `terraform import`

Use:

```bash
terraform import
```

when infrastructure already exists in AWS but is not currently managed by Terraform.

Example:

```text
Existing AWS S3 Bucket
        ↓
terraform import
        ↓
Terraform State
```

---

# 36. When to Use `terraform force-unlock`

Use:

```bash
terraform force-unlock <LOCK_ID>
```

only when:

* Terraform crashed
* The process was terminated unexpectedly
* The state lock remained behind
* No Terraform operation is currently running

Never force-unlock an active Terraform operation.

---

# 37. State Security

Terraform state can contain sensitive information depending on the resources being managed.

Therefore, state should be protected.

Recommended practices:

* Store state remotely.
* Enable encryption.
* Enable S3 versioning.
* Restrict IAM permissions.
* Enable state locking.
* Never commit `terraform.tfstate` to Git.
* Never expose state publicly.
* Use secure backend access.

---

# 38. Terraform State Architecture Used

The final architecture was:

```text
                    Developer
                        |
                        |
                   Terraform CLI
                        |
                        v
              ┌─────────────────┐
              │ Terraform Config│
              │     *.tf        │
              └────────┬────────┘
                       |
                       v
              ┌─────────────────┐
              │   S3 Backend    │
              │                 │
              │ dev/            │
              │ terraform.tfstate│
              └────────┬────────┘
                       |
                 State Locking
                       |
                       v
              ┌─────────────────┐
              │    DynamoDB     │
              │ terraweek-state │
              │     -lock       │
              └─────────────────┘
                       |
                       v
              ┌─────────────────┐
              │   AWS Resources │
              │                 │
              │ VPC             │
              │ Subnet          │
              │ Route Table     │
              │ IGW             │
              │ Security Group  │
              │ EC2             │
              │ S3              │
              └─────────────────┘
```

---

# 39. Final Verification

The following command was used:

```bash
terraform plan
```

Final result:

```text
No changes.
Your infrastructure matches the configuration.
```

This confirmed:

* Remote state is working.
* Terraform can read the S3 state.
* Resources are correctly tracked.
* Imported resources are correctly managed.
* State surgery was successful.
* Drift was detected.
* Drift was reconciled.
* AWS infrastructure matches Terraform configuration.

---

# 40. What I Learned

Through this practical, I learned that Terraform state is the connection between Terraform configuration and real infrastructure.

I learned how to:

1. Inspect Terraform state.
2. Store Terraform state remotely in Amazon S3.
3. Enable S3 versioning.
4. Use DynamoDB for state locking.
5. Migrate local state to remote state.
6. Verify remote state.
7. Demonstrate Terraform state locking.
8. Import existing AWS infrastructure.
9. Move resources using `terraform state mv`.
10. Remove resources from state using `terraform state rm`.
11. Re-import existing resources.
12. Detect infrastructure drift.
13. Reconcile drift using Terraform.
14. Protect Terraform state.

---

# 41. Key DevOps Concepts

The most important concepts from this practical are:

```text
Terraform State
      ↓
Remote Backend
      ↓
S3
      ↓
State Locking
      ↓
DynamoDB
      ↓
Import
      ↓
State Surgery
      ↓
Drift Detection
      ↓
Drift Reconciliation
```

Terraform state management is especially important in production and team environments because many engineers may work on the same infrastructure.

A properly configured remote backend provides centralized state storage, versioning, encryption, and locking.

---

# 42. Final Status

## Day 64 Practical Checklist

* [x] Inspected Terraform state
* [x] Used `terraform show`
* [x] Used `terraform state list`
* [x] Used `terraform state show`
* [x] Created S3 remote backend
* [x] Enabled S3 versioning
* [x] Enabled encryption
* [x] Created DynamoDB lock table
* [x] Migrated local state to S3
* [x] Verified remote state
* [x] Tested state locking
* [x] Imported existing S3 bucket
* [x] Used `terraform state mv`
* [x] Used `terraform state rm`
* [x] Verified AWS resource was not deleted
* [x] Re-imported resource
* [x] Simulated infrastructure drift
* [x] Detected drift using `terraform plan`
* [x] Reconciled drift using `terraform apply`
* [x] Verified final `terraform plan`
* [x] Final result: **No changes**

---

# 🎯 Day 64 Completed Successfully

```text
Terraform State Management
          ✅
Remote S3 Backend
          ✅
DynamoDB Locking
          ✅
State Migration
          ✅
Resource Import
          ✅
State Surgery
          ✅
Drift Detection
          ✅
Drift Reconciliation
          ✅
Final Terraform Plan
          ✅
```

**Day 64 — Terraform State Management and Remote Backends: COMPLETE ✅**
